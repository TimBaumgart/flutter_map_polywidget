import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_polywidget/flutter_map_polywidget.dart';
import 'package:flutter_map_polywidget/src/editor/layer/provider.dart';

typedef MoveCallback = void Function(MapCamera camera);
typedef EditorChildBuilder = Widget Function(
    BuildContext context, EdgeInsets padding);
typedef EditEditorCallback = Function(PolyWidgetData? data);

class PolyWidgetEditorLayer extends StatelessWidget {
  final PolyWidgetEditorController? controller;
  final List<Widget> children;
  final MoveCallback? onMove;
  final EditorChildBuilder? builder;
  final Widget? centerChild;
  final Size? minCenterSize;
  final EditorZoomMode? zoomMode;

  const PolyWidgetEditorLayer({
    super.key,
    this.controller,
    required this.children,
    this.onMove,
    this.builder,
    this.centerChild,
    this.minCenterSize,
    this.zoomMode,
  });

  @override
  Widget build(BuildContext context) {
    return PolyWidgetEditorLayerProvider(
      builder: (context, data) {
        return Stack(
          children: [
            PolyWidgetLayer(
              polyWidgets: children,
            ),
            PolyWidgetEditor(
              controller: controller,
              builder: builder,
              centerChild: centerChild,
              onMove: onMove,
              zoomMode: zoomMode,
              minCenterSize: minCenterSize,
            ),
          ],
        );
      },
    );
  }
}
