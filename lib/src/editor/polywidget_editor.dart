import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_polywidget/flutter_map_polywidget.dart';

typedef ActivateEditorCallback = Function(MapCamera camera);

class PolyWidgetBoundsEditor extends StatelessWidget {
  final PolyWidgetEditorController? controller;
  final PolyWidgetData? data;
  final bool active;
  final EditorChildBuilder? builder;
  final Widget? centerChild;
  final Size minCenterSize;
  final EditorZoomMode? zoomMode;
  final Function(MapCamera camera)? onMove;

  const PolyWidgetBoundsEditor({
    super.key,
    this.controller,
    this.data,
    this.active = true,
    this.builder,
    this.centerChild,
    this.minCenterSize = Size.zero,
    this.zoomMode,
    this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: active ? 1 : 0,
      duration: kThemeAnimationDuration,
      child: IgnorePointer(
        ignoring: !active,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return PolyWidgetEditorProvider(
              controller: controller,
              camera: MapCamera.of(context),
              data: data,
              active: active,
              onMove: onMove,
              constraints: constraints,
              minCenterSize: minCenterSize,
              builder: builder,
              centerChild: centerChild,
              zoomMode: zoomMode,
            );
          },
        ),
      ),
    );
  }
}
