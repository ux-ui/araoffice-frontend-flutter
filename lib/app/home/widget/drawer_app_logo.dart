import 'package:app_ui/app_ui.dart';
import 'package:common_assets/common_assets.dart';
import 'package:common_util/common_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../view/home_page.dart';

class DrawerAppLogo extends StatelessWidget {
  const DrawerAppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => context.go(HomePage.route),
          child: (AutoConfig.instance.domainType.isDferiDomain)
              ? _buildDferiLogo(context)
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CommonAssets.icon.dabondaSymbol.svg(width: 32, height: 32),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AUTHOR',
                          style: context.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                        Text('ARA Office', style: context.headlineSmall)
                      ],
                    )
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildDferiLogo(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CommonAssets.image.booknaviLogo.image(),
        const SizedBox(width: 8),
        Text('dferi_app_name'.tr,
            style: context.headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold, fontSize: 20))
      ],
    );
  }
}
