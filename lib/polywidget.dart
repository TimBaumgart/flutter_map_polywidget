library polywidget;

import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';

/// poly widget defined by center, width, height and angle
///
/// should always be added inside PolyWidgetLayer.polyWidgets
class PolyWidget extends StatelessWidget {
  final LatLng center;
  final int widthInMeters;
  final int heightInMeters;
  final double angle;
  final Widget? child;
  final Orientation? forceOrientation;
  final bool noRotation;
  final BoxConstraints? constraints;

  const PolyWidget({
    super.key,
    required this.center,
    required this.widthInMeters,
    required this.heightInMeters,
    this.angle = 0,
    this.forceOrientation,
    bool? noRotation,
    this.constraints,
    required this.child,
  }) : noRotation = noRotation ?? false;

  @override
  Widget build(BuildContext context) {
    final mapState = FlutterMapState.of(context);
    Offset centerOffset = mapState.getOffsetFromOrigin(center);
    double width =
        _calcLength(mapState, center, centerOffset, widthInMeters, 90);
    double height =
        _calcLength(mapState, center, centerOffset, heightInMeters, 180);

    int turns = _calcTurns(
        width, height, mapState.rotation + angle, forceOrientation, noRotation);
    double rotation = angle - (turns * 90);

    if (turns.isOdd) {
      double temp = width;
      width = height;
      height = temp;
    }

    Offset offset = centerOffset.translate(-width / 2, -height / 2);

    return Positioned(
      left: offset.dx,
      top: offset.dy,
      width: width,
      height: height,
      child: Transform.rotate(
        angle: degToRadian(rotation),
        child: Builder(builder: (context) {
          if (constraints != null) {
            return _ConstrainedPolyWidgetContent(
              width: width,
              height: height,
              constraints: constraints!,
              child: child,
            );
          }

          return SizedBox(
            width: width,
            height: height,
            child: child,
          );
        }),
      ),
    );
  }

  /// poly widget defined by three points
  ///
  /// should always be added inside PolyWidgetLayer.polyWidgets
  ///
  /// [pointA] and [pointB] are fixed and will be used to define the width and angle of your widget. [approxPointC] is only fixed
  // if it is placed in a 90° angle from [pointB]. Otherwise the distance from [pointB] to [approxPointC] is used to calculate the actual third corner. All three corners are used to calculate
  // the center location.
  factory PolyWidget.threePoints({
    required LatLng pointA,
    required LatLng pointB,
    required LatLng approxPointC,
    required Widget child,
    Orientation? forceOrientation,
    bool? noRotation,
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
      noRotation: noRotation,
      child: child,
    );
  }

  /// calculates the current screen distance for [lengthInMeters]
  double _calcLength(
    FlutterMapState mapState,
    LatLng center,
    Offset centerOffset,
    int lengthInMeters,
    int angle,
  ) {
    LatLng latLng = const Distance().offset(center, lengthInMeters, angle);
    Offset offset = mapState.getOffsetFromOrigin(latLng);
    double width =
        Offset(offset.dx - centerOffset.dx, offset.dy - centerOffset.dy)
            .distance;
    return width;
  }

  /// calculates how much 90° turns are necessary to rotate the widget the desired way
  int _calcTurns(
    double width,
    double height,
    double rotation,
    Orientation? forceOrientation,
    bool noRotation,
  ) {
    if (noRotation) {
      return 0;
    }

    double turns = (rotation % 360) / 90;
    if (turns.round().isOdd) {
      double temp = width;
      width = height;
      height = temp;
    }

    return _calcExactTurns(width, height, turns, forceOrientation);
  }

  /// calculates turns and takes the given [forceOrientation] value in account
  int _calcExactTurns(
    double width,
    double height,
    double turns,
    Orientation? forceOrientation,
  ) {
    int rounded = turns.round();

    if (forceOrientation != null) {
      if (forceOrientation == Orientation.landscape) {
        if (height > width) {
          return rounded + (turns < rounded ? -1 : 1);
        }
      }

      if (forceOrientation == Orientation.portrait) {
        if (width > height) {
          return rounded + (turns < rounded ? -1 : 1);
        }
      }
    }

    return turns.round();
  }
}

/// polywidget that sizes itself to the given constraints
class _ConstrainedPolyWidgetContent extends StatelessWidget {
  final double width;
  final double height;
  final BoxConstraints constraints;
  final Widget? child;

  const _ConstrainedPolyWidgetContent({
    required this.width,
    required this.height,
    required this.constraints,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    Size size = Size(width, height);
    if (!constraints.isSatisfiedBy(size)) {
      Size constrainedSize =
          constraints.constrainSizeAndAttemptToPreserveAspectRatio(size);
      return SizedBox.fromSize(
        size: size,
        child: FittedBox(
          child: SizedBox.fromSize(
            size: constrainedSize,
            child: child,
          ),
        ),
      );
    }

    return SizedBox.fromSize(
      size: size,
      child: child,
    );
  }
}
