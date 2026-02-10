import 'package:flutter/material.dart';

import '../../app_ui.dart';
import 'base_radio_btn.dart';

class RectangleRadioBtn extends BaseRadioBtn {
  final BuildContext context;

  const RectangleRadioBtn({
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
    return RectangleCheckBox(
        isGroup: true,
        isChecked: true,
        buttonSize: buttonSize,
        selectedBackgroundColor: context.primary,
        iconSize: iconSize);
  }

  @override
  Widget checkBoxIconFalse() {
    return RectangleCheckBox(
      isGroup: true,
      isChecked: false,
      buttonSize: buttonSize,
      unselectedBackgroundColor: context.surfaceContainer,
      iconSize: iconSize,
    );
  }
}
