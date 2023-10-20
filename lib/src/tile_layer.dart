import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

/// layer class where all poly widgets should be added
class PolyWidgetLayer extends StatelessWidget {
  final List<Widget> polyWidgets;

  const PolyWidgetLayer({super.key, required this.polyWidgets});

  @override
  Widget build(BuildContext context) {
    return MobileLayerTransformer(
      child: Builder(builder: (context) {
        return PolyWidgetLayerState(
          parentContext: context,
          child: Stack(
            children: polyWidgets,
          ),
        );
      }),
    );
  }
}

class PolyWidgetLayerState extends InheritedWidget {
  final BuildContext parentContext;

  const PolyWidgetLayerState({
    super.key,
    required super.child,
    required this.parentContext,
  });

  @override
  bool updateShouldNotify(covariant PolyWidgetLayerState oldWidget) {
    return true;
  }

  static PolyWidgetLayerState? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PolyWidgetLayerState>();
  }

  static PolyWidgetLayerState of(BuildContext context) {
    return maybeOf(context)!;
  }
}
