import 'package:flutter/material.dart';
import 'package:flutter_map_polywidget/src/data.dart';

class PolyWidgetEditorState extends InheritedWidget {
  final void Function({int? width, int? height, double? angle}) updateData;
  final void Function() onActivate;
  final PolyWidgetData Function() onSave;

  const PolyWidgetEditorState({
    super.key,
    required this.onActivate,
    required this.onSave,
    required this.updateData,
    required super.child,
  });

  static PolyWidgetEditorState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PolyWidgetEditorState>()!;
  }

  @override
  bool updateShouldNotify(covariant PolyWidgetEditorState oldWidget) {
    return false;
  }

  void activate() {
    onActivate.call();
  }

// PolyWidgetData toProjected(
//     BuildContext context, BoxConstraints constraints, EdgeInsets size) {
//   MapCamera camera = MapCamera.of(context);
//   PolyWidgetScreenData polyWidgetScreenData = PolyWidgetScreenData(
//     left: size.left,
//     top: size.top,
//     width: constraints.maxWidth - size.horizontal,
//     height: constraints.maxHeight - size.vertical,
//     rotation: camera.rotation,
//   );
//   return polyWidgetScreenData.convert(context);
// }
}
