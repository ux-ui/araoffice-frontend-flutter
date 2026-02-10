import 'package:flutter/material.dart';

class BaseRadioBtn extends StatefulWidget {
  final int buttonIndex;
  final Function(double)? onChanged;
  final double? buttonPadding;
  final double? buttonSize;
  final double? iconSize;

  const BaseRadioBtn(
      {required this.buttonIndex,
      this.onChanged,
      this.buttonPadding,
      this.buttonSize,
      this.iconSize,
      super.key});

  @override
  State<BaseRadioBtn> createState() => _BaseRadioBtnState();

  Widget checkBoxIconTrue() {
    return Icon(
      Icons.check_box,
      size: iconSize,
    );
  }

  Widget checkBoxIconFalse() {
    return Icon(
      Icons.check_box,
      size: iconSize,
    );
  }
}

class _BaseRadioBtnState extends State<BaseRadioBtn> {
  int groupValue = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          widget.buttonIndex,
          (index) => Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    groupValue = index;
                  });
                  widget.onChanged?.call(groupValue.toDouble());
                },
                child: groupValue == index
                    ? widget.checkBoxIconTrue()
                    : widget.checkBoxIconFalse(),
              ),
              SizedBox(width: widget.buttonPadding ?? 10),
            ],
          ),
        ));
  }
}
