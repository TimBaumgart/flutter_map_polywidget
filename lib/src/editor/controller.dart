import 'package:flutter/material.dart';
import 'package:flutter_map_polywidget/src/data.dart';
import 'package:flutter_map_polywidget/src/editor/state.dart';

class PolyWidgetEditorController with ChangeNotifier {
  late PolyWidgetEditorState state;
  PolyWidgetData? data;

  PolyWidgetEditorController();

  void attach(BuildContext context) {
    state = PolyWidgetEditorState.of(context);
  }

  void updateWidth(int width) {
    state.updateData(width: width);
  }

  void updateHeight(int height) {
    state.updateData(height: height);
  }

  void updateAngle(double angle) {
    state.updateData(angle: angle);
  }

  void updateData(PolyWidgetData? data) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      this.data = data;
      notifyListeners();
    });
  }
}
