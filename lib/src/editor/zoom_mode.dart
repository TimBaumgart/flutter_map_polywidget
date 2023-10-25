import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_polywidget/flutter_map_polywidget.dart';

enum EditorZoomMode { fixed, real }

extension EditorZoomModeExtension on EditorZoomMode {
  MapCamera transform(
      MapCamera camera, PolyWidgetData data, BoxConstraints constraints) {
    switch (this) {
      case EditorZoomMode.fixed:
        var fit = CameraFit.coordinates(
          coordinates: data.calcOutlineCoordinates(),
          padding:
              EdgeInsets.all((constraints.biggest.shortestSide * 0.3827) / 2),
        );

        var desiredCamera = fit.fit(camera.withRotation(-data.angle));
        return desiredCamera;
      case EditorZoomMode.real:
        return camera
            .withPosition(center: data.center)
            .withRotation(-data.angle);
    }
  }
}
