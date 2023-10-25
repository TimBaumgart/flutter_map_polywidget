import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map_polywidget/src/editor/unprojected_editor/draggable.dart';
import 'package:flutter_map_polywidget/src/editor/unprojected_editor/state.dart';

const double thickness = 8;
const double thicknessOffset = thickness / 2;
const double visibleThickness = 1;

abstract class ResizeLineData {
  double offset;

  ResizeLineData({this.offset = 0});

  EdgeInsets modifySize(EdgeInsets size, Size parentSize, Size minCenterSize);

  Widget build(BuildContext context);
}

class LeftHorizontalResizeLineData extends ResizeLineData {
  @override
  Widget build(BuildContext context) {
    UnprojectedEditorState state = UnprojectedEditorState.of(context);
    return Positioned.fill(
      left: state.size.left - thicknessOffset,
      child: PositionedResizeLine(
        offset: const Offset(-thicknessOffset, 0),
        onOffsetChanged: (offset) {
          this.offset = offset.dx;
          state.onLineChanged(this);
        },
        child: _VerticalDivider(),
      ),
    );
  }

  @override
  EdgeInsets modifySize(EdgeInsets size, Size parentSize, Size minCenterSize) =>
      size.copyWith(
        left: min(
          offset,
          parentSize.width - minCenterSize.width - size.right,
        ),
      );
}

class RightHorizontalResizeLineData extends ResizeLineData {
  @override
  Widget build(BuildContext context) {
    UnprojectedEditorState state = UnprojectedEditorState.of(context);
    return Positioned.fill(
      left: state.parentSize.width - state.size.right - thicknessOffset,
      child: PositionedResizeLine(
        offset: const Offset(-thicknessOffset, 0),
        onOffsetChanged: (offset) {
          this.offset = state.parentSize.width - offset.dx;
          state.onLineChanged(this);
        },
        child: _VerticalDivider(),
      ),
    );
  }

  @override
  EdgeInsets modifySize(EdgeInsets size, Size parentSize, Size minCenterSize) =>
      size.copyWith(
        right: min(
          offset,
          parentSize.width - minCenterSize.width - size.left,
        ),
      );
}

class TopVerticalResizeLineData extends ResizeLineData {
  @override
  Widget build(BuildContext context) {
    UnprojectedEditorState state = UnprojectedEditorState.of(context);
    return Positioned.fill(
      top: state.size.top - thicknessOffset,
      child: PositionedResizeLine(
        offset: const Offset(0, -thicknessOffset),
        onOffsetChanged: (offset) {
          this.offset = offset.dy;
          state.onLineChanged(this);
        },
        child: _HorizontalDivider(),
      ),
    );
  }

  @override
  EdgeInsets modifySize(EdgeInsets size, Size parentSize, Size minCenterSize) =>
      size.copyWith(
        top: min(
          offset,
          parentSize.height - minCenterSize.height - size.bottom,
        ),
      );
}

class BottomVerticalResizeLineData extends ResizeLineData {
  @override
  Widget build(BuildContext context) {
    UnprojectedEditorState state = UnprojectedEditorState.of(context);
    return Positioned.fill(
      top: state.parentSize.height - state.size.bottom - thicknessOffset,
      child: PositionedResizeLine(
        offset: const Offset(0, -thicknessOffset),
        onOffsetChanged: (offset) {
          this.offset = state.parentSize.height - offset.dy;
          state.onLineChanged(this);
        },
        child: _HorizontalDivider(),
      ),
    );
  }

  @override
  EdgeInsets modifySize(EdgeInsets size, Size parentSize, Size minCenterSize) =>
      size.copyWith(
        bottom: min(
          offset,
          parentSize.height - minCenterSize.height - size.top,
        ),
      );
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
        child: Center(
          child: SizedBox(
            width: width.isInfinite ? width : visibleThickness,
            height: height.isInfinite ? height : visibleThickness,
            child: ColoredBox(
              color: Theme.of(context).dividerColor.withOpacity(1),
            ),
          ),
        ),
      ),
    );
  }
}

class PositionedResizeLine extends StatelessWidget {
  final Offset offset;
  final void Function(Offset offset) onOffsetChanged;
  final Widget child;

  const PositionedResizeLine({
    super.key,
    this.offset = Offset.zero,
    required this.onOffsetChanged,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: MyDraggable(
        feedback: const SizedBox.shrink(),
        data: "nothing",
        onDragUpdate: (details) {
          UnprojectedEditorState state = UnprojectedEditorState.of(context);
          Offset offset =
              state.renderBox.globalToLocal(details.globalPosition) -
                  this.offset;
          onOffsetChanged(offset);
        },
        onDragEnd: (details) {
          UnprojectedEditorState state = UnprojectedEditorState.of(context);
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
