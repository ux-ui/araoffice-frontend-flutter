import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuestionView extends StatefulWidget {
  const QuestionView({super.key});

  @override
  State<QuestionView> createState() => _QuestionViewState();
}

class _QuestionViewState extends State<QuestionView> {
  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    debugPrint('-------question view : $location');
    // '도움말 센터'
    return Center(child: CommonAssets.image.exampleHelp.image());
  }
}
