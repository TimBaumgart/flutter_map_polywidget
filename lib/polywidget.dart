library polywidget;

import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';

class PolyWidget extends StatelessWidget {
  final LatLng center;
  final int widthInMeters;
  final int heightInMeters;
  final double angle;
  final Widget? child;
  final Orientation? forceOrientation;

  const PolyWidget({
    super.key,
    required this.center,
    required this.widthInMeters,
    required this.heightInMeters,
    this.angle = 0,
    this.forceOrientation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final mapState = FlutterMapState.of(context);
    Offset centerOffset = mapState.getOffsetFromOrigin(center);
    double width =
        _calcLength(mapState, center, centerOffset, widthInMeters, 90);
    double height =
        _calcLength(mapState, center, centerOffset, heightInMeters, 180);

    int turns =
        _calcSwap(width, height, mapState.rotation + angle, forceOrientation);
    double rotation = angle - (turns * 90);

    if (turns.isOdd) {
      double temp = width;
      width = height;
      height = temp;
    }

    return Transform.translate(
      offset: centerOffset.translate(-width / 2, -height / 2),
      child: Transform.rotate(
        angle: degToRadian(rotation),
        child: SizedBox(
          width: width,
          height: height,
          child: child,
        ),
      ),
    );
  }

  double _calcLength(FlutterMapState mapState, LatLng center,
      Offset centerOffset, int widthInMeters, int angleRad) {
    LatLng latLng = const Distance().offset(center, widthInMeters, angleRad);
    Offset offset = mapState.getOffsetFromOrigin(latLng);
    double width =
        Offset(offset.dx - centerOffset.dx, offset.dy - centerOffset.dy)
            .distance;
    return width;
  }

  factory PolyWidget.threePoints({
    required LatLng pointA,
    required LatLng pointB,
    required LatLng approxPointC,
    required Widget child,
    Orientation? forceOrientation,
  }) {
    double width = const Distance().distance(pointA, pointB);
    double height = const Distance().distance(pointB, approxPointC);
    double xAngle = const Distance().bearing(pointA, pointB);
    LatLng centerLine = const Distance().offset(pointA, width / 2, xAngle);

    double yAngle = const Distance().bearing(pointB, approxPointC);
    double cDirection = ((yAngle - xAngle) % 360);
    double cDirectionAngle = cDirection >= 0 && cDirection < 180 ? 90 : -90;
    LatLng center = const Distance()
        .offset(centerLine, height / 2, xAngle + cDirectionAngle);
    return PolyWidget(
      center: center,
      widthInMeters: width.toInt(),
      heightInMeters: height.toInt(),
      angle: xAngle - 90,
      forceOrientation: forceOrientation,
      child: child,
    );
  }

  double _calcTurns(double rotation) {
    return (rotation % 360) / 90;
  }

  int _calcSwap(double width, double height, double rotation,
      Orientation? forceOrientation) {
    double turns = _calcTurns(rotation);
    if (turns.round().isOdd) {
      double temp = width;
      width = height;
      height = temp;
    }

    return _calcExactTurns(width, height, turns, forceOrientation);
  }

  int _calcExactTurns(double width, double height, double turns,
      Orientation? forceOrientation) {
    if (forceOrientation != null) {
      if (forceOrientation == Orientation.landscape) {
        if (height > width) {
          return (turns / 2).round() * 2;
        }
      }

      if (forceOrientation == Orientation.portrait) {
        if (width > height) {
          return (((turns + 1) / 2).round() * 2) - 1;
        }
      }
    }

    return turns.round();
  }
}
