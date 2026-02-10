import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../../app_ui.dart';
import 'vulcan_x_stateful_widget.dart';

extension ColorExtension on Color {
  String toHexString() {
    return '0xff${toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  String toHexStringWithAlpha() {
    return '#${toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
  }
}

class VulcanXColorPickerWidget extends VulcanXStatefulWidget {
  final String label;
  final Color initialColor;
  final ValueChanged<Color>? onColorChanged;
  final VoidCallback? onConfirm;
  final VoidCallback? onCanceled;
  final AlignmentGeometry? alignment;

  const VulcanXColorPickerWidget({
    super.key,
    required this.label,
    required this.initialColor,
    this.onColorChanged,
    this.onConfirm,
    this.onCanceled,
    this.alignment,
  });

  @override
  VulcanXState<VulcanXColorPickerWidget> createState() =>
      _ColorPickerWidgetState();
}

class _ColorPickerWidgetState extends VulcanXState<VulcanXColorPickerWidget> {
  late final Rx<Color> _currentColor = Colors.black.withAlpha(100).obs;
  final TextEditingController hexController = TextEditingController();
  final TextEditingController opacityController = TextEditingController();
  final TextEditingController alphaController = TextEditingController();
  final TextEditingController alphaPercentController = TextEditingController();
  final TextEditingController redController = TextEditingController();
  final TextEditingController greenController = TextEditingController();
  final TextEditingController blueController = TextEditingController();
  ColorPickMode _colorPickMode = ColorPickMode.hex;
  StateSetter? _colorPickerSetState;
  final PopupMenuBarController _popupController = PopupMenuBarController();

  final saveColorList = [
    '0xFF000000', // 검정색
    '0xFFFFFFFF', // 흰색
    '0xFF808080', // 회색
    '0xFFFF0000', // 빨강
    '0xFFFF7F00', // 주황
    '0xFFFFFF00', // 노랑
    '0xFF00FF00', // 초록
    '0xFF0000FF', // 파랑
    '0xFF4B0082', // 남색
    '0xFF9400D3', // 보라
  ].obs;

