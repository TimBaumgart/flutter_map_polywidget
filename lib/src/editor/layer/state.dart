import 'package:flutter/material.dart';

class PolyWidgetEditorLayerState extends InheritedWidget {
  const PolyWidgetEditorLayerState({
    super.key,
    required super.child,
  });

  @override
  bool updateShouldNotify(covariant PolyWidgetEditorLayerState oldWidget) {
    return false;
  }

  static PolyWidgetEditorLayerState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<PolyWidgetEditorLayerState>()!;
  }
}
