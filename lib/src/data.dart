import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class PolyWidgetData {
  final LatLng center;
  final num widthInMeters;
  final num heightInMeters;
  final num angle;

  PolyWidgetData({
    required this.center,
    required this.widthInMeters,
    required this.heightInMeters,
    required this.angle,
  });

  PolyWidgetScreenData convert({
    required BuildContext context,
    required bool mobileLayer,
    Orientation? forceOrientation,
    bool noRotation = false,
  }) {
    final mapCamera = MapCamera.of(context);
    return convertForCamera(
      mapCamera: mapCamera,
      mobileLayer: mobileLayer,
      forceOrientation: forceOrientation,
      noRotation: noRotation,
    );
  }

  PolyWidgetScreenData convertForCamera({
    required MapCamera mapCamera,
    required bool mobileLayer,
    Orientation? forceOrientation,
    bool noRotation = false,
  }) {
    Offset centerOffset = mobileLayer
        ? mapCamera.getOffsetFromOrigin(center)
        : mapCamera.latLngToScreenPoint(center).toOffset();
    double width = _calcLength(
        mapCamera, mobileLayer, center, centerOffset, widthInMeters, 90);
    double height = _calcLength(
        mapCamera, mobileLayer, center, centerOffset, heightInMeters, 180);

    int turns = _calcTurns(width, height, mapCamera.rotation + angle,
        forceOrientation, noRotation);
    double rotation = angle - (turns * 90);

    if (turns.isOdd) {
      double temp = width;
      width = height;
      height = temp;
    }

    Offset offset = centerOffset.translate(-width / 2, -height / 2);

    return PolyWidgetScreenData(
      left: offset.dx,
      top: offset.dy,
      width: width,
      height: height,
      rotation: rotation,
    );
  }

  /// calculates the current screen distance for [lengthInMeters]
  double _calcLength(
    MapCamera mapCamera,
    bool mobileLayer,
    LatLng center,
    Offset centerOffset,
    num lengthInMeters,
    num angle,
  ) {
    LatLng latLng = const Distance().offset(center, lengthInMeters, angle);
    Offset offset = mobileLayer
        ? mapCamera.getOffsetFromOrigin(latLng)
        : mapCamera.latLngToScreenPoint(latLng).toOffset();
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

  PolyWidgetData copyWith(
      {LatLng? center,
      int? widthInMeters,
      int? heightInMeters,
      double? angle}) {
    return PolyWidgetData(
      center: center ?? this.center,
      widthInMeters: widthInMeters ?? this.widthInMeters,
      heightInMeters: heightInMeters ?? this.heightInMeters,
      angle: angle ?? this.angle,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PolyWidgetData &&
          runtimeType == other.runtimeType &&
          center == other.center &&
          widthInMeters == other.widthInMeters &&
          heightInMeters == other.heightInMeters &&
          angle == other.angle;

  @override
  int get hashCode =>
      center.hashCode ^
      widthInMeters.hashCode ^
      heightInMeters.hashCode ^
      angle.hashCode;

  List<LatLng> calcOutlineCoordinates() {
    num angle = this.angle;
    const distance = Distance();
    LatLng east = distance.offset(center, heightInMeters / 2, angle);
    LatLng northEast = distance.offset(east, widthInMeters / 2, angle - 90);
    LatLng southEast = distance.offset(northEast, widthInMeters, angle + 90);
    LatLng southWest = distance.offset(southEast, heightInMeters, angle + 180);
    LatLng northWest = distance.offset(southWest, widthInMeters, angle + 270);
    return [northEast, southEast, southWest, northWest];
  }

  double? calcRotationDiff(MapCamera camera) {
    return angle - -camera.rotation;
  }
}

class PolyWidgetScreenData {
  final double left;
  final double top;
  final double width;
  final double height;
  final double rotation;

  PolyWidgetScreenData({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.rotation,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PolyWidgetScreenData &&
          runtimeType == other.runtimeType &&
          left == other.left &&
          top == other.top &&
          width == other.width &&
          height == other.height &&
          rotation == other.rotation;

  @override
  int get hashCode =>
      left.hashCode ^
      top.hashCode ^
      width.hashCode ^
      height.hashCode ^
      rotation.hashCode;

  PolyWidgetData convert(BuildContext context, MapCamera camera) {
    LatLng topLeft = camera.offsetToCrs(Offset(left, top));
    LatLng topRight = camera.offsetToCrs(Offset(left + width, top));
    LatLng bottomLeft = camera.offsetToCrs(Offset(left, top + height));
    LatLng center =
        camera.offsetToCrs(Offset(left + (width / 2), top + (height / 2)));
    return PolyWidgetData(
      center: center,
      widthInMeters: const Distance().distance(topLeft, topRight),
      heightInMeters: const Distance().distance(topLeft, bottomLeft),
      angle: rotation,
    );
  }
}
