import 'dart:ui';

extension StringExtension on String? {
  Color? toColor({bool withAlpha = false}) {
    if (this == null) {
      return null;
    }

    // 색상 이름 매핑
    final colorNames = {
      'BLACK': 'FF000000',
      'RED': 'FFFF0000',
      'GREEN': 'FF008000',
      'BLUE': 'FF0000FF',
      'WHITE': 'FFFFFFFF',
      'YELLOW': 'FFFFFF00',
      'CYAN': 'FF00FFFF',
      'MAGENTA': 'FFFF00FF',
      'ORANGE': 'FFFFA500',
      'PURPLE': 'FF800080',
      'PINK': 'FFFFC0CB',
      'GRAY': 'FF808080',
      'GREY': 'FF808080',
      'BROWN': 'FFA52A2A',
      'LIME': 'FF00FF00',
      'NAVY': 'FF000080',
      'SILVER': 'FFC0C0C0',
      'GOLD': 'FFFFD700',
      'TRANSPARENT': '00000000',
    };

    // 색상 이름으로 변환 시도
    final colorName = this!.toUpperCase();
    if (colorNames.containsKey(colorName)) {
      return Color(int.parse(colorNames[colorName]!, radix: 16));
    }

    // RGB/RGBA 형식 확인
    if (this!.toUpperCase().startsWith('RGB')) {
      final match = RegExp(
              r'rgba?\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*(?:,\s*([\d.]+)\s*)?\)')
          .firstMatch(this!);
      if (match != null) {
        final r = int.parse(match.group(1)!);
        final g = int.parse(match.group(2)!);
        final b = int.parse(match.group(3)!);
        final alpha = (withAlpha && match.group(4) != null)
            ? (double.tryParse(match.group(4)!) ?? 1.0).clamp(0.0, 1.0)
            : 1.0;
        return Color.fromRGBO(r, g, b, alpha);
      }
    }

    String hexString = this?.toUpperCase().replaceAll('#', '') ?? '';
    if (hexString.length == 6) {
      hexString = 'FF$hexString'; // Add alpha value if not provided
    }
    return Color(int.tryParse(hexString, radix: 16) ?? 0);
  }

  String get contentType {
    final fileExtension = this?.split('.').lastOrNull ?? '';
    if (fileExtension.isEmpty) {
      return 'application/octet-stream';
    }
    switch (fileExtension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'html':
        return 'text/html; charset=utf-8';
      case 'txt':
        return 'text/plain; charset=utf-8';
      case 'js':
        return 'application/javascript; charset=utf-8';
      case 'pdf':
        return 'application/pdf';
      case 'epub':
        return 'application/epub+zip';
      case 'css':
        return 'text/css; charset=utf-8';
      default:
        return 'application/octet-stream';
    }
  }

  String get safeFileName {
    var fileName = this ?? '';
    // Reserved Characters: ?, #, &, =, /, +, :, @
    fileName = fileName.replaceAll(RegExp(r'[?#&=/+:@]'), '_');
    // Unsafe Characters: 공백, <, >, ", `, {, }, [, ], |, \, ^, ~
    fileName = fileName.replaceAll(RegExp(r'[\s<>"\`\{\}\[\]\|\\^\~]'), '_');
    return fileName;
  }
}
