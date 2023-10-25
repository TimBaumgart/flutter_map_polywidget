import 'package:flutter/material.dart';
import 'package:flutter_map_polywidget/src/editor/unprojected_editor/resize_line.dart';

class UnprojectedEditorState extends InheritedWidget {
  final RenderBox renderBox;
  final Size parentSize;
  final EdgeInsets size;
  final Function(ResizeLineData data) onLineChanged;
  final Function() submitActiveLine;

  const UnprojectedEditorState({
    super.key,
    required this.renderBox,
    required this.parentSize,
    required this.size,
    required this.onLineChanged,
    required this.submitActiveLine,
    required super.child,
  });

  @override
  bool updateShouldNotify(covariant UnprojectedEditorState oldWidget) {
    return parentSize != oldWidget.parentSize || size != oldWidget.size;
  }

  static UnprojectedEditorState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<UnprojectedEditorState>()!;
  }
}
