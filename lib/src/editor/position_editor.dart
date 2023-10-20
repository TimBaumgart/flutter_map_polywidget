import 'package:flutter/material.dart';
import 'package:flutter_map_polywidget/src/editor/state.dart';
import 'package:flutter_map_polywidget/src/mixin.dart';
import 'package:latlong2/latlong.dart';

class PolyWidgetPositionEditor extends StatelessWidget with PolyWidgetMixin {
  Widget child;

  PolyWidgetPositionEditor({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable(
      feedback: Text("drag"),
      data: "nothing",
      onDragUpdate: (details) {
        LatLng center = offsetToLatLng(context, details.globalPosition);
        PolyWidgetEditorState.of(context).onUpdatePosition(center);
      },
      onDragEnd: (details) {
        PolyWidgetEditorState state = PolyWidgetEditorState.of(context);
        state.onSubmitted(
          center: state.center,
        );
      },
      child: child,
    );
  }
}
