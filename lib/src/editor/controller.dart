import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_polywidget/src/data.dart';
import 'package:flutter_map_polywidget/src/editor/state.dart';

class PolyWidgetEditorController with ChangeNotifier {
  late PolyWidgetEditorState state;
  PolyWidgetData? data;
  PolyWidgetData? outputData;

  PolyWidgetEditorController();

  void attach(BuildContext context) {
    state = PolyWidgetEditorState.of(context);
  }

  void show(PolyWidgetData data) {
    this.data = data;
    this.outputData = data;
    notifyListeners();
  }

  PolyWidgetData submit() {
    PolyWidgetData? data = state.onSubmit();
    if (data == null) {
      throw Exception("cannot submit inactive poly widget editor");
    }

    hide();
    return data;
  }

  void hide() {
    this.data = null;
    this.outputData = null;
    notifyListeners();
  }

  void updateWidth(int width) {
    data = data?.copyWith(widthInMeters: width);
    outputData = data;
    notifyListeners();
  }

  void updateHeight(int height) {
    data = data?.copyWith(heightInMeters: height);
    outputData = data;
    notifyListeners();
  }

  void updateAngle(double angle) {
    data = data?.copyWith(angle: angle);
    outputData = data;
    notifyListeners();
  }

  void updateOutputData(PolyWidgetData? data) {
    outputData = data;
    notifyListeners();
  }

  bool get active => data != null;

  void updateUnprojectedSize(
      BuildContext context, BoxConstraints constraints, EdgeInsets size) {
    data = toProjected(context, constraints, size);
    outputData = data;
    notifyListeners();
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
}
