library polywidget;

import 'package:flutter/material.dart';
import 'package:flutter_map_polywidget/src/data.dart';
import 'package:flutter_map_polywidget/src/state.dart';
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
  final EdgeInsets expand;

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
    this.expand = EdgeInsets.zero,
  }) : noRotation = noRotation ?? false;

  @override
  Widget build(BuildContext context) {
    PolyWidgetData data = PolyWidgetData(
      center: center,
      widthInMeters: widthInMeters,
      heightInMeters: heightInMeters,
      angle: angle,
    );
  
    PolyWidgetScreenData screenData = data.convert(
      context: context,
      mobileLayer: true,
      forceOrientation: forceOrientation,
      noRotation: noRotation,
    );

    return PolyWidgetState(
      parentContext: context,
      data: data,
      screenData: screenData,
      child: Positioned(
        left: screenData.left - expand.left,
        top: screenData.top - expand.top,
        width: screenData.width + expand.horizontal,
        height: screenData.height + expand.vertical,
        child: Transform.rotate(
          angle: degToRadian(screenData.rotation),
          child: Builder(builder: (context) {
            if (constraints != null) {
              return _ConstrainedPolyWidgetContent(
                width: screenData.width + expand.horizontal,
                height: screenData.height + expand.vertical,
                constraints: constraints!,
                child: child,
              );
            }

            return SizedBox(
              width: screenData.width,
              height: screenData.height,
              child: child,
            );
          }),
        ),
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
