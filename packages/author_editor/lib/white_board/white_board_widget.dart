import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class CursorTrailPainter extends CustomPainter {
  final List<Offset> points;
  final List<Offset> newPoints;
  final String userId;
  final Color color;
  final ui.Image? cachedImage;
  final double scale;
  final double diffX;
  final double diffY;

  CursorTrailPainter({
    required this.points,
    required this.newPoints,
    required this.userId,
    required this.color,
    required this.scale,
    required this.diffX,
    required this.diffY,
    this.cachedImage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 캐시된 이미지가 있으면 먼저 그리기
    if (cachedImage != null) {
      canvas.drawImage(cachedImage!, Offset.zero, Paint());
    }

    // 실시간 포인트 그리기
    if (newPoints.length >= 2) {
      final paint = Paint()
        ..color = color
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final transformedPoints = newPoints
          .map((point) => Offset(
                point.dx * (20 * scale) + diffX,
                point.dy * (20 * scale) + diffY,
                // point.dx * scale + diffX,
                // point.dy * scale + diffY,
              ))
          .toList();

      for (int i = 0; i < transformedPoints.length - 1; i++) {
        canvas.drawLine(
          transformedPoints[i],
          transformedPoints[i + 1],
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CursorTrailPainter oldDelegate) {
    return oldDelegate.newPoints != newPoints ||
        oldDelegate.cachedImage != cachedImage;
  }
}

class CursorTrailWidget extends StatefulWidget {
  final String userId;
  final double x;
  final double y;
  final double diffX;
  final double diffY;
  final double scale;
  final bool showRuler;
  final List<Offset> points;
  final List<Offset> newPoints;
  final Color cursorColor;

  const CursorTrailWidget({
    super.key,
    required this.userId,
    required this.x,
    required this.y,
    required this.diffX,
    required this.diffY,
    required this.scale,
    required this.showRuler,
    required this.points,
    required this.newPoints,
    this.cursorColor = Colors.black,
  });

  @override
  State<CursorTrailWidget> createState() => _CursorTrailWidgetState();
}

class _CursorTrailWidgetState extends State<CursorTrailWidget> {
  ui.Image? _cachedImage;

  @override
  void dispose() {
    _cachedImage?.dispose();
    super.dispose();
  }

  Future<ui.Image?> _updateCache(Size size) async {
    if (size.isEmpty) return null;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // 캔버스 초기화
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = Colors.transparent,
    );

    // 기존 캐시된 이미지 그리기
    if (_cachedImage != null) {
      canvas.drawImage(_cachedImage!, Offset.zero, Paint());
    }

    // 새로운 포인트 그리기
    if (widget.newPoints.length >= 2) {
      final paint = Paint()
        ..color = widget.cursorColor
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final transformedPoints = widget.newPoints
          .map((point) => Offset(
                point.dx * widget.scale + widget.diffX,
                point.dy * widget.scale + widget.diffY,
              ))
          .toList();

      for (int i = 0; i < transformedPoints.length - 1; i++) {
        canvas.drawLine(
          transformedPoints[i],
          transformedPoints[i + 1],
          paint,
        );
      }
    }

    final picture = recorder.endRecording();
    return await picture.toImage(
      size.width.toInt(),
      size.height.toInt(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return FutureBuilder<ui.Image?>(
          future: _updateCache(constraints.biggest),
          builder: (context, snapshot) {
            return Stack(
              children: [
                // 전체 화면 크기의 CustomPaint
                SizedBox.expand(
                  child: CustomPaint(
                    painter: CursorTrailPainter(
                      points: widget.points,
                      newPoints: widget.newPoints,
                      userId: widget.userId,
                      color: widget.cursorColor,
                      cachedImage: snapshot.data,
                      scale: widget.scale,
                      diffX: widget.diffX,
                      diffY: widget.diffY,
                    ),
                  ),
                ),
                // 현재 커서 위치
                // Positioned(
                //   left: (widget.x * widget.scale + widget.diffX),
                //   top: (widget.y * widget.scale + widget.diffY),
                //   child: Container(
                //     padding: const EdgeInsets.symmetric(
                //       horizontal: 8,
                //       vertical: 4,
                //     ),
                //     decoration: BoxDecoration(
                //       color: widget.cursorColor.withOpacity(0.8),
                //       borderRadius: BorderRadius.circular(4),
                //     ),
                //     child: Column(
                //       children: [
                //         Text(
                //           widget.userId,
                //           style: const TextStyle(
                //             color: Colors.white,
                //             fontSize: 12,
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            );
          },
        );
      },
    );
  }
}
