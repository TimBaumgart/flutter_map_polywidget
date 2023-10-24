import 'package:flutter/material.dart';
import 'package:flutter_map_polywidget/flutter_map_polywidget.dart';
import 'package:flutter_map_polywidget/src/mixin.dart';
import 'package:latlong2/latlong.dart';

class PolyWidgetAngleEditor extends StatelessWidget with PolyWidgetMixin {
  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink();
    return Center(
      child: Draggable(
        data: "nothing",
        feedback: SizedBox.shrink(),
        onDragUpdate: (details) {
          LatLng latLng = offsetToLatLng(context, details.globalPosition);
          double bearing = Distance()
              .bearing(latLng, PolyWidgetState.of(context).data.center);
          PolyWidgetEditorState.of(context).onUpdateAngle(bearing);
        },
        onDragEnd: (details) {
          PolyWidgetEditorState state = PolyWidgetEditorState.of(context);
          state.onSubmitted(angle: state.angle);
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Transform.rotate(
              angle: -degToRadian(PolyWidgetEditorState.of(context).angle ??
                  PolyWidgetState.of(context).data.angle),
              child: Builder(
                builder: (context) {
                  double? angle = PolyWidgetEditorState.of(context).angle;
                  if (angle == null) {
                    return Icon(Icons.crop_rotate);
                  } else {
                    return Text("${angle.toInt()}°");
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
