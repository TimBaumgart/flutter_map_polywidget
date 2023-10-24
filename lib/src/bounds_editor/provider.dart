import 'package:flutter/material.dart';
import 'package:flutter_map_polywidget/src/bounds_editor/resize_line.dart';
import 'package:flutter_map_polywidget/src/bounds_editor/state.dart';

class BoundsEditorProvider extends StatefulWidget {
  final BuildContext parentContext;
  final Size parentSize;
  final EdgeInsets size;
  final Function(EdgeInsets onChanged) onChanged;
  final Widget child;

  BoundsEditorProvider({
    super.key,
    required this.parentContext,
    required this.parentSize,
    EdgeInsets? size,
    required this.onChanged,
    required this.child,
  }) : size = size ??
            EdgeInsets.symmetric(
              vertical: parentSize.height / 3,
              horizontal: parentSize.width / 3,
            );

  @override
  State<BoundsEditorProvider> createState() => _BoundsEditorProviderState();
}

class _BoundsEditorProviderState extends State<BoundsEditorProvider> {
  late EdgeInsets size;
  ResizeLineData? activeResizeLine;

  @override
  void initState() {
    super.initState();
    size = widget.size;
  }

  @override
  void didUpdateWidget(covariant BoundsEditorProvider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.parentSize != widget.parentSize ||
        oldWidget.size != widget.size) {
      size = widget.size;
      setState(() {
        _updateSize();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BoundsEditorState(
      renderBox: widget.parentContext.findRenderObject() as RenderBox,
      parentSize: widget.parentSize,
      size: size,
      onLineChanged: (resizeLine) {
        setState(() {
          activeResizeLine = resizeLine;
          _updateSize();
        });
      },
      submitActiveLine: () {
        setState(() {
          activeResizeLine = null;
          _updateSize();
        });
        // widget.onChanged.call(size);
      },
      child: widget.child,
    );
  }

  void _updateSize() {
    size = activeResizeLine?.modifySize(size) ?? size;
  }
}
