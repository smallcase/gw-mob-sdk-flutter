import 'package:flutter/widgets.dart';

extension ColorExt on Color {
  String toHex({bool leadingHashSign = true, bool includeAlpha = false}) =>
      '${leadingHashSign ? '#' : ''}'
          '${includeAlpha ? alpha.toRadixString(16).padLeft(2, '0') : ''}'
          '${red.toRadixString(16).padLeft(2, '0')}'
          '${green.toRadixString(16).padLeft(2, '0')}'
          '${blue.toRadixString(16).padLeft(2, '0')}';
}