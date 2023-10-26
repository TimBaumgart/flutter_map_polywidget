import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_polywidget/flutter_map_polywidget.dart';

typedef ActivateEditorCallback = Function(MapCamera camera);

class PolyWidgetEditor extends StatelessWidget {
  final PolyWidgetEditorController controller;
  final EditorChildBuilder? builder;
  final Widget? centerChild;
  final Size minCenterSize;
  final EditorZoomMode? zoomMode;
  final MoveCallback? onMove;

  PolyWidgetEditor({
    super.key,
    PolyWidgetEditorController? controller,
    this.builder,
    this.centerChild,
    Size? minCenterSize,
    this.zoomMode,
    this.onMove,
  })  : controller = controller ?? PolyWidgetEditorController(),
        minCenterSize = minCenterSize ?? Size.zero;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        MapCamera camera = MapCamera.of(context);
        return PolyWidgetEditorProvider(
          controller: controller,
          camera: camera,
          onMove: onMove,
          constraints: constraints,
          zoomMode: zoomMode,
          builder: (context, size, rotation) {
            controller.attach(context);
            return AnimatedOpacity(
              opacity: controller.active ? 1 : 0,
              duration: kThemeAnimationDuration,
              child: IgnorePointer(
                ignoring: !controller.active,
                child: UnprojectedEditor(
                  size: size,
                  rotation: rotation,
                  minCenterSize: minCenterSize,
                  onChanged: (size) {
                    controller.updateUnprojectedSize(
                      context,
                      camera,
                      constraints,
                      size,
                    );
                  },
                  builder: builder,
                  centerChild: centerChild,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
