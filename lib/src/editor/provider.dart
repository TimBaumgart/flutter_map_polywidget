import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_polywidget/flutter_map_polywidget.dart';

class PolyWidgetEditorProvider extends StatefulWidget {
  final PolyWidgetEditorController controller;
  final MapCamera camera;
  final PolyWidgetData? data;
  final BoxConstraints constraints;
  final Size minCenterSize;
  final EditorChildBuilder? builder;
  final Widget? centerChild;
  final EditorZoomMode zoomMode;
  final Function(MapCamera camera)? onMove;
  final bool active;

  PolyWidgetEditorProvider({
    super.key,
    PolyWidgetEditorController? controller,
    required this.camera,
    required this.data,
    required this.constraints,
    required this.minCenterSize,
    required this.builder,
    this.centerChild,
    required this.onMove,
    required this.active,
    EditorZoomMode? zoomMode,
  })  : zoomMode = zoomMode ?? EditorZoomMode.real,
        controller = controller ?? PolyWidgetEditorController();

  @override
  State<PolyWidgetEditorProvider> createState() =>
      _PolyWidgetEditorProviderState();
}

class _PolyWidgetEditorProviderState extends State<PolyWidgetEditorProvider> {
  late EdgeInsets size;

  @override
  void initState() {
    super.initState();
    _initSize();
  }

  @override
  void didUpdateWidget(covariant PolyWidgetEditorProvider oldWidget) {
    super.didUpdateWidget(oldWidget);
    PolyWidgetData? data = widget.data;
    if (widget.active && data != null) {
      bool justActivated = !oldWidget.active && widget.active;
      bool somethingChanged =
          oldWidget.constraints != widget.constraints || oldWidget.data != data;
      if (justActivated || somethingChanged) {
        MapCamera? desiredCamera;
        if (justActivated) {
          desiredCamera = widget.zoomMode
              .transform(MapCamera.of(context), data, widget.constraints);
          _onActivate(desiredCamera);
        }
        _initSize(customCamera: desiredCamera);
        return;
      }

      if (widget.zoomMode == EditorZoomMode.real &&
          widget.camera != oldWidget.camera) {
        _initSize(
          customCamera: widget.camera.withPosition(center: data.center),
        );
      }
    }
  }

  void _initSize({MapCamera? customCamera, PolyWidgetData? customData}) {
    MapCamera camera = customCamera ?? widget.camera;
    PolyWidgetData? data = customData ?? widget.data;

    widget.controller.updateData(data);

    if (data == null) {
      size = EdgeInsets.zero;
      return;
    }

    size = toUnprojected(
      camera.withRotation(0),
      widget.constraints,
      data,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PolyWidgetEditorState(
      onActivate: () {
        setState(() {
          _initSize();
        });
      },
      onSave: () {
        return toProjected(context, widget.constraints, size);
      },
      updateData: ({int? width, int? height, double? angle}) {
        setState(() {
          _initSize(
            customData: widget.data?.copyWith(
              heightInMeters: height,
              widthInMeters: width,
              angle: angle,
            ),
          );
        });
        if (angle != null) {
          MapCamera camera = widget.camera.withRotation(-angle);
          if (widget.onMove != null) {
            widget.onMove!.call(camera);
          } else {
            MapController.of(context).moveAndRotate(
              camera.center,
              camera.zoom,
              camera.rotation,
            );
          }
        }
      },
      child: Builder(
        builder: (context) {
          widget.controller.attach(context);
          return UnprojectedEditor(
            size: size,
            minCenterSize: widget.minCenterSize,
            onChanged: (size) {
              this.size = size;
              widget.controller
                  .updateData(toProjected(context, widget.constraints, size));
            },
            builder: widget.builder,
            centerChild: widget.centerChild,
          );
        },
      ),
    );
  }

  EdgeInsets toUnprojected(
      MapCamera camera, BoxConstraints constraints, PolyWidgetData data) {
    PolyWidgetScreenData convert = data.convertFromCamera(camera, null, true);
    return EdgeInsets.fromLTRB(
      convert.left,
      convert.top,
      constraints.maxWidth - (convert.left + convert.width),
      constraints.maxHeight - (convert.top + convert.height),
    );
  }

  PolyWidgetData toProjected(
      BuildContext context, BoxConstraints constraints, EdgeInsets size) {
    MapCamera camera = MapCamera.of(context);
    PolyWidgetScreenData polyWidgetScreenData = PolyWidgetScreenData(
      left: size.left,
      top: size.top,
      width: constraints.maxWidth - size.horizontal,
      height: constraints.maxHeight - size.vertical,
      rotation: -camera.rotation,
    );
    return polyWidgetScreenData.convert(context);
  }

  void _onActivate(MapCamera camera) {
    if (widget.onMove != null) {
      widget.onMove!.call(camera);
    } else {
      MapController.of(context).moveAndRotate(
        camera.center,
        camera.zoom,
        camera.rotation,
      );
    }
  }
}
