import 'package:flutter/material.dart';
import 'package:flutter_map_polywidget/flutter_map_polywidget.dart';
import 'package:flutter_map_polywidget/src/editor/unprojected_editor/provider.dart';
import 'package:flutter_map_polywidget/src/editor/unprojected_editor/resize_line.dart';
import 'package:flutter_map_polywidget/src/editor/unprojected_editor/state.dart';

class UnprojectedEditor extends StatelessWidget {
  final EdgeInsets? size;
  final void Function(EdgeInsets size) onChanged;
  final EditorChildBuilder? builder;
  final Size minCenterSize;
  final Widget? centerChild;

  const UnprojectedEditor({
    super.key,
    required this.size,
    required this.onChanged,
    required this.minCenterSize,
    required this.builder,
    this.centerChild,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return UnprojectedEditorProvider(
        parentContext: context,
        size: size,
        parentSize: constraints.biggest,
        minCenterSize: minCenterSize,
        onChanged: onChanged,
        child: Builder(builder: (context) {
          UnprojectedEditorState state = UnprojectedEditorState.of(context);
          return Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: ColorFiltered(
                    colorFilter: const ColorFilter.mode(
                      Colors.black,
                      BlendMode.srcOut,
                    ),
                    child: ColoredBox(
                      color: Colors.black.withOpacity(0.5),
                      child: Stack(
                        children: [
                          Positioned(
                            top: state.size.top,
                            left: state.size.left,
                            width:
                                state.parentSize.width - state.size.horizontal,
                            height:
                                state.parentSize.height - state.size.vertical,
                            child: const ColoredBox(
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (centerChild != null)
                Positioned(
                  top: state.size.top,
                  left: state.size.left,
                  bottom: state.size.bottom,
                  right: state.size.right,
                  child: centerChild!,
                ),
              LeftHorizontalResizeLineData().build(context),
              RightHorizontalResizeLineData().build(context),
              TopVerticalResizeLineData().build(context),
              BottomVerticalResizeLineData().build(context),
              if (builder != null)
                Positioned.fill(
                  child: builder!.call(context, state.size),
                ),
            ],
          );
        }),
      );
    });
  }
}
