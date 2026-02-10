import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'vulcan_x_stateful_widget.dart';
import 'vulcan_x_text_field.dart';

class VulcanXDatePickerTextField extends VulcanXStatefulWidget {
  final TextEditingController controller;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const VulcanXDatePickerTextField({
    super.key,
    required this.controller,
    this.initialDate,
    this.firstDate,
    this.lastDate,
  });

  @override
  VulcanXDatePickerTextFieldState createState() =>
      VulcanXDatePickerTextFieldState();
}

class VulcanXDatePickerTextFieldState
    extends VulcanXState<VulcanXDatePickerTextField> {
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.initialDate != null) {
      selectedDate = widget.initialDate;
      widget.controller.text = DateFormat('yyyy-MM-dd').format(selectedDate!);
    }
  }

  Future<void> _selectDate(BuildContext context, ThemeData themeData) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? widget.initialDate ?? DateTime.now(),
      firstDate: widget.firstDate ?? DateTime(2000),
      lastDate: widget.lastDate ?? DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: themeData.copyWith(
            colorScheme: themeData.colorScheme.copyWith(
              primary: themeData.colorScheme.primary,
              onPrimary: themeData.colorScheme.onPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        widget.controller.text = DateFormat('yyyy-MM-dd').format(selectedDate!);
      });
    }
  }

  @override
  Widget buildWithTheme(BuildContext context, ThemeData themeData) {
    return VulcanXTextField(
      controller: widget.controller,
      hintText: 'YYYY-MM-DD',
      suffixIcon: IconButton(
        icon: Icon(Icons.calendar_today, color: themeData.colorScheme.primary),
        onPressed: () => _selectDate(context, themeData),
      ),
      readOnly: true,
      //onTap: () => _selectDate(context, themeData),
    );
  }
}
