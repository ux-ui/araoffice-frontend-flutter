import 'package:flutter/material.dart';

import '../../common/constants.dart';
import '../../theme/theme_extension.dart';

class PenColorPicker extends StatefulWidget {
  final double? strokeWidth;
  final double minWidth;
  final double maxWidth;
  final Color? strokeColor;
  final Axis direction;
  final void Function(double width) onWidthSelected;
  final void Function(Color color) onColorSelected;

  const PenColorPicker({
    super.key,
    this.strokeWidth,
    this.minWidth = 1.0,
    this.maxWidth = 10.0,
    this.strokeColor,
    this.direction = Axis.vertical,
    required this.onWidthSelected,
    required this.onColorSelected,
  });

  @override
  PenColorPickerState createState() => PenColorPickerState();
}

class PenColorPickerState extends State<PenColorPicker> {
  final _penColors = PenColorType.values.map((e) => e.color).toList();
  var _strokeWidth = kDefaultPenWidth;
  var _selectedIndex = -1;

  @override
  void initState() {
    _strokeWidth = widget.strokeWidth ?? kDefaultPenWidth;
    if (widget.strokeColor != null) {
      _selectedIndex = _penColors.indexWhere((e) => e == widget.strokeColor);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.direction == Axis.vertical) {
      return _buildVertical();
    } else {
      return _buildHorizontal();
    }
  }

  Widget _buildVertical() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            spreadRadius: 0,
            blurRadius: 8,
            offset: Offset(1, 4),
          ),
        ],
        shape: BoxShape.rectangle,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pen width
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      color: Colors.black,
                      width: 24,
                      height: _strokeWidth.round().toDouble(),
                    ),
                    const SizedBox(width: 5),
                    Text('${_strokeWidth.round().toString()}px',
                        style: context.labelLarge),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${widget.minWidth.round()}px',
                      style: context.labelMedium,
                    ),
                    SizedBox(
                      width: 100,
                      height: 16,
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4,
                          activeTrackColor: context.primary,
                          inactiveTrackColor: context.primaryContainer,
                          thumbColor: context.primary,
                          overlayColor: context.primary.withValues(alpha: 0.2),
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6),
                          overlayShape:
                              const RoundSliderOverlayShape(overlayRadius: 12),
                          // showValueIndicator: ShowValueIndicator.always,
                        ),
                        child: Slider(
                          value: _strokeWidth,
                          min: widget.minWidth,
                          max: widget.maxWidth,
                          label: _strokeWidth.round().toString(),
                          onChanged: (value) {
                            setState(() {
                              _strokeWidth = value;
                              widget.onWidthSelected(_strokeWidth);
                            });
                          },
                        ),
                      ),
                    ),
                    Text('${widget.maxWidth.round()}px',
                        style: context.labelMedium),
                  ],
                ),
              ],
            ),
          ),
          // Pen color
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            decoration: const BoxDecoration(
              border: Border(
                  top: BorderSide(
                color: Color(0xFFE1E1E1),
              )),
            ),
            width: 196,
            height: 196,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _penColors.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 14,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                      widget.onColorSelected(_penColors[index]);
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      color: _penColors[index],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedIndex == index
                            ? context.primary
                            : context.outline,
                        width: 2,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontal() {
    return Column(
      children: [
        // Pen width
        Container(
          margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    color: Colors.black,
                    width: 24,
                    height: _strokeWidth.round().toDouble(),
                  ),
                  const SizedBox(width: 5),
                  SizedBox(
                    width: 66,
                    child: Text('${_strokeWidth.round().toString()}px',
                        style: context.labelLarge),
                  ),
                  Text('${widget.minWidth.round()}px',
                      style: context.labelMedium),
                  Expanded(
                    child: SizedBox(
                      height: 16,
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4,
                          activeTrackColor: context.primary,
                          inactiveTrackColor: context.primaryContainer,
                          thumbColor: context.primary,
                          overlayColor: context.primary.withValues(alpha: 0.2),
                          overlayShape:
                              const RoundSliderOverlayShape(overlayRadius: 12),
                          // showValueIndicator: ShowValueIndicator.always,
                        ),
                        child: Slider(
                          value: _strokeWidth,
                          min: widget.minWidth,
                          max: widget.maxWidth,
                          // divisions: 1,
                          label: _strokeWidth.round().toString(),
                          onChanged: (value) {
                            setState(() {
                              _strokeWidth = value;
                              widget.onWidthSelected(_strokeWidth);
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  Text('${widget.maxWidth.round()}px',
                      style: context.labelMedium),
                ],
              ),
            ],
          ),
        ),
        Divider(height: 1, indent: 32, endIndent: 32, color: context.outline),
        // Pen color
        Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 7),
            itemCount: _penColors.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                    widget.onColorSelected(_penColors[index]);
                  });
                },
                child: Container(
                  margin: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    color: _penColors[index],
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _selectedIndex == index
                          ? context.primary
                          : context.outline,
                      width: 2,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
