import 'package:app_ui/app_ui.dart';
import 'package:author_editor/vulcan_editor_eventbus.dart';
import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditorHistoryStackIconMenu extends StatelessWidget with EditorEventbus {
  EditorHistoryStackIconMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Obx(() => IconButton(
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(5),
              onPressed:
                  controller.rxCanUndo.value ? () => controller.undo() : null,
              icon: CommonAssets.icon.undo.svg(
                colorFilter: ColorFilter.mode(
                    controller.rxCanUndo.value
                        ? context.onSurface
                        : context.surfaceDim,
                    BlendMode.srcIn),
              ),
            )),
        Obx(() => IconButton(
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(5),
              onPressed:
                  controller.rxCanRedo.value ? () => controller.redo() : null,
              icon: CommonAssets.icon.redo.svg(
                colorFilter: ColorFilter.mode(
                    controller.rxCanRedo.value
                        ? context.onSurface
                        : context.surfaceDim,
                    BlendMode.srcIn),
              ),
            )),
      ],
    );
  }
}
