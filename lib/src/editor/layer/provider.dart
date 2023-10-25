import 'package:flutter/material.dart';
import 'package:flutter_map_polywidget/flutter_map_polywidget.dart';

class PolyWidgetEditorLayerProvider extends StatefulWidget {
  final Widget Function(BuildContext context, PolyWidgetData? data) builder;

  const PolyWidgetEditorLayerProvider({
    required this.builder,
    super.key,
  });

  @override
  State<PolyWidgetEditorLayerProvider> createState() =>
      _PolyWidgetEditorLayerProviderState();
}

class _PolyWidgetEditorLayerProviderState
    extends State<PolyWidgetEditorLayerProvider> {
  PolyWidgetData? data;

  @override
  Widget build(BuildContext context) {
    return PolyWidgetEditorLayerState(
      child: Builder(builder: (context) {
        return widget.builder.call(context, data);
      }),
    );
  }
}
