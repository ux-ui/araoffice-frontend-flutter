import 'package:flutter/material.dart';

class HorizontalExpandableMenu extends StatefulWidget {
  final List<Widget> menuItems;

  const HorizontalExpandableMenu({
    super.key,
    required this.menuItems,
  });

  @override
  State<HorizontalExpandableMenu> createState() =>
      _HorizontalExpandableMenuState();
}

class _HorizontalExpandableMenuState extends State<HorizontalExpandableMenu> {
  bool _isExpanded = false;

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isExpanded ? (widget.menuItems.length * 40.0) : 0,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Row(
                children: widget.menuItems,
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(26),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon:
                  Icon(_isExpanded ? Icons.chevron_right : Icons.chevron_left),
              onPressed: _toggleExpand,
            ),
          ),
        ],
      ),
    );
  }
}

class EditorFloatingBar extends StatefulWidget {
  const EditorFloatingBar({super.key});

  @override
  State<EditorFloatingBar> createState() => _EditorFloatingBarState();
}

class _EditorFloatingBarState extends State<EditorFloatingBar> {
  Offset _offset = const Offset(100, 20); // 초기 위치

  void _updatePosition(Offset newOffset) {
    setState(() {
      _offset = newOffset;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _offset.dx,
      top: _offset.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          _updatePosition(_offset + details.delta);
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(26),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: HorizontalExpandableMenu(
            menuItems: [
              IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
              IconButton(icon: const Icon(Icons.copy), onPressed: () {}),
              IconButton(icon: const Icon(Icons.delete), onPressed: () {}),
              IconButton(icon: const Icon(Icons.share), onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
