import 'package:flutter/cupertino.dart';
import 'package:latlong2/latlong.dart';

class PolyWidgetState extends InheritedWidget {
  final BuildContext parentContext;
  final PolyWidgetScreenData screenData;
  final PolyWidgetData data;

  const PolyWidgetState({
    required this.parentContext,
    required this.data,
    required this.screenData,
    required super.child,
    super.key,
  });

  @override
  bool updateShouldNotify(covariant PolyWidgetState oldWidget) {
    return data != oldWidget.data;
  }

  static PolyWidgetState? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PolyWidgetState>();
  }

  static PolyWidgetState of(BuildContext context) {
    return maybeOf(context)!;
  }
}

class PolyWidgetData {
  final LatLng center;
  final int widthInMeters;
  final int heightInMeters;
  final double angle;

  PolyWidgetData({
    required this.center,
    required this.widthInMeters,
    required this.heightInMeters,
    required this.angle,
  });
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
}
