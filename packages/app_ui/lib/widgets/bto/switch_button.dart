import 'package:flutter/material.dart';

import '../../app_ui.dart';

class BtoSwitchBtn extends StatefulWidget {
  const BtoSwitchBtn(
      {required this.onChanged,
      this.initValue = false,
      this.activeColor,
      this.inactiveColor,
      this.activeTrackColor,
      this.inactiveTrackColor,
      this.activeThumbColor,
      this.inactiveThumbColor,
      this.disabled,
      super.key});

  final Function(bool) onChanged;
  final bool initValue;
  final bool? disabled;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? activeTrackColor;
  final Color? inactiveTrackColor;
  final Color? activeThumbColor;
  final Color? inactiveThumbColor;

  @override
  State<BtoSwitchBtn> createState() => _BtoSwitchBtnState();
}

class _BtoSwitchBtnState extends State<BtoSwitchBtn> {
  bool isSwitched = false;

  @override
  void initState() {
    super.initState();
    isSwitched = widget.initValue;
  }

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: isSwitched,
      inactiveThumbColor: widget.disabled ?? false
          ? const Color(0xff00A5AE)
          : context.outlineVariant,
      inactiveTrackColor: context.surfaceVariant.withAlpha(128),
      activeTrackColor: widget.disabled ?? false
          ? context.primaryFixedDim.withAlpha(128)
          : context.primaryFixedDim.withAlpha(128),
      activeColor: widget.disabled ?? false ? context.primary : context.primary,
      trackOutlineWidth: WidgetStateProperty.all(0.0),
      trackOutlineColor:
          WidgetStateColor.resolveWith((states) => Colors.transparent),
      onChanged: widget.disabled ?? false
          ? null
          : (value) {
              setState(() {
                isSwitched = value;
                widget.onChanged(value)?.call();
              });
            },
    );
  }
}
