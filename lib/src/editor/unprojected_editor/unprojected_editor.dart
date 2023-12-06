import 'package:flutter/material.dart';
import 'package:flutter_map_polywidget/flutter_map_polywidget.dart';
import 'package:flutter_map_polywidget/src/editor/unprojected_editor/provider.dart';
import 'package:flutter_map_polywidget/src/editor/unprojected_editor/resize_line.dart';
import 'package:flutter_map_polywidget/src/editor/unprojected_editor/state.dart';
import 'package:latlong2/latlong.dart';

class UnprojectedEditor extends StatelessWidget {
  final EdgeInsets? size;
  final void Function(EdgeInsets size) onChanged;
  final EditorChildBuilder? builder;
  final Size minCenterSize;
  final Widget? centerChild;
  final double? rotation;
  final bool resizeable;
  final bool rotateable;

  const UnprojectedEditor({
    super.key,
    required this.size,
    required this.onChanged,
    required this.minCenterSize,
    required this.builder,
    required this.rotation,
    this.centerChild,
    bool? resizeable,
    bool? rotateable,
  })  : this.resizeable = resizeable ?? true,
        this.rotateable = rotateable ?? true;

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
                          if (resizeable)
                            Positioned(
                              top: state.size.top,
                              left: state.size.left,
                              width: state.parentSize.width -
                                  state.size.horizontal,
                              height:
                                  state.parentSize.height - state.size.vertical,
                              child: _Rotated(
                                rotation: rotation,
                                child: const ColoredBox(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (centerChild != null)
                if (!resizeable)
                  Positioned(
                    top: state.size.top - 32,
                    left: state.size.left - 32,
                    bottom: state.size.bottom - 32,
                    right: state.size.right - 32,
                    child: centerChild!,
                  )
                else
                  Positioned(
                    top: state.size.top,
                    left: state.size.left,
                    bottom: state.size.bottom,
                    right: state.size.right,
                    child: _Rotated(
                      rotation: rotation,
                      child: centerChild!,
                    ),
                  ),
              // if (resizeable ?? true) ...{
              //   Positioned(
              //     top: state.size.top,
              //     left: state.size.left,
              //     bottom: state.size.bottom,
              //     right: state.size.right,
              //     child: _Rotated(
              //       rotation: rotation,
              //       child: centerChild!,
              //     ),
              //   ),
              // } else ...{
              //   Center(child: centerChild),
              // },
              if (resizeable) ...{
                LeftHorizontalResizeLineData().build(context),
                RightHorizontalResizeLineData().build(context),
                TopVerticalResizeLineData().build(context),
                BottomVerticalResizeLineData().build(context),
              },
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

class _Rotated extends StatelessWidget {
  final Widget child;
  final double? rotation;

  const _Rotated({
    required this.child,
    required this.rotation,
  });

  @override
  Widget build(BuildContext context) {
    if (rotation == null) {
      return child;
    }

    return Transform.rotate(
      angle: degToRadian(rotation!),
      child: child,
    );
  }
}
