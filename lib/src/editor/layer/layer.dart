import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_polywidget/flutter_map_polywidget.dart';

typedef MoveCallback = Future<void> Function(MapCamera camera);
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
  final bool? resizeable;
  final bool? rotateable;

  const PolyWidgetEditorLayer({
    super.key,
    this.controller,
    required this.children,
    this.onMove,
    this.builder,
    this.centerChild,
    this.minCenterSize,
    this.zoomMode,
    this.resizeable,
    this.rotateable,
  });

  @override
  Widget build(BuildContext context) {
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
          resizeable: resizeable,
          rotateable: rotateable,
        ),
      ],
    );
  }
}
