import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'window_controller.dart';

class WindowDemoPage extends GetView<WindowController> {
  static const String route = '/window_page_demo';

  const WindowDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        OutlinedButton(
            onPressed: () => controller.login(), child: const Text('login')),
        const SizedBox(height: 10),
        OutlinedButton(
            onPressed: () => controller.checkSession(),
            child: const Text('check session')),
        const SizedBox(height: 10),
        OutlinedButton(
            onPressed: () => controller.logout(), child: const Text('logout')),
        const SizedBox(height: 10),
        Obx(() => Text(controller.result.value)),
      ],
    );
  }
}
