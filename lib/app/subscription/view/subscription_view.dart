import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';

class SubscriptionView extends StatefulWidget {
  const SubscriptionView({super.key});

  @override
  State<SubscriptionView> createState() => _SubscriptionViewState();
}

/// 구독 관리
class _SubscriptionViewState extends State<SubscriptionView> {
  @override
  Widget build(BuildContext context) {
    return Center(child: CommonAssets.image.exampleSubscription.image());
  }
}
