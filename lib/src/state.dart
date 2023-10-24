import 'package:flutter/cupertino.dart';
import 'package:flutter_map_polywidget/src/data.dart';

class PolyWidgetState extends InheritedWidget {
  final BuildContext parentContext;
  final PolyWidgetScreenData screenData;
  final PolyWidgetData data;

  const PolyWidgetState({
    required this.parentContext,
    required this.data,
    required this.screenData,
    required super.child,
    super.key,
  });

  @override
  bool updateShouldNotify(covariant PolyWidgetState oldWidget) {
    return data != oldWidget.data;
  }

  static PolyWidgetState? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PolyWidgetState>();
  }

  static PolyWidgetState of(BuildContext context) {
    return maybeOf(context)!;
  }
}
