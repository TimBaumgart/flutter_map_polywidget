import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_polywidget/src/data.dart';

class PolyWidgetBoundsEditorState extends InheritedWidget {
  final void Function() onActivate;

  const PolyWidgetBoundsEditorState(
      {super.key, required this.onActivate, required super.child});

  static PolyWidgetBoundsEditorState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<PolyWidgetBoundsEditorState>()!;
  }

  @override
  bool updateShouldNotify(covariant PolyWidgetBoundsEditorState oldWidget) {
    return false;
  }

  void activate() {
    onActivate.call();
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
