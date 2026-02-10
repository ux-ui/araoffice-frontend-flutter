import 'package:app/app/common/common_home_header.dart';
import 'package:app/app/common/common_view_type.dart';
import 'package:app/app/guide/contents/guide_start_content.dart';
import 'package:flutter/material.dart';

import '../contents/guide_download_content.dart';
import '../guide_view_type.dart';

class GuideContentView extends StatelessWidget {
  final GuideViewType? guideViewType;

  /// page -> view -> content
  const GuideContentView({super.key, this.guideViewType});

  @override
  Widget build(BuildContext context) {
    debugPrint('=========GuideContentView');
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        CommonHomePageHeader(viewType: ViewType.guide),
        switch (guideViewType) {
          GuideViewType.none => const Center(
              child: CircularProgressIndicator(),
            ),
          GuideViewType.guideStart => const GuideStartContent(),
          GuideViewType.guideDownload => const GuideDownloadContent(),
          _ => const GuideStartContent(),
        },
      ],
    );
  }
}
