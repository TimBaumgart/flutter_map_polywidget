<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

# flutter_map_polywidget

`flutter_map_polywidget` is a [flutter_map](https://pub.dev/packages/flutter_map) plugin for
displaying any widget on the map.

[polywidget.webm](https://github.com/TimBaumgart/flutter_map_polywidget/assets/46818679/6caa4f5c-901b-4415-9411-a26e72e3a638)

Join [flutter_map Discord server](https://discord.gg/egEGeByf4q) to talk
about `flutter_map_polywidget`, get help and help others in the #plugins channel.

## Features

- choose the location and size of the desired area and display any widget you want
- define the location by
    - center, width, height and angle
    - two exact and one approximated point
- constrain your custom widget so that it does not get too big or too small when you zoom in or out
- define whether the widget should rotate with the users view, restrict it to one orientation or
  disable rotation completely

## Getting started

Add `flutter_map_polywidget` to your `pubspec.yaml`:

```
dependencies:
  flutter_map_polywidget: any # or latest verion
```

## Usage

Start by adding a `PolyWidgetLayer` to your map:

```dart 
FlutterMap(
  children: [
    ...
    PolyWidgetLayer(
      polyWidgets: [
        ...
      ],
    ),
  ],
),
```

Add `PolyWidget` widgets inside your `PolyWidgetLayer`. PolyWidgets can be created in two ways.

First, by defining the center location, the width, the height and the angle of your widget:

```dart             
PolyWidget(
  center: LatLng(50.933465, 6.875109),
  widthInMeters: 100,
  heightInMeters: 200,
  angle: 90,
  child: ...,
),
```

Second, by defining three corners of the desired widget on the map. The first and second corners are
fixed and will be used to define the width and angle of your widget. The third corner is only fixed
if it is placed in a 90° angle from the second corner. Otherwise the distance from the second to the
third corner is used to calculate the actual third corner. All three corners are used to calculate
the center location.

```dart 
PolyWidget.threePoints(
  pointA: LatLng(50.936614, 6.876283),
  pointB: LatLng(50.936498, 6.877663),
  approxPointC: LatLng(50.935312, 6.877419),
  child: ...,
),
```

### Constraints

By default, your widget is unconstrained. The more you zoom out, the smaller your widget gets. If
your widget needs a minimum size, this can result in layout errors. To prevent that, you can define
constraints on your polywidget. This wraps your widget in a `FittedBox` and ensures, that it fits your
constraints.

```dart 
PolyWidget(
  ...,
  constraints: BoxConstraints(
    minWidth: 250,
    maxWidth: 350,
  ),
  child: ...,
),
```

[polywidget_with_constraints.webm](https://github.com/TimBaumgart/flutter_map_polywidget/assets/46818679/64c5008a-318e-458e-9f6c-cff5c1cfe88d)


### Disable rotation

By default, your widget rotates automatically so it lines up with the current rotation of the map.
To disable that, set `noRotation` to `true`:

```dart 
PolyWidget(
  ...,
  noRotation: true,
  child: ...,
),
```

### Force orientation

If you want your widget to only rotate to `portrait` or `landscape` orientation, you can do that by
defining `forceOrientation`:

```dart                
PolyWidget(
  ...,
  forceOrientation: Orientation.landscape, //or Orientation.portrait
  child: ...,
),
```

## Example

You can find the example shown in the showcase video in `/example`.
