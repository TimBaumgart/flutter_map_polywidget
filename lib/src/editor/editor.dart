import 'package:flutter/material.dart';
import 'package:flutter_map_polywidget/flutter_map_polywidget.dart';
import 'package:flutter_map_polywidget/src/editor/angle_editor.dart';
import 'package:flutter_map_polywidget/src/editor/position_editor.dart';
import 'package:flutter_map_polywidget/src/editor/size_editor.dart';
import 'package:flutter_map_polywidget/src/editor/state.dart';
import 'package:latlong2/latlong.dart';

class PolyWidgetEditor extends StatelessWidget {
  final Widget child;
  final LatLng center;
  final int widthInMeters;
  final int heightInMeters;
  final double angle;
  final Future<void> Function({
    LatLng? center,
    int? widthInMeters,
    int? heightInMeters,
    double? angle,
  }) onSubmitted;

  const PolyWidgetEditor({
    required this.child,
    required this.center,
    required this.widthInMeters,
    required this.heightInMeters,
    required this.angle,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return PolyWidgetEditorStateProvider(
      onSubmitted: onSubmitted,
      child: Builder(builder: (context) {
        PolyWidgetEditorState state = PolyWidgetEditorState.of(context);
        return PolyWidget(
          center: state.center ?? center,
          widthInMeters: widthInMeters,
          heightInMeters: heightInMeters,
          angle: state.angle ?? angle,
          expand: state.expand ?? EdgeInsets.zero,
          noRotation: true,
          constraints: const BoxConstraints(
            minWidth: 100,
            minHeight: 100,
          ),
          child: PolyWidgetPositionEditor(
            child: Stack(
              children: [
                Positioned.fill(child: child),
                PolyWidgetSizeEditor(),
                PolyWidgetAngleEditor(),
              ],
            ),
          ),
        );
      }),
    );
  }
}
