import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_polywidget/polywidget.dart';
import 'package:flutter_map_polywidget/tile_layer.dart';
import 'package:latlong2/latlong.dart';

class PolyWidgetExample extends StatefulWidget {
  const PolyWidgetExample({super.key});

  @override
  State<PolyWidgetExample> createState() => _PolyWidgetExampleState();
}

class _PolyWidgetExampleState extends State<PolyWidgetExample>
    with SingleTickerProviderStateMixin {
  late MapController mapController;
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    mapController = MapController();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );

    var zoomAnimation = TweenSequence(
      [
        TweenSequenceItem(
          tween: Tween<double>(begin: 16.5, end: 18)
              .chain(CurveTween(curve: Curves.easeInOutSine)),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 18, end: 16.5)
              .chain(CurveTween(curve: Curves.easeInOutSine)),
          weight: 1,
        ),
      ],
    ).animate(animationController);

    var rotationAnimation =
        Tween<double>(begin: 0, end: 360).animate(animationController);

    animationController
      ..addListener(() {
        mapController.moveAndRotate(
          const LatLng(50.934798, 6.875384),
          zoomAnimation.value,
          rotationAnimation.value,
        );
      })
      ..repeat(min: 0, max: 1);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: FlutterMap(
          mapController: mapController,
          options: MapOptions(
            center: const LatLng(50.934798, 6.875384),
            onTap: (tapPosition, point) {
              if (kDebugMode) {
                print(point);
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: const ["a", "b", "c"],
            ),
            PolyWidgetLayer(
              polyWidgets: [
                const PolyWidget(
                  center: LatLng(50.933465, 6.875109),
                  widthInMeters: 120,
                  heightInMeters: 165,
                  angle: 8,
                  child: _Content("Stadium", "full rotation"),
                ),
                const PolyWidget(
                  center: LatLng(50.936158, 6.87445),
                  widthInMeters: 100,
                  heightInMeters: 135,
                  angle: 8,
                  forceOrientation: Orientation.landscape,
                  child: _Content("West", "only landscape"),
                ),
                PolyWidget.threePoints(
                  pointA: const LatLng(50.936614, 6.876283),
                  pointB: const LatLng(50.936498, 6.877663),
                  approxPointC: const LatLng(50.935312, 6.877419),
                  noRotation: true,
                  child: const _Content("East", "no rotation"),
                ),
                const PolyWidget(
                  center: LatLng(50.936253, 6.872112),
                  widthInMeters: 50,
                  heightInMeters: 100,
                  angle: 8,
                  forceOrientation: Orientation.landscape,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.elliptical(50, 50)),
                      gradient: LinearGradient(
                        colors: [
                          Color.fromRGBO(230, 0, 0, 1),
                          Color.fromRGBO(255, 142, 0, 1),
                          Color.fromRGBO(255, 239, 0, 1),
                          Color.fromRGBO(0, 130, 27, 1),
                          Color.fromRGBO(0, 75, 255, 1),
                          Color.fromRGBO(120, 0, 137, 1),
                        ],
                      ),
                    ),
                    child: FittedBox(
                        child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "any widget",
                        style: TextStyle(color: Colors.black),
                      ),
                    )),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final String title;
  final String subTitle;

  const _Content(this.title, this.subTitle);

  @override
  Widget build(BuildContext context) {
    double minWidth = 200;
    double minHeight = 72;

    return LayoutBuilder(
      builder: (context, constraints) {
        var column = Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ListTile(
              title: Text(title),
              subtitle: Text(subTitle),
            ),
            Expanded(
              child: AnimatedOpacity(
                opacity: constraints.maxHeight > 200 ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."),
                ),
              ),
            ),
          ],
        );

        if (constraints.maxWidth < minWidth ||
            constraints.maxHeight < minHeight) {
          return Card(
            child: Align(
              alignment: Alignment.topCenter,
              child: FittedBox(
                child: SizedBox(
                  width: minWidth,
                  height: minHeight,
                  child: column,
                ),
              ),
            ),
          );
        }

        return Card(
          child: Center(
            child: column,
          ),
        );
      },
    );
  }
}
