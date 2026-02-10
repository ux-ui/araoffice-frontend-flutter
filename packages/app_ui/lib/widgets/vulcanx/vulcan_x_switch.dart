import 'package:flutter/material.dart';

import '../../app_ui.dart';
import 'vulcan_x_stateful_widget.dart';

class VulcanXSwitch extends VulcanXStatefulWidget {
  final bool value;
  final Function(bool)? onChanged;
  final String? label; // label 속성 추가

  const VulcanXSwitch({
    super.key,
    this.value = false,
    this.onChanged,
    this.label, // label 파라미터 추가
  });

  @override
  VulcanXState<VulcanXSwitch> createState() => _VulcanXSwitchState();
}

class _VulcanXSwitchState extends VulcanXState<VulcanXSwitch> {
  bool _value = false;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  void didUpdateWidget(covariant VulcanXSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    _value = widget.value;
  }

  @override
  Widget buildWithTheme(BuildContext context, ThemeData themeData) {
    return Row(
      mainAxisSize: MainAxisSize.min, // Row의 크기를 내용물에 맞게 조절
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: context.bodyMedium),
          const Spacer(),
        ],
        Switch(
          value: _value,
          onChanged: (value) {
            setState(() {
              _value = value;
            });
            widget.onChanged?.call(_value);
          },
        ),
      ],
    );
  }
}
