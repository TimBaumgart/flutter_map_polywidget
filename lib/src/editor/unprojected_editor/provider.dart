import 'package:flutter/material.dart';
import 'package:flutter_map_polywidget/src/editor/unprojected_editor/resize_line.dart';
import 'package:flutter_map_polywidget/src/editor/unprojected_editor/state.dart';

class UnprojectedEditorProvider extends StatefulWidget {
  final BuildContext parentContext;
  final Size parentSize;
  final EdgeInsets size;
  final Function(EdgeInsets onChanged) onChanged;
  final Widget child;
  final Size minCenterSize;

  UnprojectedEditorProvider({
    super.key,
    required this.parentContext,
    required this.parentSize,
    EdgeInsets? size,
    required this.onChanged,
    required this.child,
    required this.minCenterSize,
  }) : size = size ??
            EdgeInsets.symmetric(
              vertical: parentSize.height / 3,
              horizontal: parentSize.width / 3,
            );

  @override
  State<UnprojectedEditorProvider> createState() =>
      _UnprojectedEditorProviderState();
}

class _UnprojectedEditorProviderState extends State<UnprojectedEditorProvider> {
  late EdgeInsets size;
  ResizeLineData? activeResizeLine;

  @override
  void initState() {
    super.initState();
    size = widget.size;
  }

  @override
  void didUpdateWidget(covariant UnprojectedEditorProvider oldWidget) {
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
    return UnprojectedEditorState(
      renderBox: widget.parentContext.findRenderObject() as RenderBox,
      parentSize: widget.parentSize,
      size: size,
      onLineChanged: (resizeLine) {
        setState(() {
          activeResizeLine = resizeLine;
          _updateSize();
        });
        // due to inaccurate project/unproject-calculations changes in size widget.onChanged.call(size) should be called as rarely as possible
        // widget.onChanged.call(size);
      },
      submitActiveLine: () {
        setState(() {
          activeResizeLine = null;
          _updateSize();
        });
        widget.onChanged.call(size);
      },
      child: widget.child,
    );
  }

  void _updateSize() {
    size = activeResizeLine
            ?.modifySize(size, widget.parentSize, widget.minCenterSize)
            .clamp(const EdgeInsets.all(thickness),
                const EdgeInsets.all(double.infinity)) as EdgeInsets? ??
        size;
  }
}
