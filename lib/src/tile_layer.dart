import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

/// layer class where all poly widgets should be added
class PolyWidgetLayer extends StatelessWidget {
  final List<Widget> polyWidgets;

  const PolyWidgetLayer({super.key, required this.polyWidgets});

  @override
  Widget build(BuildContext context) {
    return MobileLayerTransformer(
      child: Stack(
        children: polyWidgets,
      ),
    );
  }
}
