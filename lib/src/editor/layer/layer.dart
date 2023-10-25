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

  const PolyWidgetEditorLayer({
    super.key,
    this.controller,
    required this.children,
    this.onMove,
    this.builder,
    this.centerChild,
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
            PolyWidgetBoundsEditor(
              controller: controller,
              builder: builder,
              centerChild: centerChild,
              data: data,
              active: data != null,
              onMove: onMove,
            ),
          ],
        );
      },
    );
  }
}
