import 'dart:ui';

extension IntExtension on int? {
  String get fileSizeText {
    if (this == null) {
      return '';
    }
    if (this! < 1024) {
      return '$this Bytes';
    } else if (this! < 1024 * 1024) {
      return '${(this! / 1024).toStringAsFixed(2)}KB';
    } else if (this! < 1024 * 1024 * 1024) {
      return '${(this! / 1024 / 1024).toStringAsFixed(2)}MB';
    } else {
      return '${(this! / 1024 / 1024 / 1024).toStringAsFixed(2)}GB';
    }
  }

  Color toColor({bool withAlpha = false}) => Color.fromARGB(
        withAlpha ? (this! >> 24) & 0xff : 0xff,
        (this! >> 16) & 0xff,
        (this! >> 8) & 0xff,
        this! & 0xff,
      );
}
