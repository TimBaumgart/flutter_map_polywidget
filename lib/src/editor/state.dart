import 'package:flutter/material.dart';
import 'package:flutter_map_polywidget/flutter_map_polywidget.dart';

typedef SubmitCallback = PolyWidgetData Function();

class PolyWidgetEditorState extends InheritedWidget {
  final SubmitCallback onSubmit;

  const PolyWidgetEditorState({
    super.key,
    required this.onSubmit,
    required super.child,
  });

  static PolyWidgetEditorState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PolyWidgetEditorState>()!;
  }

  @override
  bool updateShouldNotify(covariant PolyWidgetEditorState oldWidget) {
    return false;
  }
}
