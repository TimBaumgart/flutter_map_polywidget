import 'package:flutter/material.dart';

class MyDraggable<T extends Object> extends StatefulWidget {
  final T? data;
  final Widget child;
  final Widget feedback;
  final VoidCallback? onDragStarted;
  final DragEndCallback? onDragEnd;
  final DragUpdateCallback? onDragUpdate;
  final Widget? childWhenDragging;
  final DragAnchorStrategy dragAnchorStrategy;

  const MyDraggable({
    super.key,
    this.data,
    required this.child,
    required this.feedback,
    this.onDragStarted,
    this.onDragEnd,
    this.onDragUpdate,
    this.childWhenDragging,
    this.dragAnchorStrategy = childDragAnchorStrategy,
  });

  @override
  State<MyDraggable> createState() => _MyDraggableState();
}

class _MyDraggableState extends State<MyDraggable> {
  late Offset pointerOffset;

  @override
  Widget build(BuildContext context) {
    return LongPressAndDefaultDraggable(
      data: widget.data,
      feedback: widget.feedback,
      onDragStarted: widget.onDragStarted,
      onDragEnd: widget.onDragEnd,
      onDragUpdate: (details) {
        widget.onDragUpdate?.call(
          DragUpdateDetails(
            globalPosition: details.globalPosition - pointerOffset,
          ),
        );
      },
      childWhenDragging: widget.childWhenDragging,
      dragAnchorStrategy: (draggable, context, position) {
        RenderBox renderBox = context.findRenderObject() as RenderBox;
        Offset local = renderBox.globalToLocal(position);
        pointerOffset = local;
        return widget.dragAnchorStrategy.call(draggable, context, position);
      },
      child: widget.child,
    );
  }
}

class LongPressAndDefaultDraggable<T extends Object> extends StatelessWidget {
  final T? data;
  final Widget child;
  final Widget feedback;
  final VoidCallback? onDragStarted;
  final DragEndCallback? onDragEnd;
  final DragUpdateCallback? onDragUpdate;
  final Widget? childWhenDragging;
  final DragAnchorStrategy dragAnchorStrategy;

  const LongPressAndDefaultDraggable({
    super.key,
    this.data,
    required this.child,
    required this.feedback,
    this.onDragStarted,
    this.onDragEnd,
    this.onDragUpdate,
    this.childWhenDragging,
    this.dragAnchorStrategy = childDragAnchorStrategy,
  });

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<T>(
      data: data,
      feedback: feedback,
      onDragStarted: onDragStarted,
      onDragEnd: onDragEnd,
      onDragUpdate: onDragUpdate,
      childWhenDragging: childWhenDragging,
      dragAnchorStrategy: dragAnchorStrategy,
      child: Draggable(
        data: data,
        feedback: feedback,
        onDragStarted: onDragStarted,
        onDragEnd: onDragEnd,
        onDragUpdate: onDragUpdate,
        childWhenDragging: childWhenDragging,
        dragAnchorStrategy: dragAnchorStrategy,
        child: child,
      ),
    );
  }
}