  Widget _buildColorPickerContent() {
    return Material(
      elevation: 4.0,
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        height: 300,
        constraints: const BoxConstraints(
          minWidth: 100,
          maxWidth: 280,
        ),
        // padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.fromLTRB(12, 2, 12, 12),
        child: PointerInterceptor(
          child: StatefulBuilder(
            builder: (context, setInnerState) {
              _colorPickerSetState = setInnerState;
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          iconSize: 20,
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            _popupController.close();
                            if (widget.onCanceled != null) {
                              widget.onCanceled?.call();
                            } else {
                              widget.onColorChanged?.call(widget.initialColor);
                              _currentColor.value = widget.initialColor;
                              setState(() {});
                            }
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    Obx(
                      () => SimpleColorPicker(
                        initialColor: _currentColor.value,
                        onColorChanged: (Color color) {
                          if (mounted) {
                            _updateColor(color, setInnerState);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Radio<ColorPickMode>(
                              value: ColorPickMode.hex,
                              groupValue: _colorPickMode,
                              onChanged: (value) {
                                if (mounted) {
                                  setInnerState(() {
                                    _colorPickMode = value!;
                                  });
                                }
                              },
                            ),
                            const Text('Hex'),
                            const SizedBox(width: 8),
                            Radio<ColorPickMode>(
                              value: ColorPickMode.rgb,
                              groupValue: _colorPickMode,
                              onChanged: (value) {
                                if (mounted) {
                                  setInnerState(() {
                                    _colorPickMode = value!;
                                  });
                                }
                              },
                            ),
                            const Text('RGB'),
                          ],
                        ),
                        // ElevatedButton(
                        //   onPressed: () {
                        //     _popupController.close();
                        //     widget.onConfirm?.call();
                        //   },
                        //   child: Text('confirm'.tr),
                        // ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _colorPickMode == ColorPickMode.hex
                            ? Expanded(
                                child: TextField(
                                  controller: hexController,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 8),
                                    prefix: Text('#'),
                                  ),
                                  onChanged: _updateFromHex,
                                ),
                              )
                            : Expanded(
                                child: Row(
                                  children: [
                                    _buildColorInput('A', alphaController),
                                    const SizedBox(width: 4),
                                    _buildColorInput('R', redController),
                                    const SizedBox(width: 4),
                                    _buildColorInput('G', greenController),
                                    const SizedBox(width: 4),
                                    _buildColorInput('B', blueController),
                                  ],
                                ),
                              ),
                        if (_colorPickMode == ColorPickMode.hex) ...[
                          const SizedBox(width: 10),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: alphaPercentController,
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 8),
                                      labelText: 'color_alpha'.tr,
                                      suffixText: '%',
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    onChanged: _updateAlphaFromPercent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]
                      ],
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => ColorPaletteListWidget(
                        colors: saveColorList
                            .map((e) => Color(int.parse(e)))
                            .toList(),
                        onColorSelected: (value) => _updateColor(value),
                        addColor: () {
                          saveColorList.add(
                              '0xff${_currentColor.value.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}');
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _popupController.close();
                            widget.onConfirm?.call();
                          },
                          child: Text('confirm'.tr),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            _popupController.close();
                            if (widget.onCanceled != null) {
                              widget.onCanceled?.call();
                            } else {
                              widget.onColorChanged?.call(widget.initialColor);
                              _currentColor.value = widget.initialColor;
                              setState(() {});
                            }
                          },
                          child: Text('cancel'.tr),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _currentColor.value = widget.initialColor;
    _updateTextFields();
    _updateControllerValues();
    alphaPercentController.text =
        '${(_currentColor.value.alpha / 255 * 100).round()}';
  }

  void _updateControllerValues() {
    final argbStrings = convertColorToARGBString(_currentColor.value);
    alphaController.text = argbStrings['alpha'] ?? '255';
    redController.text = argbStrings['red'] ?? '0';
    greenController.text = argbStrings['green'] ?? '0';
    blueController.text = argbStrings['blue'] ?? '0';
  }

  @override
  void didUpdateWidget(covariant VulcanXColorPickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialColor != widget.initialColor) {
      _currentColor.value = widget.initialColor;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _updateTextFields();
            _updateControllerValues();
          });
          _colorPickerSetState?.call(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    alphaController.dispose();
    redController.dispose();
    greenController.dispose();
    blueController.dispose();
    hexController.dispose();
    opacityController.dispose();
    alphaPercentController.dispose();
    _colorPickerSetState = null;
    super.dispose();
  }

  Color createColorFromARGB(int a, int r, int g, int b) {
    return Color.fromARGB(
      a.clamp(0, 255),
      r.clamp(0, 255),
      g.clamp(0, 255),
      b.clamp(0, 255),
    );
  }

  Map<String, int> convertColorToARGB(Color color) {
    return {
      'alpha': (color.a * 255.0).round() & 0xff,
      'red': (color.r * 255.0).round() & 0xff,
      'green': (color.g * 255.0).round() & 0xff,
      'blue': (color.b * 255.0).round() & 0xff,
    };
  }

  Map<String, String> convertColorToARGBString(Color color) {
    return {
      'alpha': ((color.a * 255.0).round() & 0xff).toString(),
      'red': ((color.r * 255.0).round() & 0xff).toString(),
      'green': ((color.g * 255.0).round() & 0xff).toString(),
      'blue': ((color.b * 255.0).round() & 0xff).toString(),
    };
  }

  Color? createColorFromARGBString(String a, String r, String g, String b) {
    try {
      final alpha = int.parse(a);
      final red = int.parse(r);
      final green = int.parse(g);
      final blue = int.parse(b);
      return createColorFromARGB(alpha, red, green, blue);
    } catch (e) {
      return null;
    }
  }

  void _updateTextFields() {
    hexController.text = _currentColor.value
        .toARGB32()
        .toRadixString(16)
        .toUpperCase()
        .padLeft(8, '0')
        .substring(2);
    opacityController.text = (_currentColor.value.a * 100).round().toString();
    final argb = convertColorToARGBString(_currentColor.value);
    alphaController.text = argb['alpha']!;
    redController.text = argb['red']!;
    greenController.text = argb['green']!;
    blueController.text = argb['blue']!;
    alphaPercentController.text =
        '${(_currentColor.value.alpha / 255 * 100).round()}';
  }

  void _updateColor(Color color, [StateSetter? setInnerState]) {
    setState(() {
      _currentColor.value = color;
      debugPrint('#########color: ${color.toARGB32().toRadixString(16)}');
      widget.onColorChanged?.call(color);
      _updateTextFields();
      _updateControllerValues();
      setInnerState?.call(() {});
      if (_colorPickerSetState != null) {
        _colorPickerSetState!(() {});
      }
    });
  }

  void _updateFromHex(String hexValue) {
    if (hexValue.length == 6) {
      try {
        final color = Color(int.parse('FF$hexValue', radix: 16));
        _updateColor(color);
      } catch (e) {
        debugPrint('Invalid hex color');
      }
    }
  }

  void _updateColorFromControllers() {
    if (alphaController.text.isEmpty ||
        redController.text.isEmpty ||
        greenController.text.isEmpty ||
        blueController.text.isEmpty) {
      return;
    }

    final color = createColorFromARGBString(
      alphaController.text,
      redController.text,
      greenController.text,
      blueController.text,
    );

    if (color != null) {
      setState(() {
        _currentColor.value = color;
        widget.onColorChanged?.call(color);
        // RGB 입력 중일 때는 텍스트 필드를 덮어쓰지 않음
        // _updateTextFields();
      });
    }
  }

  void _updateAlphaFromPercent(String value) {
    if (value.isEmpty) return;
    if (!RegExp(r'^\d+$').hasMatch(value)) return;

    final percent = int.parse(value).clamp(0, 100);
    final alpha = percent / 100;

    final currentPosition = alphaPercentController.selection.baseOffset;

    setState(() {
      _currentColor.value = _currentColor.value.withOpacity(alpha);
      widget.onColorChanged?.call(_currentColor.value);
      _updateTextFields();
      _updateControllerValues();
      if (_colorPickerSetState != null) {
        _colorPickerSetState!(() {
          // SimpleColorPicker의 상태 업데이트
          final simpleColorPicker =
              context.findAncestorStateOfType<_SimpleColorPickerState>();
          if (simpleColorPicker != null) {
            simpleColorPicker.setState(() {
              simpleColorPicker._currentHsvColor =
                  HSVColor.fromColor(_currentColor.value);
            });
          }
        });
      }
    });

    // 커서 위치 복원
    if (currentPosition != -1) {
      alphaPercentController.selection = TextSelection.fromPosition(
        TextPosition(offset: currentPosition),
      );
    }
  }

  // Widget _buildColorInput(String label, TextEditingController controller) {
  //   return Expanded(
  //     child: TextField(
  //       controller: controller,
  //       keyboardType: TextInputType.number,
  //       decoration: InputDecoration(
  //         labelText: label,
  //         contentPadding:
  //             const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
  //         border: const OutlineInputBorder(),
  //       ),
  //       onEditingComplete: () {
  //         _updateColorFromControllers();
  //         FocusScope.of(context).unfocus();
  //       },
  //       onChanged: (value) {
  //         final currentPosition = controller.selection.baseOffset;

  //         if (value.isEmpty) return;
  //         if (!RegExp(r'^[0-9]+$').hasMatch(value)) return;

  //         final number = int.parse(value);
  //         if (number > 255) {
  //           controller.value = const TextEditingValue(
  //             text: '255',
  //             selection: TextSelection.collapsed(offset: 3),
  //           );
  //         } else {
  //           controller.selection =
  //               TextSelection.collapsed(offset: currentPosition);
  //         }

  //         // RGB 값이 변경될 때마다 실시간으로 색상 업데이트
  //         _updateColorFromControllers();
  //       },
  //     ),
  //   );
  // }

  Widget _buildColorInput(String label, TextEditingController controller) {
    return Expanded(
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          border: const OutlineInputBorder(),
        ),
        onEditingComplete: () {
          _updateColorFromControllers();
          FocusScope.of(context).unfocus();
        },
        onChanged: (value) {
          final currentPosition = controller.selection.baseOffset;

          if (value.isEmpty) {
            // _updateColorFromControllers();
            return;
          }

          if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
            return;
          }

          final number = int.tryParse(value);

          if (number != null && number > 255) {
            // 255 초과 입력 시 '255'로 고정
            controller.value = const TextEditingValue(
              text: '255',
              selection: TextSelection.collapsed(offset: 3),
            );
          } else {
            // 커서 위치 유지
            controller.selection =
                TextSelection.collapsed(offset: currentPosition);
          }

          // 모든 컨트롤러의 값이 유효할 때만 색상 업데이트
          if (int.tryParse(alphaController.text) != null &&
              int.tryParse(redController.text) != null &&
              int.tryParse(greenController.text) != null &&
              int.tryParse(blueController.text) != null) {
            // _updateColorFromControllers();
            setState(() {
              _currentColor.value = createColorFromARGBString(
                alphaController.text,
                redController.text,
                greenController.text,
                blueController.text,
              )!;
            });
            widget.onColorChanged?.call(_currentColor.value);
          }
        },
      ),
    );
  }

  @override
  Widget buildWithTheme(BuildContext context, ThemeData themeData) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(widget.label),
        PopupMenuBar(
          controller: _popupController,
          alignmentGeometry: widget.alignment ?? Alignment.topLeft,
          onMenuStateChanged: (showMenu) async {
            if (!showMenu) {
              widget.onCanceled?.call();
            }
            return true;
          },
          content: _buildColorPickerContent(),
          child: VulcanXOutlinedButton.icon(
            width: 74,
            height: 40,
            onPressed: null,
            icon: Icon(Icons.square, color: _currentColor.value),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Text(_currentColor.value
                  .toARGB32()
                  .toRadixString(16)
                  .padLeft(8, '0')
                  .substring(2)),
            ),
          ),
        ),
      ],
    );
  }
}

