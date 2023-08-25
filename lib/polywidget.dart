library polywidget;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A Calculator.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
}

class PolyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: Colors.red, child: SizedBox.square(dimension: 10),);
  }

}