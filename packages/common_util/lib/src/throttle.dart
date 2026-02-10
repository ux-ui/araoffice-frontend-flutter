import 'dart:async';
import 'dart:ui';

class Throttle {
  final int milliseconds;
  Timer? _timer;

  Throttle({required this.milliseconds});

  void run(VoidCallback action) {
    if (_timer?.isActive ?? false) return;
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), () {
      action();
      _timer = null;
    });
  }
}
