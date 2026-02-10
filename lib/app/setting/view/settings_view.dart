import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    // 일반 설정
    return Center(child: CommonAssets.image.exampleSetting.image());
  }
}
