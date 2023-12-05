## 0.0.1

* Initial release

## 0.0.2

* Add example from showcase video in `/example`

## 0.0.3

* fix example and add documentation

## 0.0.4

* fix formatting in polywidget.dart

## 0.0.5-0.0.8

* add automatic deployment

## 0.0.9

* disable automatic deployment as it does not work
  yet (https://github.com/dart-lang/setup-dart/issues/68)

## 0.1.0

* make polywidget clickable by using `Positioned()` instead of `Transform.translate()`
* add functionality
  to [constrain](https://github.com/TimBaumgart/flutter_map_polywidget/blob/main/README.md#constraints)
  custom widget

## 1.0.0

* migrate to flutter_map v6.0.0
* add library file to reduce imports

### migration steps

* replace `import 'package:flutter_map_polywidget/tile_layer.dart';`
  and `import 'package:flutter_map_polywidget/polywidget.dart';`
  with `import 'package:flutter_map_polywidget/flutter_map_polywidget.dart';`

## 1.0.1

* allow all widgets to be placed inside `PolyWidgetLayer`. This allows the use of Selectors to build
  PolyWidgets for example.

## 1.1.0-dev.1 - 1.1.0-dev.4

* add polywidget editor (wip)

### roadmap

* documentation missing
* example missing
* move unprojected center widget by drag&drop
* show height/length when resizing editor
* add corner buttons to resize width and height at once