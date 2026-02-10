import 'package:flutter/material.dart';

import '../../app_ui.dart';
import 'base_radio_btn.dart';

class CircleRadioBtn extends BaseRadioBtn {
  final BuildContext context;

  const CircleRadioBtn({
    super.key,
    required this.context,
    required super.buttonIndex,
    super.onChanged,
    super.buttonSize,
    super.iconSize,
    super.buttonPadding,
  });

  @override
  Widget checkBoxIconTrue() {
    return CircleCheckBox(
      isGroup: true,
      buttonSize: buttonSize,
      selectedBackgroundColor: context.primary,
      isChecked: true,
    );
  }

  @override
  Widget checkBoxIconFalse() {
    return CircleCheckBox(
      isGroup: true,
      buttonSize: buttonSize,
      unselectedBackgroundColor: context.surfaceContainer,
      isChecked: false,
    );
  }
}
