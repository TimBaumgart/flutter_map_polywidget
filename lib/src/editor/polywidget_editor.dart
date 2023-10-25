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
  final Function(MapCamera camera)? onMove;

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
        return PolyWidgetEditorProvider(
          controller: controller,
          camera: MapCamera.of(context),
          onMove: onMove,
          constraints: constraints,
          minCenterSize: minCenterSize,
          builder: builder,
          centerChild: centerChild,
          zoomMode: zoomMode,
          builderX: (context, size) {
            controller.attach(context);
            return AnimatedOpacity(
              opacity: controller.active ? 1 : 0,
              duration: kThemeAnimationDuration,
              child: IgnorePointer(
                ignoring: !controller.active,
                child: UnprojectedEditor(
                  size: size,
                  minCenterSize: minCenterSize,
                  onChanged: (size) {
                    controller.updateUnprojectedSize(
                      context,
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
