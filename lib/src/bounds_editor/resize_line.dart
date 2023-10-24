import 'package:flutter/material.dart';
import 'package:flutter_map_polywidget/src/bounds_editor/state.dart';

const double thickness = 8;

abstract class ResizeLineData {
  double? offset;

  ResizeLineData({this.offset});

  EdgeInsets modifySize(EdgeInsets size);

  Widget build(BuildContext context);
}

class LeftHorizontalResizeLineData extends ResizeLineData {
  @override
  Widget build(BuildContext context) {
    BoundsEditorState state = BoundsEditorState.of(context);
    return Positioned.fill(
      left: state.size.left - thickness,
      child: PositionedResizeLine(
        onOffsetChanged: (offset) {
          this.offset = offset.dx;
          state.onLineChanged(this);
        },
        child: _VerticalDivider(),
      ),
    );
  }

  @override
  EdgeInsets modifySize(EdgeInsets size) => size.copyWith(left: offset);
}

class RightHorizontalResizeLineData extends ResizeLineData {
  @override
  Widget build(BuildContext context) {
    BoundsEditorState state = BoundsEditorState.of(context);
    return Positioned.fill(
      left: state.parentSize.width - state.size.right,
      child: PositionedResizeLine(
        onOffsetChanged: (offset) {
          this.offset = state.parentSize.width - offset.dx;
          state.onLineChanged(this);
        },
        child: _VerticalDivider(),
      ),
    );
  }

  @override
  EdgeInsets modifySize(EdgeInsets size) => size.copyWith(right: offset);
}

class TopVerticalResizeLineData extends ResizeLineData {
  @override
  Widget build(BuildContext context) {
    BoundsEditorState state = BoundsEditorState.of(context);
    return Positioned.fill(
      top: state.size.top - thickness,
      child: PositionedResizeLine(
        onOffsetChanged: (offset) {
          this.offset = offset.dy;
          state.onLineChanged(this);
        },
        child: _HorizontalDivider(),
      ),
    );
  }

  @override
  EdgeInsets modifySize(EdgeInsets size) => size.copyWith(top: offset);
}

class BottomVerticalResizeLineData extends ResizeLineData {
  @override
  Widget build(BuildContext context) {
    BoundsEditorState state = BoundsEditorState.of(context);
    return Positioned.fill(
      top: state.parentSize.height - state.size.bottom,
      child: PositionedResizeLine(
        onOffsetChanged: (offset) {
          this.offset = state.parentSize.height - offset.dy;
          state.onLineChanged(this);
        },
        child: _HorizontalDivider(),
      ),
    );
  }

  @override
  EdgeInsets modifySize(EdgeInsets size) => size.copyWith(bottom: offset);
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const _Divider(
      cursor: SystemMouseCursors.resizeColumn,
      width: thickness,
      height: double.infinity,
    );
  }
}

class _HorizontalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const _Divider(
      cursor: SystemMouseCursors.resizeRow,
      height: thickness,
      width: double.infinity,
    );
  }
}

class _Divider extends StatelessWidget {
  final MouseCursor cursor;
  final double width;
  final double height;

  const _Divider({
    required this.cursor,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: cursor,
      child: SizedBox(
        height: height,
        width: width,
        child: ColoredBox(
          color: Colors.red.withOpacity(0.5),
        ),
      ),
    );
  }
}

class PositionedResizeLine extends StatelessWidget {
  final void Function(Offset offset) onOffsetChanged;
  final Widget child;

  const PositionedResizeLine({
    required this.onOffsetChanged,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // return Align(
    //   alignment: Alignment.topLeft,
    //   child: GestureDetector(
    //     // onTap: () {
    //     //   print("ontap");
    //     // },
    //     dragStartBehavior: DragStartBehavior.down,
    //     onPanUpdate: (details) {
    //       BoundsEditorState state = BoundsEditorState.of(context);
    //       Offset offset = state.renderBox.globalToLocal(details.globalPosition);
    //       onOffsetChanged(offset);
    //     },
    //     onPanEnd: (details) {
    //       BoundsEditorState state = BoundsEditorState.of(context);
    //       state.submitActiveLine();
    //     },
    //     child: child,
    //   ),
    // );
    return Align(
      alignment: Alignment.topLeft,
      child: LongPressAndDefaultDraggable(
        feedback: const SizedBox.shrink(),
        data: "nothing",
        onDragUpdate: (details) {
          BoundsEditorState state = BoundsEditorState.of(context);
          Offset offset = state.renderBox.globalToLocal(details.globalPosition);
          onOffsetChanged(offset);
        },
        onDragEnd: (details) {
          BoundsEditorState state = BoundsEditorState.of(context);
          state.submitActiveLine();
        },
        childWhenDragging: DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: kElevationToShadow[8],
          ),
          child: child,
        ),
        child: child,
      ),
    );
  }
}

class LongPressAndDefaultDraggable<T extends Object> extends StatelessWidget {
  final T? data;
  final Widget child;
  final Widget feedback;
  final DragEndCallback? onDragEnd;
  final DragUpdateCallback? onDragUpdate;
  final Widget? childWhenDragging;

  const LongPressAndDefaultDraggable({
    super.key,
    this.data,
    required this.child,
    required this.feedback,
    this.onDragEnd,
    this.onDragUpdate,
    this.childWhenDragging,
  });

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<T>(
      data: data,
      feedback: feedback,
      onDragEnd: onDragEnd,
      onDragUpdate: onDragUpdate,
      childWhenDragging: childWhenDragging,
      child: Draggable(
        data: data,
        feedback: feedback,
        onDragEnd: onDragEnd,
        onDragUpdate: onDragUpdate,
        childWhenDragging: childWhenDragging,
        child: child,
      ),
    );
  }
}
