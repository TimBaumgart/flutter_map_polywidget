import 'package:flutter/material.dart';
import 'package:flutter_map_polywidget/src/bounds_editor/provider.dart';
import 'package:flutter_map_polywidget/src/bounds_editor/resize_line.dart';
import 'package:flutter_map_polywidget/src/bounds_editor/state.dart';

class BoundsEditor extends StatelessWidget {
  final EdgeInsets? size;
  final void Function(EdgeInsets size) onChanged;

  const BoundsEditor({
    required this.size,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return BoundsEditorProvider(
        parentContext: context,
        size: size,
        parentSize: constraints.biggest,
        onChanged: onChanged,
        child: Builder(builder: (context) {
          BoundsEditorState state = BoundsEditorState.of(context);
          return Stack(
            children: [
              Positioned.fill(
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black,
                    BlendMode.srcOut,
                  ),
                  child: ColoredBox(
                    color: Colors.black.withOpacity(0.2),
                    child: Stack(
                      children: [
                        Positioned(
                          top: state.size.top,
                          left: state.size.left,
                          width: state.parentSize.width - state.size.horizontal,
                          height: state.parentSize.height - state.size.vertical,
                          child: ColoredBox(
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              LeftHorizontalResizeLineData().build(context),
              RightHorizontalResizeLineData().build(context),
              TopVerticalResizeLineData().build(context),
              BottomVerticalResizeLineData().build(context),
            ],
          );
        }),
      );
    });
  }
}
