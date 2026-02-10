import 'package:flutter/material.dart';

class UserCursorWidget extends StatelessWidget {
  final String userId;
  final double x;
  final double y;
  final double diffX;
  final double diffY;
  final double scale;
  final bool showRuler;

  const UserCursorWidget({
    super.key,
    required this.userId,
    required this.x,
    required this.y,
    required this.diffX,
    required this.diffY,
    required this.scale,
    required this.showRuler,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: showRuler
          ? diffX > 0
              ? x + diffX + (20 * scale)
              : x + (20 * scale)
          : diffX > 0
              ? x + diffX
              : x,
      // left: diffX > 0 ? x + diffX : x,
      // left: x,
      top: showRuler ? y + (20 * scale) : y,
      // top: diffY > 0 ? y + diffY : y,
      // top: y,
      child: Container(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 커서 아이콘
            Icon(
              Icons.mouse_sharp,
              // color: Colors.blue
              color: getColorForUserId(userId),
            ),
            // 사용자 아이디
            Text(
              userId,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

Color getColorForUserId(String userId) {
  final hash = userId.hashCode;
  final hue = (hash % 360).toDouble();
  return HSLColor.fromAHSL(1.0, hue, 0.7, 0.5).toColor();
}