enum ColorPickMode {
  hex,
  rgb,
}

class ColorPaletteListWidget extends StatefulWidget {
  final List<Color> colors;
  final Function(Color) onColorSelected;
  final Function() addColor;

  const ColorPaletteListWidget({
    super.key,
    required this.colors,
    required this.onColorSelected,
    required this.addColor,
  });

  @override
  ColorPaletteListWidgetState createState() => ColorPaletteListWidgetState();
}

class ColorPaletteListWidgetState extends State<ColorPaletteListWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('color_palette'.tr),
              TextButton(
                onPressed: widget.addColor,
                child: Text('add_color'.tr),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: widget.colors.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  return _buildColorPaletteItem(widget.colors[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPaletteItem(Color color) {
    return GestureDetector(
      onTap: () => widget.onColorSelected(color),
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border:
              Border.all(color: Colors.black.withValues(alpha: 0.5), width: 1),
        ),
      ),
    );
  }
}

class SimpleColorPicker extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;

  const SimpleColorPicker({
    super.key,
    required this.initialColor,
    required this.onColorChanged,
  });

  @override
  State<SimpleColorPicker> createState() => _SimpleColorPickerState();
}

class _SimpleColorPickerState extends State<SimpleColorPicker> {
  late HSVColor _currentHsvColor;
  final GlobalKey _pickerKey = GlobalKey();
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _currentHsvColor = HSVColor.fromColor(widget.initialColor);
  }

  @override
  void didUpdateWidget(SimpleColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialColor != oldWidget.initialColor) {
      setState(() {
        _currentHsvColor = HSVColor.fromColor(widget.initialColor);
      });
    }
  }

  void _handleSliderInteraction(Offset position) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(position);
    final width = box.size.width;

    setState(() {
      _currentHsvColor = HSVColor.fromAHSV(
        _currentHsvColor.alpha,
        (localPosition.dx / width * 360).clamp(0.0, 360.0),
        _currentHsvColor.saturation,
        _currentHsvColor.value,
      );
      widget.onColorChanged(_currentHsvColor.toColor());
    });
  }

  void _handleAlphaChange(double alpha) {
    setState(() {
      _currentHsvColor = _currentHsvColor.withAlpha(alpha);
      widget.onColorChanged(_currentHsvColor.toColor());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          key: _pickerKey,
          width: 232,
          height: 152,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: GestureDetector(
                    onPanDown: (details) {
                      final RenderBox box = _pickerKey.currentContext!
                          .findRenderObject() as RenderBox;
                      final localPosition =
                          box.globalToLocal(details.globalPosition);
                      final width = box.size.width;
                      final height = box.size.height;

                      final dx = localPosition.dx.clamp(0.0, width);
                      final dy = localPosition.dy.clamp(0.0, height);

                      setState(() {
                        _currentHsvColor = HSVColor.fromAHSV(
                          _currentHsvColor.alpha,
                          _currentHsvColor.hue,
                          dx / width,
                          1 - (dy / height),
                        );
                        widget.onColorChanged(_currentHsvColor.toColor());
                      });
                    },
                    onPanUpdate: (details) {
                      final RenderBox box = _pickerKey.currentContext!
                          .findRenderObject() as RenderBox;
                      final localPosition =
                          box.globalToLocal(details.globalPosition);
                      final width = box.size.width;
                      final height = box.size.height;

                      final dx = localPosition.dx.clamp(0.0, width);
                      final dy = localPosition.dy.clamp(0.0, height);

                      setState(() {
                        _currentHsvColor = HSVColor.fromAHSV(
                          _currentHsvColor.alpha,
                          _currentHsvColor.hue,
                          dx / width,
                          1 - (dy / height),
                        );
                        widget.onColorChanged(_currentHsvColor.toColor());
                      });
                    },
                    child: CustomPaint(
                      painter: _ColorPickerPainter(
                        _currentHsvColor.hue,
                        saturation: _currentHsvColor.saturation,
                        value: _currentHsvColor.value,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: 232,
          height: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                for (double hue = 0; hue <= 360; hue += 360 / 6)
                  HSVColor.fromAHSV(1, hue, 1, 1).toColor(),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (event) {
                    _isDragging = true;
                    _handleSliderInteraction(event.position);
                  },
                  onPointerMove: (event) {
                    if (_isDragging) {
                      _handleSliderInteraction(event.position);
                    }
                  },
                  onPointerUp: (event) {
                    _isDragging = false;
                  },
                  child: Container(),
                ),
              ),
              Positioned(
                left: (_currentHsvColor.hue / 360 * 232).clamp(5.5, 228.5) - 6,
                child: Listener(
                  onPointerDown: (event) {
                    _isDragging = true;
                    _handleSliderInteraction(event.position);
                  },
                  onPointerMove: (event) {
                    if (_isDragging) {
                      _handleSliderInteraction(event.position);
                    }
                  },
                  onPointerUp: (event) {
                    _isDragging = false;
                  },
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _currentHsvColor.toColor(),
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 2,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: 232,
          height: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              CheckerboardBackground(
                borderRadius: BorderRadius.circular(15.0),
                squareSize: 8.0,
                lightColor: const Color(0xFFFFFFFF),
                darkColor: const Color(0xFFEEEEEE),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      _currentHsvColor.toColor().withValues(alpha: 0),
                      _currentHsvColor.toColor(),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Listener(
                        behavior: HitTestBehavior.opaque,
                        onPointerDown: (event) {
                          _isDragging = true;
                          final RenderBox box =
                              context.findRenderObject() as RenderBox;
                          final localPosition =
                              box.globalToLocal(event.position);
                          final width = box.size.width;

                          setState(() {
                            _currentHsvColor = _currentHsvColor.withAlpha(
                              (localPosition.dx / width).clamp(0.0, 1.0),
                            );
                            widget.onColorChanged(_currentHsvColor.toColor());
                          });
                        },
                        onPointerMove: (event) {
                          if (_isDragging) {
                            final RenderBox box =
                                context.findRenderObject() as RenderBox;
                            final localPosition =
                                box.globalToLocal(event.position);
                            final width = box.size.width;

                            setState(() {
                              _currentHsvColor = _currentHsvColor.withAlpha(
                                (localPosition.dx / width).clamp(0.0, 1.0),
                              );
                              widget.onColorChanged(_currentHsvColor.toColor());
                            });
                          }
                        },
                        onPointerUp: (event) {
                          _isDragging = false;
                        },
                        child: Container(),
                      ),
                    ),
                    Positioned(
                      left:
                          (_currentHsvColor.alpha * 232).clamp(5.5, 228.5) - 6,
                      child: Listener(
                        onPointerDown: (event) {
                          _isDragging = true;
                          final RenderBox box =
                              context.findRenderObject() as RenderBox;
                          final localPosition =
                              box.globalToLocal(event.position);
                          final width = box.size.width;

                          setState(() {
                            _currentHsvColor = _currentHsvColor.withAlpha(
                              (localPosition.dx / width).clamp(0.0, 1.0),
                            );
                            widget.onColorChanged(_currentHsvColor.toColor());
                          });
                        },
                        onPointerMove: (event) {
                          if (_isDragging) {
                            final RenderBox box =
                                context.findRenderObject() as RenderBox;
                            final localPosition =
                                box.globalToLocal(event.position);
                            final width = box.size.width;

                            setState(() {
                              _currentHsvColor = _currentHsvColor.withAlpha(
                                (localPosition.dx / width).clamp(0.0, 1.0),
                              );
                              widget.onColorChanged(_currentHsvColor.toColor());
                            });
                          }
                        },
                        onPointerUp: (event) {
                          _isDragging = false;
                        },
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _currentHsvColor.toColor(),
                            border: Border.all(color: Colors.white, width: 2),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.4),
                                blurRadius: 2,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _ColorPickerPainter extends CustomPainter {
  final double hue;
  final double saturation;
  final double value;

  _ColorPickerPainter(
    this.hue, {
    this.saturation = 0.0,
    this.value = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // HSV 색상 공간을 제대로 표현하기 위한 그라데이션
    // 가로축: 채도(Saturation) - 흰색에서 순수 색상으로
    // 세로축: 명도(Value) - 밝은 색상에서 어두운 색상으로

    final width = size.width;
    final height = size.height;

    // 각 세로줄마다 해당 채도에 맞는 색상 그라데이션 그리기
    for (int x = 0; x < width.toInt(); x++) {
      final saturation = x / width;

      // 세로 방향 그라데이션 (명도)
      final topGradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          // 위쪽: 높은 명도 (V=1.0) - 밝은 색상
          HSVColor.fromAHSV(1.0, hue, saturation, 1.0).toColor(),
          // 아래쪽: 낮은 명도 (V=0.0) - 어두운 색상
          HSVColor.fromAHSV(1.0, hue, saturation, 0.0).toColor(),
        ],
      ).createShader(Rect.fromLTWH(x.toDouble(), 0, 1, height));

      canvas.drawRect(
        Rect.fromLTWH(x.toDouble(), 0, 1, height),
        Paint()..shader = topGradient,
      );
    }

    // 포인터 그리기
    final pointerX = saturation * size.width;
    final pointerY = (1 - value) * size.height;
    final pointerRadius = 6.0;

    // 흰색 테두리
    canvas.drawCircle(
      Offset(pointerX, pointerY),
      pointerRadius,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // 검은색 그림자
    canvas.drawCircle(
      Offset(pointerX, pointerY),
      pointerRadius - 1,
      Paint()
        ..color = Colors.black.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(_ColorPickerPainter oldDelegate) =>
      hue != oldDelegate.hue ||
      saturation != oldDelegate.saturation ||
      value != oldDelegate.value;
}

class ChessboardPatternPainter extends CustomPainter {
  final double squareSize;
  final Color lightColor;
  final Color darkColor;

  ChessboardPatternPainter({
    this.squareSize = 10.0,
    this.lightColor = const Color(0xFFFFFFFF),
    this.darkColor = const Color(0xFFCCCCCC),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint lightPaint = Paint()..color = lightColor;
    final Paint darkPaint = Paint()..color = darkColor;

    final int numRows = (size.height / squareSize).ceil();
    final int numCols = (size.width / squareSize).ceil();

    for (int r = 0; r < numRows; r++) {
      for (int c = 0; c < numCols; c++) {
        final double left = c * squareSize;
        final double top = r * squareSize;
        final double right = min(left + squareSize, size.width);
        final double bottom = min(top + squareSize, size.height);

        final Rect rect = Rect.fromLTRB(left, top, right, bottom);

        if ((r + c) % 2 == 0) {
          canvas.drawRect(rect, lightPaint);
        } else {
          canvas.drawRect(rect, darkPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant ChessboardPatternPainter oldDelegate) {
    return oldDelegate.squareSize != squareSize ||
        oldDelegate.lightColor != lightColor ||
        oldDelegate.darkColor != darkColor;
  }
}

class CheckerboardBackground extends StatelessWidget {
  final double? width;
  final double? height;
  final double squareSize;
  final Color lightColor;
  final Color darkColor;
  final BorderRadius? borderRadius;

  const CheckerboardBackground({
    super.key,
    this.width,
    this.height,
    this.squareSize = 8.0,
    this.lightColor = const Color(0xFFFFFFFF),
    this.darkColor = const Color(0xFFEEEEEE),
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget checkerboard = CustomPaint(
      painter: ChessboardPatternPainter(
        squareSize: squareSize,
        lightColor: lightColor,
        darkColor: darkColor,
      ),
      size: width != null && height != null
          ? Size(width!, height!)
          : Size.infinite,
    );

    if (borderRadius != null) {
      checkerboard = ClipRRect(
        borderRadius: borderRadius!,
        child: checkerboard,
      );
    }

    if (width != null || height != null) {
      return SizedBox(
        width: width,
        height: height,
        child: checkerboard,
      );
    }

    return checkerboard;
  }
}
