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

  void updateData({int? width, int? height, double? angle}) {
    data = data?.copyWith(
      widthInMeters: width,
      heightInMeters: height,
      angle: angle,
    );
    outputData = data;
    notifyListeners();
  }

  // void updateWidth(int width) {
  //   data = data?.copyWith(widthInMeters: width);
  //   outputData = data;
  //   notifyListeners();
  // }
  //
  // void updateHeight(int height) {
  //   data = data?.copyWith(heightInMeters: height);
  //   outputData = data;
  //   notifyListeners();
  // }
  //
  // void updateAngle(double angle) {
  //   data = data?.copyWith(angle: angle);
  //   outputData = data;
  //   notifyListeners();
  // }

  void updateOutputData(PolyWidgetData? data) {
    this.data = data;
    outputData = data;
    notifyListeners();
  }

  bool get active => data != null;

  void updateUnprojectedSize(BuildContext context, MapCamera camera,
      BoxConstraints constraints, EdgeInsets size) {
    data = toProjected(context, camera, constraints, size);
    print("updateUnprojectedSize ${data?.center}");
    outputData = data;
    // outputData = toProjected(context, constraints, size);
    // outputData = data;
    notifyListeners();
  }

  PolyWidgetData toProjected(BuildContext context, MapCamera camera,
      BoxConstraints constraints, EdgeInsets size) {
    PolyWidgetScreenData polyWidgetScreenData = PolyWidgetScreenData(
      left: size.left,
      top: size.top,
      width: constraints.maxWidth - size.horizontal,
      height: constraints.maxHeight - size.vertical,
      rotation: -mod(camera.rotation, -180, 180),
      // rotation: -camera.rotation,
    );
    return polyWidgetScreenData.convert(context, camera);
  }

  double mod(double value, double fromExclusive, double toInclusive) {
    double step = toInclusive - fromExclusive;
    var result = ((value - fromExclusive) % step) + fromExclusive;
    if (result == fromExclusive) result = toInclusive;
    return result;
  }
}
