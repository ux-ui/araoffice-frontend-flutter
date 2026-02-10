import 'dart:ui';

extension ColorExtension on Color {
  int toInt({bool withAlpha = false}) {
    return ((withAlpha ? ((a * 255.0).round() & 0xff) << 24 : 0) |
            (((r * 255.0).round() & 0xff) << 16) |
            (((g * 255.0).round() & 0xff) << 8) |
            (((b * 255.0).round() & 0xff) << 0)) &
        0xFFFFFFFF;
  }

  String toHex({String? leading, bool withAlpha = false}) {
    var hex = StringBuffer();
    if (leading != null) hex.write(leading);
    if (withAlpha) {
      hex.write((a * 255.0).round().toRadixString(16).padLeft(2, '0'));
    }
    hex.write((r * 255.0).round().toRadixString(16).padLeft(2, '0'));
    hex.write((g * 255.0).round().toRadixString(16).padLeft(2, '0'));
    hex.write((b * 255.0).round().toRadixString(16).padLeft(2, '0'));
    return hex.toString().toUpperCase();
  }
}
