import 'dart:math' as math;

import 'package:flutter/material.dart';

class DownloadIcon extends StatefulWidget {
  const DownloadIcon(
      {required this.icon,
      this.color,
      this.size = 20,
      this.onTap,
      this.borderWidth,
      this.borderColor = Colors.black,
      this.progress = 0,
      super.key});

  final Widget icon;
  final Color? color;
  final double size;
  final void Function()? onTap;
  final double? borderWidth;
  final Color borderColor;
  final double progress;

  @override
  State<DownloadIcon> createState() => _DownloadIconState();
}

class _DownloadIconState extends State<DownloadIcon> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              width: widget.borderWidth ?? 2, color: widget.borderColor),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            widget.icon,
            SizedBox(
              width: widget.size,
              height: widget.size,
              child: CustomPaint(
                painter: ArcPainter(percentage: widget.progress / 100),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ArcPainter extends CustomPainter {
  final double percentage;

  ArcPainter({required this.percentage});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.blue.withAlpha(128)
      ..strokeWidth = 5
      ..style = PaintingStyle.fill;

    double radius = math.min(size.width / 2, size.height / 2);
    Rect rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: radius,
    );

    double startAngle = -math.pi / 2;
    double sweepAngle = 2 * math.pi * percentage;

    canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

Stream<int> changeNumber() async* {
  for (int i = 1; i <= 100; i++) {
    await Future.delayed(const Duration(milliseconds: 50));
    yield i;
  }
}
