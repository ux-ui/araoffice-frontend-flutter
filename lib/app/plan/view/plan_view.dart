import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';

class PlanView extends StatefulWidget {
  const PlanView({super.key});

  @override
  State<PlanView> createState() => _PlanViewState();
}

/// 오서 플랜
class _PlanViewState extends State<PlanView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(
          //   '모든 프로젝트는 Starter 플랜에서 시작합니다. 언제든지 플랜을 업그레이드 할 수 있습니다.',
          //   style: context.titleMedium?.copyWith(color: context.onSurface),
          //   maxLines: 1,
          //   overflow: TextOverflow.ellipsis,
          // ),
          //const SizedBox(height: 12),
          CommonAssets.image.examplePlan.image()
        ],
      ),
    );
  }
}
