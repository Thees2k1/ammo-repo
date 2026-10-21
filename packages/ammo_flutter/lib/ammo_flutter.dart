/// Flutter widget helpers and UI extensions built on modern Flutter and ammo_dart.
library ammo_flutter;

import 'package:ammo_dart/ammo_dart.dart';
import 'package:flutter/widgets.dart';

export 'package:ammo_dart/ammo_dart.dart';

/// Extension methods on [Widget] for common layout wrappers.
extension AmmoWidgetX on Widget {
  /// Wraps this widget in [Padding] with all sides set to [padding].
  Widget padAll(double padding) =>
      Padding(padding: EdgeInsets.all(padding), child: this);

  /// Wraps this widget in [Padding] with horizontal and vertical padding.
  Widget padSymmetric({double horizontal = 0.0, double vertical = 0.0}) =>
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontal,
          vertical: vertical,
        ),
        child: this,
      );

  /// Wraps this widget in [Center].
  Widget centered() => Center(child: this);
}

/// Helper utilities combining Flutter and ammo_dart functionality.
abstract final class AmmoFlutterHelper {
  /// Formats a title using [AmmoStringX.capitalize] and creates a [Text] widget.
  static Text formattedText(String text) => Text(text.capitalize());
}
