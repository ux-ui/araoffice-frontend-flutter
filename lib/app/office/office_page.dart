import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../common/common_home_drawer.dart';
import 'controller/office_controller.dart';
import 'view/office_view.dart';

// http://localhost:12342/web/#/office?fileId=MTAwMDAxNTA1MzM0MjQ0fDM0NzI2MDQ4ODEyODEyNjY0NDB8Rnww&fileName=introducemyself.hwp

// http://localhost:12342/web/#/office?fileId=MTAwMDAxNTA1MzM0MjQ0fDM0NzI2MDQ4OTE4NzQ1NTc5NjF8Rnww&fileName=filename=2023.hwpx

// ## 사용 예시

// ### Case 1: 네이버웍스 (기존 방식 - 변경 없음)
// # 기존 URL 그대로 동작
// # drive 파라미터 없음 → 자동으로 naverWorks 처리
// http://localhost:12342/web/#/office?fileId=MTAwMDA...&fileName=2023.hwpx

// ### Case 2: IOP - fileId로 조회
// http://localhost:12342/web/#/office?fileId=ABC123&fileName=test.epub&drive=iop

// ### Case 3: IOP - downloadUrl 직접 전달 (accessKey 별도 파라미터)
// http://localhost:12342/web/#/office?downloadUrl=api/v1/external/files/download&fileId=ABC123&fileName=test.epub&drive=iop&accessKey=xyz789

// ### Case 4: IOP - downloadUrl에 fileId와 accessKey가 포함된 경우
// http://localhost:12342/web/#/office?downloadUrl=api/v1/external/files/download?fileId=ABC123&accessKey=xyz789&fileName=test.epub&drive=iop

// 주의: downloadUrl에 쿼리 파라미터가 있으면 URL 인코딩 필요
// 예: downloadUrl=api%2Fv1%2Fexternal%2Ffiles%2Fdownload%3FfileId%3DABC123%26accessKey%3Dxyz789

class OfficePage extends GetView<OfficeController> {
  static const String route = '/office';

  const OfficePage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewType = controller.viewType.value;

    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonHomeDrawer(viewType: viewType),
          const VerDivider(),
          FutureBuilder(
            future: controller.loadFileUrl(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Expanded(
                  child: SingleChildScrollView(
                    child: OfficeView(
                      key: controller.officeViewKey,
                      fileUrl: controller.fileUrl,
                      fileName: controller.fileName,
                       onConvert: (result, fileName, page, total, content) =>
                          controller.onConvert(
                              context, result, fileName, page, total, content),
                    ),
                  ),
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ],
      ),
    );
  }
}
