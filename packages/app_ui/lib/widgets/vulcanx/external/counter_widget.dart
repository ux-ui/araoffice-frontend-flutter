import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ValueUnitPair {
  final double value;
  final String unit;

  const ValueUnitPair(this.value, this.unit);

  @override
  String toString() => 'ValueUnitPair(value: $value, unit: $unit)';
}

class UnitConfig {
  final String unit;
  final double stepValue;
  final int decimalPlaces;

  const UnitConfig({
    required this.unit,
    required this.stepValue,
    required this.decimalPlaces,
  });

  @override
  String toString() =>
      'UnitConfig(unit: $unit, stepValue: $stepValue, decimalPlaces: $decimalPlaces)';
}

class CounterWidget extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String>? onChanged;
  final double width;
  final double height;
  final double buttonWidth;
  final double numberWidth;
  final double minValue;
  final double? maxValue;
  final String? text;
  final double? spacing;
  final String? unit; // Added: unit option
  final UnitConfig? unitConfig;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;

  static const defaultUnitConfigs = {
    'px': UnitConfig(unit: 'px', stepValue: 1.0, decimalPlaces: 0),
    '%': UnitConfig(unit: '%', stepValue: 10.0, decimalPlaces: 0),
    'em': UnitConfig(unit: 'em', stepValue: 0.1, decimalPlaces: 1),
  };

  const CounterWidget({
    super.key,
    this.initialValue = '16px',
    this.onChanged,
    this.width = 120,
    this.height = 40,
    this.buttonWidth = 38,
    this.numberWidth = 40,
    this.minValue = 0,
    this.maxValue,
    this.text,
    this.spacing = 8.0,
    this.unit,
    this.unitConfig,
    this.focusNode,
    this.inputFormatters,
  });

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  late TextEditingController textEditingController;
  late double _count;
  late ValueUnitPair valueUnitPair;
  late final FocusNode _focusNode;
  String? _rawInput;
  late UnitConfig _currentUnitConfig;

  UnitConfig _getUnitConfig(String unit) {
    // unitConfig가 있고 해당 unit과 일치하면 unitConfig 사용
    if (widget.unitConfig != null && widget.unitConfig!.unit == unit) {
      return widget.unitConfig!;
    }
    // 그렇지 않으면 기본 설정 사용
    return CounterWidget.defaultUnitConfigs[unit] ??
        const UnitConfig(unit: 'px', stepValue: 1.0, decimalPlaces: 0);
  }

  String _getEffectiveUnit(String defaultUnit) {
    // unitConfig가 있으면 해당 unit 사용
    if (widget.unitConfig != null) {
      return widget.unitConfig!.unit;
    }
    // unit 옵션이 있으면 해당 unit 사용
    if (widget.unit != null) {
      return widget.unit!;
    }
    // 둘 다 없으면 기본값 사용
    return defaultUnit;
  }

  String _formatNumber(double value, String unit) {
    final config = _getUnitConfig(unit);
    return value.toStringAsFixed(config.decimalPlaces);
  }

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    valueUnitPair = parseValueUnit(widget.initialValue);

    // 유효한 unit 결정
    final effectiveUnit = _getEffectiveUnit(valueUnitPair.unit);
    valueUnitPair = ValueUnitPair(valueUnitPair.value, effectiveUnit);

    _currentUnitConfig = _getUnitConfig(valueUnitPair.unit);
    _count = valueUnitPair.value;

    if (_count < widget.minValue) {
      _count = widget.minValue;
    } else if (widget.maxValue != null && _count > widget.maxValue!) {
      _count = widget.maxValue!;
    }

    final formattedValue = _formatNumber(_count, valueUnitPair.unit);
    textEditingController =
        TextEditingController(text: '$formattedValue${valueUnitPair.unit}');

    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    textEditingController.dispose();
    _focusNode.removeListener(_handleFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      _validateAndUpdateValue();
    }
  }

  void _validateAndUpdateValue() {
    if (_rawInput == null) return;

    try {
      final newValueUnitPair = parseValueUnit(_rawInput!);
      final effectiveUnit = _getEffectiveUnit(newValueUnitPair.unit);
      double newValue = newValueUnitPair.value;

      if (newValue < widget.minValue) {
        newValue = widget.minValue;
      } else if (widget.maxValue != null && newValue > widget.maxValue!) {
        newValue = widget.maxValue!;
      }

      final formattedValue = _formatNumber(newValue, effectiveUnit);
      final newText = '$formattedValue$effectiveUnit';

      setState(() {
        valueUnitPair = ValueUnitPair(newValue, effectiveUnit);
        _currentUnitConfig = _getUnitConfig(effectiveUnit);
        _count = newValue;
        textEditingController.text = newText;
      });

      widget.onChanged?.call(newText);
    } catch (e) {
      final formattedValue = _formatNumber(_count, valueUnitPair.unit);
      textEditingController.text = '$formattedValue${valueUnitPair.unit}';
    }

    _rawInput = null;
  }

  @override
  void didUpdateWidget(covariant CounterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue ||
        widget.unit != oldWidget.unit ||
        widget.unitConfig != oldWidget.unitConfig) {
      final initialValue = (widget.initialValue.isEmpty)
          ? oldWidget.initialValue
          : widget.initialValue;
      valueUnitPair = parseValueUnit(initialValue);

      final effectiveUnit = _getEffectiveUnit(valueUnitPair.unit);
      valueUnitPair = ValueUnitPair(valueUnitPair.value, effectiveUnit);

      _currentUnitConfig = _getUnitConfig(valueUnitPair.unit);
      _count = valueUnitPair.value;

      if (_count < widget.minValue) {
        _count = widget.minValue;
      } else if (widget.maxValue != null && _count > widget.maxValue!) {
        _count = widget.maxValue!;
      }

      final formattedValue = _formatNumber(_count, valueUnitPair.unit);
      textEditingController.text = '$formattedValue${valueUnitPair.unit}';
      _focusNode.unfocus();
    }
  }

  void _increment() {
    if (widget.maxValue != null &&
        _count + _currentUnitConfig.stepValue > widget.maxValue!) {
      return;
    }

    setState(() {
      _count += _currentUnitConfig.stepValue;
      final formattedValue = _formatNumber(_count, valueUnitPair.unit);
      final newValue = '$formattedValue${valueUnitPair.unit}';
      textEditingController.text = newValue;
      widget.onChanged?.call(newValue);
    });
  }

  void _decrement() {
    if (_count - _currentUnitConfig.stepValue < widget.minValue) {
      return;
    }

    setState(() {
      _count -= _currentUnitConfig.stepValue;
      final formattedValue = _formatNumber(_count, valueUnitPair.unit);
      final newValue = '$formattedValue${valueUnitPair.unit}';
      textEditingController.text = newValue;
      widget.onChanged?.call(newValue);
    });
  }

  ValueUnitPair parseValueUnit(String input) {
    if (input.isEmpty) {
      throw const FormatException('Input string cannot be empty');
    }

    final RegExp regex = RegExp(r'^(-?\d*\.?\d+)([a-zA-Z%]*)$');
    final match = regex.firstMatch(input);

    if (match == null) {
      throw FormatException('Invalid format: $input');
    }

    final value = double.parse(match.group(1)!);
    final unit = match.group(2)!;

    return ValueUnitPair(value, unit);
  }

  Widget _buildButton({
    required VoidCallback onPressed,
    required Widget child,
    required double width,
  }) {
    return SizedBox(
      width: width,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          height: widget.height,
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget counterWidget = Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildButton(
              onPressed: _decrement,
              child: const Icon(Icons.remove, size: 16),
              width: widget.buttonWidth,
            ),
            VerticalDivider(
              width: 1,
              color: Colors.grey[300],
            ),
            Expanded(
              child: TextField(
                controller: textEditingController,
                focusNode: _focusNode,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(bottom: 8.0),
                ),
                style: Theme.of(context).textTheme.bodyMedium,
                onChanged: (value) {
                  _rawInput = value;
                },
                onSubmitted: (value) {
                  _validateAndUpdateValue();
                },
                inputFormatters: widget.inputFormatters,
              ),
            ),
            VerticalDivider(
              width: 1,
              color: Colors.grey[300],
            ),
            _buildButton(
              onPressed: _increment,
              child: const Icon(Icons.add, size: 16),
              width: widget.buttonWidth,
            ),
          ],
        ),
      ),
    );

    if (widget.text != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.text!),
          SizedBox(width: widget.spacing!),
          counterWidget,
        ],
      );
    }

    return counterWidget;
  }
}
