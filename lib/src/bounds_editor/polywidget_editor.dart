import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_polywidget/flutter_map_polywidget.dart';

class PolyWidgetBoundsEditor extends StatelessWidget {
  final PolyWidgetData data;
  final Function(PolyWidgetData data) onChanged;
  final bool active;
  final Function()? onActivate;

  const PolyWidgetBoundsEditor({
    super.key,
    required this.data,
    required this.onChanged,
    this.active = true,
    this.onActivate,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return PolyWidgetBoundsEditorProvider(
          camera: MapCamera.of(context),
          data: data,
          active: active,
          onActivate: onActivate,
          constraints: constraints,
          onChanged: onChanged,
          builder: (context, size) {
            return BoundsEditor(
              size: size,
              onChanged: (size) {
                onChanged.call(
                  PolyWidgetBoundsEditorState.of(context).toProjected(
                    context,
                    constraints,
                    size,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
