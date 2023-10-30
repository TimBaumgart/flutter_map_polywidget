import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_polywidget/flutter_map_polywidget.dart';
import 'package:latlong2/latlong.dart';

class PolyWidgetEditorProvider extends StatefulWidget {
  final PolyWidgetEditorController controller;
  final MapCamera camera;
  final BoxConstraints constraints;
  final EditorZoomMode zoomMode;
  final MoveCallback? onMove;
  final Function(BuildContext context, EdgeInsets size, double? rotation)
      builder;

  const PolyWidgetEditorProvider({
    super.key,
    required this.controller,
    required this.camera,
    required this.constraints,
    required this.onMove,
    EditorZoomMode? zoomMode,
    required this.builder,
  }) : zoomMode = zoomMode ?? EditorZoomMode.real;

  @override
  State<PolyWidgetEditorProvider> createState() =>
      _PolyWidgetEditorProviderState();
}

class _PolyWidgetEditorProviderState extends State<PolyWidgetEditorProvider> {
  bool active = false;
  bool moveOnCameraChange = true;
  EdgeInsets size = EdgeInsets.zero;
  CancelableOperation<void>? cameraFuture;

  @override
  void initState() {
    super.initState();
    _updateSize();
    _updateActive();
    widget.controller.addListener(() {
      if (context.mounted) {
        setState(() {
          _updateSize();
          _updateActive();
        });
      }
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
    var updateOnZoom = camera.zoom != oldWidget.camera.zoom &&
        widget.zoomMode.updateSizeOnZoom();
    var updateOnActivationMovement =
        moveOnCameraChange && camera != oldWidget.camera;
    if (updateOnZoom || updateOnActivationMovement) {
      _updateSize();
    }

    if (camera != oldWidget.camera) {
      cameraFuture?.cancel();
      cameraFuture = CancelableOperation.fromFuture(
        Future.delayed(const Duration(milliseconds: 200)),
      ).then((value) {
        if (!widget.controller.active) {
          return;
        }

        if (widget.zoomMode == EditorZoomMode.real && _sizeRatioUnequal) {
          _moveToCenter();
        }

        widget.controller.updateOutputData(
          widget.controller.toProjected(
            context,
            camera,
            widget.constraints,
            size,
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    cameraFuture?.cancel();
    super.dispose();
  }

  void _updateSize({PolyWidgetData? customData}) {
    PolyWidgetData? data = customData ?? widget.controller.data;
    if (data == null) {
      return;
    }

    size = toUnprojected(
      context,
      widget.camera,
      widget.constraints,
      data,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PolyWidgetEditorState(
      onSubmit: () => widget.controller
          .toProjected(context, widget.camera, widget.constraints, size),
      child: Builder(
        builder: (context) {
          return widget.builder.call(
            context,
            size,
            moveOnCameraChange
                ? widget.controller.data?.calcRotationDiff(widget.camera)
                : null,
          );
        },
      ),
    );
  }

  EdgeInsets toUnprojected(BuildContext context, MapCamera camera,
      BoxConstraints constraints, PolyWidgetData data) {
    PolyWidgetScreenData convert = data.convertForCamera(
      mapCamera: camera,
      mobileLayer: false,
      noRotation: true,
    );
    return EdgeInsets.fromLTRB(
      convert.left,
      convert.top,
      constraints.maxWidth - (convert.left + convert.width),
      constraints.maxHeight - (convert.top + convert.height),
    );
  }

  Future<void> _onActivate(MapCamera camera) async {
    if (widget.onMove != null) {
      await widget.onMove!.call(camera);
    } else {
      MapController.of(context).moveAndRotate(
        camera.center,
        camera.zoom,
        camera.rotation,
      );
    }
  }

  void _updateActive() async {
    if (active != widget.controller.active) {
      if (!active) {
        PolyWidgetData data = widget.controller.data!;
        var camera = widget.camera;
        camera = widget.zoomMode.transform(camera, data, widget.constraints);
        await _onActivate(
          camera,
        );
        moveOnCameraChange = false;
      } else {
        moveOnCameraChange = true;
      }
      setState(() {
        active = widget.controller.active;
      });
    }
  }

  bool get _sizeRatioUnequal {
    double verticalRatio = size.top / size.bottom;
    if (verticalRatio > 1.1 || verticalRatio < (1 / 1.1)) return true;
    double horizontalRatio = size.left / size.right;
    if (horizontalRatio > 1.1 || horizontalRatio < (1 / 1.1)) return true;
    return false;
  }

  void _moveToCenter() async {
    LatLng? dataCenter = widget.controller.data?.center;
    if (dataCenter != null) {
      moveOnCameraChange = true;
      await widget.onMove?.call(widget.camera.withPosition(center: dataCenter));
      moveOnCameraChange = false;
    }
  }
}
