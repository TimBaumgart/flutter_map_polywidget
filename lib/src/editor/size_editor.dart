import 'package:flutter/material.dart';
import 'package:flutter_map_polywidget/flutter_map_polywidget.dart';
import 'package:flutter_map_polywidget/src/tile_layer.dart';
import 'package:latlong2/latlong.dart';

class PolyWidgetSizeEditor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(3, (index) => _Row(index)),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  int vIndex;

  _Row(this.vIndex);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        3,
        (hIndex) => vIndex != 1 || hIndex != 1
            ? _Button(Alignment(hIndex - 1, vIndex - 1))
            : const SizedBox.shrink(),
      ),
    );
  }
}

class _Button extends StatelessWidget {
  Alignment alignment;

  _Button(this.alignment);

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: kElevationToShadow[8],
      ),
      width: 16,
      height: 16,
    );

    return Draggable(
      data: "nothing",
      feedback: const SizedBox.shrink(),
      // feedback: content,
      child: content,
      onDragUpdate: (details) {
        PolyWidgetLayerState layerState = PolyWidgetLayerState.of(context);
        RenderBox renderBox =
            (layerState.parentContext.findRenderObject() as RenderBox);
        Offset offset = renderBox.globalToLocal(details.globalPosition);

        PolyWidgetState state = PolyWidgetState.of(context);
        offset =
            offset.translate(-state.screenData.left, -state.screenData.top);

        EdgeInsets expand = EdgeInsets.fromLTRB(
          alignment.x < 0 ? alignment.x * offset.dx : 0,
          alignment.y < 0 ? alignment.y * offset.dy : 0,
          alignment.x > 0
              ? -(state.screenData.width - alignment.x * offset.dx)
              : 0,
          alignment.y > 0
              ? -(state.screenData.height - alignment.y * offset.dy)
              : 0,
        );

        PolyWidgetEditorState editorState = PolyWidgetEditorState.of(context);
        editorState.onUpdateSize(expand);

        // Offset topLeftOffset =
        //     Offset(state.screenData.left - expand.left, state.data.top - expand.top);
        // Offset bottomLeftOffset = Offset(
        //     state.screenData.left + state.data.width + expand.right,
        //     state.screenData.top - expand.top);
        // Offset bottomRightOffset = Offset(
        //     state.screenData.left + state.data.width + expand.right,
        //     state.screenData.top + state.data.height + expand.bottom);
        // Offset diff = bottomRightOffset - topLeftOffset;
        // Offset centerOffset = topLeftOffset + (diff / 2);
        //
        // LatLng center = MapCamera.of(context).offsetToCrs(centerOffset);
        //
        // LatLng topLeft = MapCamera.of(context).offsetToCrs(topLeftOffset);
        // LatLng bottomLeft = MapCamera.of(context).offsetToCrs(bottomLeftOffset);
        // LatLng bottomRight =
        //     MapCamera.of(context).offsetToCrs(bottomRightOffset);
        //
        // var widthInMeters =
        //     const Distance().distance(topLeft, bottomLeft).toInt();
        // var heightInMeters =
        //     const Distance().distance(bottomLeft, bottomRight).toInt();
        //
        // print("calc: $center $widthInMeters $heightInMeters");
      },
      onDragEnd: (details) {
        PolyWidgetEditorState editorState = PolyWidgetEditorState.of(context);
        EdgeInsets expand = editorState.expand ?? EdgeInsets.zero;

        PolyWidgetState state = PolyWidgetState.of(context);

        double expandHorizontal =
            1 + (expand.horizontal / state.screenData.width);
        int widthInMeters =
            (state.data.widthInMeters * expandHorizontal).toInt();
        double horizontalChange =
            (widthInMeters / state.data.widthInMeters) - 1;
        double moveHorizontal =
            horizontalChange * state.data.widthInMeters * 0.5 * alignment.x;

        LatLng horizontalCenter =
            const Distance().offset(state.data.center, moveHorizontal, 90);

        double expandVertical = 1 + (expand.vertical / state.screenData.height);
        int heightInMeters =
            (state.data.heightInMeters * expandVertical).toInt();
        double verticalChange =
            (heightInMeters / state.data.heightInMeters) - 1;
        double moveVertical =
            verticalChange * state.data.heightInMeters * 0.5 * alignment.y;

        LatLng center =
            const Distance().offset(horizontalCenter, moveVertical, 180);

        editorState.onSubmitted(
          center: center,
          widthInMeters: widthInMeters,
          heightInMeters: heightInMeters,
        );

        // editorState.onSubmitted();
      },
    );
  }
}
