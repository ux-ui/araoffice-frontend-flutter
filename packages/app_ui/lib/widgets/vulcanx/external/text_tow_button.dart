import 'package:flutter/material.dart';

class TextTwoButton extends StatefulWidget {
  final String leftLabel;
  final String rightLabel;
  final VoidCallback? onTap;
  const TextTwoButton({
    super.key,
    required this.leftLabel,
    required this.rightLabel,
    this.onTap,
  });

  @override
  State<TextTwoButton> createState() => _TextTwoButtonState();
}

class _TextTwoButtonState extends State<TextTwoButton> {
  Color _backgroundColor = Colors.transparent; // 초기 배경색

  void _onEnter(PointerEvent details) {
    setState(() {
      _backgroundColor = Colors.grey.withAlpha(77); // 마우스가 올라갔을 때 색상
    });
  }

  void _onExit(PointerEvent details) {
    setState(() {
      _backgroundColor = Colors.transparent; // 마우스가 벗어났을 때 색상
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: _onEnter,
        onExit: _onExit,
        child: Container(
          decoration: BoxDecoration(
            color: _backgroundColor, // 배경색 변경
            borderRadius: BorderRadius.circular(8), // 라운드 처리
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.leftLabel),
                Text(widget.rightLabel),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
