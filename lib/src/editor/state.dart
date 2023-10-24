import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_polywidget/flutter_map_polywidget.dart';
import 'package:latlong2/latlong.dart';

class PolyWidgetEditorState extends InheritedWidget {
  final void Function(EdgeInsets expand) onUpdateSize;
  final void Function(LatLng center) onUpdatePosition;
  final void Function(double angle) onUpdateAngle;
  final void Function({
    LatLng? center,
    int? widthInMeters,
    int? heightInMeters,
    double? angle,
  }) onSubmitted;
  final void Function(BuildContext context) activate;

  final void Function(MapEvent mapEvent) onMapEvent;

  final EdgeInsets? expand;
  final LatLng? center;
  final double? angle;

  const PolyWidgetEditorState({
    super.key,
    required this.activate,
    required this.onMapEvent,
    required this.onUpdateSize,
    required this.onUpdatePosition,
    required this.onUpdateAngle,
    required this.onSubmitted,
    required this.expand,
    required this.center,
    required this.angle,
    required super.child,
  });

  @override
  bool updateShouldNotify(covariant PolyWidgetEditorState oldWidget) {
    return expand != oldWidget.expand ||
        center != oldWidget.center ||
        angle != oldWidget.angle;
  }

  static PolyWidgetEditorState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PolyWidgetEditorState>()!;
  }
}

class PolyWidgetEditorStateProvider extends StatefulWidget {
  final Widget child;
  final Future<void> Function({
    LatLng? center,
    int? widthInMeters,
    int? heightInMeters,
    double? angle,
  }) onSubmitted;

  const PolyWidgetEditorStateProvider({
    super.key,
    required this.child,
    required this.onSubmitted,
  });

  @override
  State<PolyWidgetEditorStateProvider> createState() =>
      _PolyWidgetEditorStateProviderState();
}

class _PolyWidgetEditorStateProviderState
    extends State<PolyWidgetEditorStateProvider> {
  EdgeInsets? expand;
  LatLng? center;
  double? angle;

  @override
  Widget build(BuildContext context) {
    return PolyWidgetEditorState(
      expand: expand,
      center: center,
      angle: angle,
      activate: (BuildContext context) {
        PolyWidgetState state = PolyWidgetState.of(context);
        print("activate called ${state.data.center}");
        bool move = MapController.of(context).move(LatLng(55, 6.8), 0);
        print("move: $move");
      },
      onMapEvent: (mapEvent) {
        setState(() {
          center = mapEvent.camera.center;
          angle = -mapEvent.camera.rotation;
        });
      },
      onUpdatePosition: (center) {
        setState(() {
          this.center = center;
        });
      },
      onUpdateSize: (expand) {
        setState(() {
          this.expand = expand;
        });
      },
      onUpdateAngle: (double angle) {
        setState(() {
          this.angle = angle;
        });
      },
      onSubmitted: ({center, widthInMeters, heightInMeters, angle}) async {
        await widget.onSubmitted.call(
          center: center,
          widthInMeters: widthInMeters,
          heightInMeters: heightInMeters,
          angle: angle,
        );
        if (context.mounted) {
          if (center != null) {
            MapController.of(context).move(center, MapCamera.of(context).zoom);
          }
          setState(() {
            expand = null;
            this.center = null;
            this.angle = null;
          });
        }
      },
      child: widget.child,
    );
  }
}
