import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class ShortcutMenuBar extends StatefulWidget {
  final Widget child;
  final List<List<Map<String, String>>> itemGroups;
  final Function(int)? onTap;

  const ShortcutMenuBar({
    super.key,
    required this.itemGroups,
    required this.child,
    this.onTap,
  });

  @override
  State<ShortcutMenuBar> createState() => _ShortcutMenuBarState();
}

class _ShortcutMenuBarState extends State<ShortcutMenuBar> {
  ShortcutRegistryEntry? _shortcutsEntry;

  @override
  void dispose() {
    _shortcutsEntry?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PointerInterceptor(
      child: MenuBar(
        style: MenuStyle(
          elevation: WidgetStateProperty.all(0.0),
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
        ),
        children: [
          SubmenuButton(
            alignmentOffset: const Offset(25.0, 0),
            menuStyle: MenuStyle(
              elevation: WidgetStateProperty.all(10), // 그림자 강도 증가
              backgroundColor: WidgetStateProperty.all(Colors.white),
              padding: WidgetStateProperty.all(EdgeInsets.zero),
              shape: WidgetStateProperty.all<OutlinedBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
              shadowColor: WidgetStateProperty.all(Colors.black.withAlpha(255)),
            ),
            style: ButtonStyle(
              elevation: WidgetStateProperty.all(0.0),
              padding: WidgetStateProperty.all(EdgeInsets.zero),
              minimumSize: WidgetStateProperty.all(Size.zero),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              backgroundColor:
                  WidgetStateProperty.all(Colors.white), // 흰색 배경 추가
            ),
            menuChildren: _buildMenuItems(),
            child: widget.child,
          ),
        ],
      ),
    );
  }

  List<MenuEntry> _createMenuEntries() {
    List<MenuEntry> entries = [];

    for (var group in widget.itemGroups) {
      for (var item in group) {
        entries.add(MenuEntry(
          label: item['label'] ?? '',
          shortcut: _parseShortcut(item['shortcut']),
          onPressed: () {
            final index = int.tryParse(item['index'] ?? '') ?? -1;
            widget.onTap?.call(index);
            //print('Clicked: ${item['label']}');
          },
        ));
      }

      // 마지막 그룹이 아니면 구분선 추가
      if (group != widget.itemGroups.last) {
        entries.add(MenuEntry.divider);
      }
    }

    return entries;
  }

  List<Widget> _buildMenuItems() {
    List<MenuEntry> entries = _createMenuEntries();
    return MenuEntry.build(entries);
  }

  MenuSerializableShortcut? _parseShortcut(String? shortcutString) {
    if (shortcutString == null || shortcutString.isEmpty) {
      return null;
    }

    List<String> keys = shortcutString.split('+');
    bool control = false;
    bool shift = false;
    bool alt = false;
    LogicalKeyboardKey? trigger;

    for (String key in keys) {
      switch (key.trim().toLowerCase()) {
        case 'ctrl':
          control = true;
          break;
        case 'shift':
          shift = true;
          break;
        case 'alt':
          alt = true;
          break;
        default:
          if (key.length == 1) {
            trigger = LogicalKeyboardKey.keyS;
          }
      }
    }

    if (trigger != null) {
      return SingleActivator(trigger, control: control, shift: shift, alt: alt);
    }

    return null;
  }
}

class MenuEntry {
  const MenuEntry({
    required this.label,
    this.shortcut,
    this.onPressed,
    this.menuChildren,
  }) : assert(menuChildren == null || onPressed == null,
            'onPressed is ignored if menuChildren are provided');

  final String label;
  final MenuSerializableShortcut? shortcut;
  final VoidCallback? onPressed;
  final List<MenuEntry>? menuChildren;

  static const MenuEntry divider = MenuEntry(label: '__divider__');

  static List<Widget> build(List<MenuEntry> selections) {
    Widget buildSelection(MenuEntry selection) {
      if (selection == MenuEntry.divider) {
        return const Divider(
            color: Color.fromARGB(255, 215, 214, 214), thickness: 0.0);
      }
      if (selection.menuChildren != null) {
        return SubmenuButton(
          menuChildren: MenuEntry.build(selection.menuChildren!),
          child: Text(selection.label),
        );
      }
      return PointerInterceptor(
        child: MenuItemButton(
          style: const ButtonStyle(
            minimumSize: WidgetStatePropertyAll(Size(250, 50)),
            padding:
                WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16)),
          ),
          shortcut: selection.shortcut,
          onPressed: selection.onPressed,
          child: Text(selection.label),
        ),
      );
    }

    return selections.map<Widget>(buildSelection).toList();
  }

  static Map<MenuSerializableShortcut, Intent> shortcuts(
      List<MenuEntry> selections) {
    final Map<MenuSerializableShortcut, Intent> result =
        <MenuSerializableShortcut, Intent>{};
    for (final MenuEntry selection in selections) {
      if (selection.menuChildren != null) {
        result.addAll(MenuEntry.shortcuts(selection.menuChildren!));
      } else {
        if (selection.shortcut != null && selection.onPressed != null) {
          result[selection.shortcut!] =
              VoidCallbackIntent(selection.onPressed!);
        }
      }
    }
    return result;
  }
}
