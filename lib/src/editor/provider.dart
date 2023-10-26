import 'package:async/async.dart';
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
  final MoveCallback? onMove;
  final Function(BuildContext context, EdgeInsets size, double? rotation)
      builderX;

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
  bool activationMovementFinished = false;
  EdgeInsets size = EdgeInsets.zero;
  CancelableOperation<void>? cameraFuture;

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
    var updateOnZoom = camera.zoom != oldWidget.camera.zoom &&
        widget.zoomMode.updateSizeOnZoom();
    var updateOnActivationMovement =
        !activationMovementFinished && camera != oldWidget.camera;
    debugPrint("updateOnActivationMovement: $updateOnActivationMovement");
    if (updateOnZoom || updateOnActivationMovement) {
      _updateSize();
    }

    if (camera != oldWidget.camera) {
      cameraFuture?.cancel();
      cameraFuture = CancelableOperation.fromFuture(
        Future.delayed(const Duration(milliseconds: 200)),
        // onCancel: () => {debugPrint('onCancel')},
      ).then((value) {
        if (!widget.controller.active) {
          return;
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

    // var camera = widget.camera;
    // camera = widget.zoomMode.transform(camera, data, widget.constraints);

    // var camera =
    // .withPosition(center: data.center)
    // .withRotation(data.angle)
    // .withRotation(-widget.camera.rotation)
    // .withRotation(0)
    // ;

    size = toUnprojected(
      context,
      widget.camera,
      widget.constraints,
      data,
    );
    print(size);
  }

  @override
  Widget build(BuildContext context) {
    return PolyWidgetEditorState(
      onSubmit: () => widget.controller
          .toProjected(context, widget.camera, widget.constraints, size),
      child: Builder(
        builder: (context) {
          return widget.builderX.call(
            context,
            size,
            activationMovementFinished
                ? null
                : widget.controller.data?.calcRotationDiff(widget.camera),
          );
        },
      ),
    );
  }

  EdgeInsets toUnprojected(BuildContext context, MapCamera camera,
      BoxConstraints constraints, PolyWidgetData data) {
    PolyWidgetScreenData convert =
        data.convert(context, camera, null, true, false);
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
        activationMovementFinished = true;
      } else {
        activationMovementFinished = false;
      }
      setState(() {
        active = widget.controller.active;
      });
    }
  }
}
