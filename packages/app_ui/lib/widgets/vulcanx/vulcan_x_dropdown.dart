import 'package:flutter/material.dart';

import '../../app_ui.dart';
import 'vulcan_x_stateless_widget.dart';

class VulcanXIconDropdownMenuItem<T> extends DropdownMenuItem<T> {
  final IconData? icon;

  const VulcanXIconDropdownMenuItem({
    required T super.value,
    required super.child,
    this.icon,
    super.key,
  });
}

class VulcanXDropdown<T> extends VulcanXStatelessWidget {
  final T? value;
  final List<VulcanXIconDropdownMenuItem<T>>? items;
  final List<String>? stringItems;
  final List<T>? enumItems;
  final ValueChanged<T?> onChanged;
  final String hintText;
  final IconData? hintIcon;
  final IconData? icon;
  final double? width;
  final double? height;
  final String Function(T)? displayStringForOption;
  final bool disabled;

  const VulcanXDropdown({
    super.key,
    required this.value,
    this.items,
    this.stringItems,
    this.enumItems,
    required this.onChanged,
    required this.hintText,
    this.hintIcon,
    this.width,
    this.height = 40,
    this.icon,
    this.displayStringForOption,
    this.disabled = false,
  }) : assert(
          items != null || stringItems != null || enumItems != null,
          'Either items, stringItems, or enumItems must be provided',
        );

  @override
  Widget buildWithTheme(BuildContext context, ThemeData themeData) {
    List<DropdownMenuItem<T>> dropdownItems;

    if (items != null) {
      dropdownItems = items!.map((VulcanXIconDropdownMenuItem<T> item) {
        return DropdownMenuItem<T>(
          value: item.value,
          child: Row(
            children: [
              if (item.icon != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(item.icon, color: context.onSurfaceVariant),
                ),
              Expanded(child: item.child),
            ],
          ),
        );
      }).toList();
    } else if (stringItems != null) {
      dropdownItems = stringItems!.map((String item) {
        return DropdownMenuItem<T>(
          value: item as T,
          child: Text(item),
        );
      }).toList();
    } else {
      dropdownItems = enumItems!.map((T item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            displayStringForOption?.call(item) ?? item.toString(),
          ),
        );
      }).toList();
    }

    return SizedBox(
      width: width,
      height: height,
      child: DropdownButtonFormField<T>(
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
        ),
        value: value,
        items: dropdownItems,
        onChanged: disabled ? null : onChanged,
        icon: Icon(
          (icon != null) ? icon : Icons.expand_more,
          color: disabled ? themeData.disabledColor : context.onSurfaceVariant,
        ),
        hint: Row(
          children: [
            if (hintIcon != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(hintIcon,
                    color: disabled
                        ? themeData.disabledColor
                        : themeData.hintColor),
              ),
            Expanded(
              child: Text(
                hintText,
                style: themeData.textTheme.bodyMedium?.copyWith(
                  color:
                      disabled ? themeData.disabledColor : themeData.hintColor,
                ),
              ),
            ),
          ],
        ),
        style: themeData.textTheme.bodyMedium?.copyWith(
          color: disabled ? themeData.disabledColor : null,
        ),
        dropdownColor: themeData.colorScheme.surface,
        isExpanded: true,
      ),
    );
  }
}
