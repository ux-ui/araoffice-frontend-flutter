import 'package:flutter/material.dart';

extension ColorToRgb on Color {
  String toRgbString() {
    return 'rgb(${(r * 255.0).round()}, ${(g * 255.0).round()}, ${(b * 255.0).round()})';
  }

  String toRgbaString() {
    return 'rgba(${(r * 255.0).round()}, ${(g * 255.0).round()}, ${(b * 255.0).round()}, ${a.toStringAsFixed(2)})';
  }
}
