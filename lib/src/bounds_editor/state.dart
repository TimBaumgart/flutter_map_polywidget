import 'package:flutter/material.dart';
import 'package:flutter_map_polywidget/src/bounds_editor/resize_line.dart';

class BoundsEditorState extends InheritedWidget {
  final RenderBox renderBox;
  final Size parentSize;
  final EdgeInsets size;
  final Function(ResizeLineData data) onLineChanged;
  final Function() submitActiveLine;

  const BoundsEditorState({
    super.key,
    required this.renderBox,
    required this.parentSize,
    required this.size,
    required this.onLineChanged,
    required this.submitActiveLine,
    required super.child,
  });

  @override
  bool updateShouldNotify(covariant BoundsEditorState oldWidget) {
    return parentSize != oldWidget.parentSize || size != oldWidget.size;
  }

  static BoundsEditorState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<BoundsEditorState>()!;
  }

  Size getSize(int xIndex, int yIndex) {
    double x = getX(xIndex);
    double y = getY(yIndex);
    return Size(x, y);
  }

  double getX(int xIndex) {
    if (xIndex == 0) {
      return size.left;
    }

    if (xIndex == 2) {
      return size.right;
    }

    return parentSize.width - size.horizontal;
  }

  double getY(int yIndex) {
    if (yIndex == 0) {
      return size.top;
    }

    if (yIndex == 2) {
      return size.bottom;
    }

    return parentSize.height - size.vertical;
  }

  double getResizeLineOffset(Axis axis, int index) {
    if (axis == Axis.horizontal) {
      if (index == 0) {
        return size.left;
      }

      return parentSize.width - size.right;
    }

    if (index == 0) {
      return size.top;
    }

    return parentSize.height - size.bottom;
  }

  // void onPanUpdate(Axis axis, int index, DragUpdateDetails details) {
  //   print("onPanUpdate");
  //   Offset offset = renderBox.globalToLocal(details.globalPosition);
  //   if (axis == Axis.horizontal) {
  //     onOffsetChanged(axis, index, offset.dx);
  //   } else {
  //     onOffsetChanged(axis, index, offset.dy);
  //   }
  // }

  void onPanUpdateX(int index, Offset offset) {
    if (index == 0) {}
  }

  void onPanUpdateY(int index, Offset offset) {}
}
