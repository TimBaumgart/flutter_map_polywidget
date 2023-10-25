import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_polywidget/flutter_map_polywidget.dart';

class PolyWidgetEditorProvider extends StatefulWidget {
  final PolyWidgetEditorController controller;
  final MapCamera camera;
  final BoxConstraints constraints;
  final Size minCenterSize;
  final EditorChildBuilder? builder;
  final Widget? centerChild;
  final EditorZoomMode zoomMode;
  final Function(MapCamera camera)? onMove;
  final Function(BuildContext context, EdgeInsets size) builderX;

  const PolyWidgetEditorProvider({
    super.key,
    required this.controller,
    required this.camera,
    required this.constraints,
    required this.minCenterSize,
    required this.builder,
    this.centerChild,
    required this.onMove,
    EditorZoomMode? zoomMode,
    required this.builderX,
  }) : zoomMode = zoomMode ?? EditorZoomMode.real;

  @override
  State<PolyWidgetEditorProvider> createState() =>
      _PolyWidgetEditorProviderState();
}

class _PolyWidgetEditorProviderState extends State<PolyWidgetEditorProvider> {
  bool active = false;
  EdgeInsets size = EdgeInsets.zero;

  @override
  void initState() {
    super.initState();
    _updateSize();
    _updateActive();
    widget.controller.addListener(() {
      setState(() {
        _updateSize();
        _updateActive();
      });
    });
  }

  @override
  void didUpdateWidget(covariant PolyWidgetEditorProvider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.controller.active) {
      return;
    }

    bool constraintsChanged = oldWidget.constraints != widget.constraints;
    if (constraintsChanged) {
      _updateSize();
    }

    var camera = widget.camera;
    if (camera.zoom != oldWidget.camera.zoom &&
        widget.zoomMode.updateSizeOnZoom()) {
      // var data = widget.controller.data;
      // if (camera.center != data?.center) {
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   MapController.of(context).move(data!.center, camera.zoom);
      // });
      // }
      _updateSize();
    }

    if (camera != oldWidget.camera) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.controller.updateOutputData(
            widget.controller.toProjected(context, widget.constraints, size));
      });
    }
  }

  void _updateSize({PolyWidgetData? customData}) {
    PolyWidgetData? data = customData ?? widget.controller.data;
    if (data == null) {
      return;
    }

    var camera = widget.camera;
    camera = widget.zoomMode.transform(camera, data, widget.constraints);

    size = toUnprojected(
      camera.withRotation(0),
      widget.constraints,
      data,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PolyWidgetEditorState(
      onSubmit: () =>
          widget.controller.toProjected(context, widget.constraints, size),
      child: Builder(
        builder: (context) {
          return widget.builderX.call(context, size);
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

  void _updateActive() {
    if (active != widget.controller.active) {
      if (!active) {
        PolyWidgetData data = widget.controller.data!;
        var camera = widget.camera;
        camera = widget.zoomMode.transform(camera, data, widget.constraints);
        _onActivate(
          camera,
        );
      }
      setState(() {
        active = widget.controller.active;
      });
    }
  }
}
