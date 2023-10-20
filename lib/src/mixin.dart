import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_polywidget/flutter_map_polywidget.dart';
import 'package:latlong2/latlong.dart';

mixin PolyWidgetMixin {
  LatLng offsetToLatLng(BuildContext context, Offset globalPosition) {
    RenderBox renderBox = PolyWidgetLayerState.of(context)
        .parentContext
        .findRenderObject() as RenderBox;
    Offset offset = renderBox.globalToLocal(globalPosition);
    LatLng center = MapCamera.of(context).withRotation(0).offsetToCrs(offset);
    return center;
  }
}
