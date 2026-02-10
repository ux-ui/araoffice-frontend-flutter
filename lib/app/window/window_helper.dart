import 'package:web/web.dart' as web;

class WindowHelper {
  static void openWidgetWindow({
    required String path,
    required int width,
    required int height,
    String? name,
  }) {
    // 화면 중앙 위치 계산
    final screenWidth = web.window.screen.width;
    final screenHeight = web.window.screen.height;
    final left = (screenWidth - width) ~/ 2;
    final top = (screenHeight - height) ~/ 2;

    // 창 옵션 설정
    final features = [
      'width=$width',
      'height=$height',
      'left=$left',
      'top=$top',
      'menubar=no',
      'toolbar=no',
      'location=no',
      'status=no',
      'scrollbars=yes',
      'resizable=yes',
    ].join(',');

    // 현재 baseUrl 가져오기
    final baseUrl = Uri.base.toString();

    // standalone 파라미터를 추가하여 URL 생성
    final url = Uri.parse('$baseUrl#$path').toString();

    // 새 창 열기
    web.window.open(url, name ?? '_blank', features);
  }
}
