import 'package:flutter/material.dart';
import 'package:flutter_map_polywidget/flutter_map_polywidget.dart';

class PolyWidgetEditorLayerState extends InheritedWidget {
  final EditEditorCallback onEdit;

  const PolyWidgetEditorLayerState({
    super.key,
    required this.onEdit,
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

  void show(BuildContext context) {
    var data = PolyWidgetState.of(context).data;
    onEdit.call(data);
  }

  void hide(BuildContext context) {
    onEdit.call(null);
  }
}
