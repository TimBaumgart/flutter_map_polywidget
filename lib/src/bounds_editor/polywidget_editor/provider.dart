import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_polywidget/flutter_map_polywidget.dart';

class PolyWidgetBoundsEditorProvider extends StatefulWidget {
  final MapCamera camera;
  final PolyWidgetData data;
  final BoxConstraints constraints;
  final Function(PolyWidgetData data) onChanged;
  final Function(BuildContext context, EdgeInsets size) builder;

  final bool active;
  final Function()? onActivate;

  const PolyWidgetBoundsEditorProvider({
    super.key,
    required this.camera,
    required this.data,
    required this.constraints,
    required this.onChanged,
    required this.builder,
    required this.active,
    required this.onActivate,
  });

  @override
  State<PolyWidgetBoundsEditorProvider> createState() =>
      _PolyWidgetBoundsEditorProviderState();
}

class _PolyWidgetBoundsEditorProviderState
    extends State<PolyWidgetBoundsEditorProvider> {
  late EdgeInsets size;

  @override
  void initState() {
    super.initState();
    _initSize();
  }

  @override
  void didUpdateWidget(covariant PolyWidgetBoundsEditorProvider oldWidget) {
    super.didUpdateWidget(oldWidget);
    bool activated = !oldWidget.active && widget.active;
    bool somethingChanged = oldWidget.constraints != widget.constraints ||
        oldWidget.data != widget.data;
    if (activated || somethingChanged) {
      _initSize();
      if (activated) {
        widget.onActivate?.call();
      }
    }
    if (widget.camera != oldWidget.camera) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // widget.onChanged.call(
        //   toProjected(context, widget.constraints, size),
        // );
      });
    }
  }

  void _initSize() {
    MapCamera camera = widget.camera;
    // print("${camera.center} ${camera.zoom} ${camera.rotation}");
    camera = widget.camera.withRotation(-widget.data.angle);
    // print("${camera.center} ${camera.zoom} ${camera.rotation}");
    // print(
    //     "- ${widget.data.center} ${widget.data.widthInMeters} ${widget.data.heightInMeters}");
    CameraFit cameraFit = CameraFit.coordinates(
      coordinates: widget.data.calcOutlineCoordinates(),
      padding: EdgeInsets.all(64),
    );
    camera = cameraFit.fit(camera);
    // print("${camera.center} ${camera.zoom} ${camera.rotation}");
    size = toUnprojected(
      camera.withRotation(0),
      widget.constraints,
      widget.data,
    );
    // print("init size: $size");
  }

  @override
  Widget build(BuildContext context) {
    return PolyWidgetBoundsEditorState(
      onActivate: () {
        setState(() {
          _initSize();
        });
      },
      child: Builder(
        builder: (context) {
          return widget.builder.call(
            context,
            size,
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
      rotation: camera.rotation,
    );
    return polyWidgetScreenData.convert(context);
  }
}
