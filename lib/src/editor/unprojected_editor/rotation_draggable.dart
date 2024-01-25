import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_polywidget/src/editor/unprojected_editor/draggable.dart';
import 'package:flutter_map_polywidget/src/editor/unprojected_editor/state.dart';
import 'package:latlong2/latlong.dart';

double buttonSize = 44;

class RotationDraggable extends StatefulWidget {
  @override
  State<RotationDraggable> createState() => _RotationDraggableState();
}

class _RotationDraggableState extends State<RotationDraggable> {
  GlobalKey _draggableKey = GlobalKey();
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    var state = UnprojectedEditorState.of(context);
    var radius = (state.parentSize.shortestSide / 2 - 16);
    var point = _rotationToPoint(radius);

    return Positioned.fill(
      child: Stack(
        children: [
          if (_dragging)
            Positioned.fill(
              child: Center(
                child: SizedBox.square(
                  dimension: radius * 2,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).dividerColor.withOpacity(0.2),
                        width: buttonSize,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            left: point.dx - buttonSize / 2,
            top: point.dy - buttonSize / 2,
            width: buttonSize,
            height: buttonSize,
            child: MyDraggable<String>(
              key: _draggableKey,
              feedback: const SizedBox.shrink(),
              // dragAnchorStrategy: pointerDragAnchorStrategy,
              onDragStarted: () {
                setState(() {
                  _dragging = true;
                });
              },
              onDragEnd: (details) {
                setState(() {
                  _dragging = false;
                });
              },
              onDragUpdate: (details) {
                _onDragUpdate(context, details);
              },
              data: "nothing",
              child: MouseRegion(
                cursor: SystemMouseCursors.grab,
                child: _Compass(dragging: false),
              ),
              childWhenDragging: MouseRegion(
                cursor: SystemMouseCursors.grabbing,
                child: _Compass(
                  dragging: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onDragUpdate(BuildContext context, DragUpdateDetails details) {
    var rotation = _offsetToRotation(context, details.globalPosition);

    MapController.of(context).rotate(radianToDeg(rotation) + 90);
  }

  double _offsetToRotation(BuildContext context, Offset globalPosition) {
    UnprojectedEditorState state = UnprojectedEditorState.of(context);
    var position = state.renderBox.globalToLocal(globalPosition);
    Offset center =
        Offset(state.parentSize.width / 2, state.parentSize.height / 2);
    var offset = (position - center);
    var direction = offset.direction;
    return direction;
  }

  Offset _rotationToPoint(double radius) {
    var buttonRadius = radius - buttonSize / 2;
    var rotation = MapCamera.of(context).rotation;
    var radians = degToRadian(rotation - 90);
    var offsetFromCenter = Offset.fromDirection(radians, buttonRadius);

    var state = UnprojectedEditorState.of(context);
    var center = state.parentCenter;
    Offset point = center + offsetFromCenter;
    return point;
  }
}

class _Compass extends StatelessWidget {
  bool dragging;

  _Compass({
    required this.dragging,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).cardColor,
        boxShadow: kElevationToShadow[dragging ? 8 : 1],
      ),
      width: buttonSize,
      height: buttonSize,
      child: Transform.rotate(
        angle: degToRadian(MapCamera.of(context).rotation),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_drop_up,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            Transform.translate(
              offset: Offset(0, -4),
              child: Transform.rotate(
                angle: -degToRadian(MapCamera.of(context).rotation),
                child: Text(
                  "N",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
