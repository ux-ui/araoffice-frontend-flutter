import 'package:api/api.dart';
import 'package:app_ui/widgets/vulcanx/vulcan_x_close_dialog_widget.dart';
import 'package:common_util/common_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

mixin CloudConnectionMixin {
  /// 클라우드 연결 상태 확인
  /// - 네이버웍스: 액세스 토큰 조회 (302 응답 처리 없이 직접 호출)
  /// return: true - 연결 상태, false - 미연결 상태 또는 연결 상태 조회 실패
  Future<bool> isCloudConnected() async {
    try {
      final cloudApiService = Get.find<CloudApiService>();
      final token = await cloudApiService.getNaverWorksTokenNoRedirect();
      if (token == null || token.isEmpty) {
        logger.d('[CloudConnection] isCloudConnected: Not connected');
        return false;
      }
      logger.d('[CloudConnection] isCloudConnected: Connected');
      return true;
    } catch (e) {
      logger.d('[CloudConnection] isCloudConnected error: $e');
      return false;
    }
  }

  /// 클라우드 연결 상태 확인 후 미연결 시 onConnect 호출
  /// return:
  /// - true: 연결된 상태
  /// - false: 미연결 상태. onConnect 받는 곳에서 클라우드 연동 화면으로 이동 처리
  /// - null: 오류 발생
  ///
  Future<bool?> handleCloudConnection(
    BuildContext context, {
    VoidCallback? onConnect,
  }) async {
    try {
      final connected = await isCloudConnected();
      if (connected) {
        return true;
      }
      if (context.mounted) {
        final result = await VulcanCloseDialogWidget(
          width: 300,
          height: 180,
          title: 'cloud_title'.tr,
          content: Text('cloud_connect_error'.tr),
          isShowConfirm: true,
          isShowCancel: true,
        ).show(context);
        if (result == VulcanCloseDialogType.ok) {
          logger.d(
              '[CloudConnection] handleCloudConnection: Go to cloud connect page');
          onConnect?.call();
          return false;
        }
      }
      return null;
    } catch (e) {
      logger.d('[CloudConnection] handleCloudConnection error: $e');
      return null;
    }
  }
}
