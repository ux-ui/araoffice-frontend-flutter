import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

extension AnimateExtension on Widget {
  Widget animation() {
    return animate()
        .fade(curve: Curves.easeInOut)
        .moveX(curve: Curves.easeInOut);
  }
}
