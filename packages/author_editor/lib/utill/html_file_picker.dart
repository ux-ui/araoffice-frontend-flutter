import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart';

class FilePickResult {
  final String fileName;
  final Uint8List fileBytes;

  FilePickResult(this.fileName, this.fileBytes);
}

class HtmlFilePicker {
  /// 예: 'image/*', '.pdf,.doc', '*/*'
  final String? acceptType;
  final Function(FilePickResult)? onPickComplete;
  final Function(String)? onError;

  HtmlFilePicker({
    this.acceptType = '*/*',
    this.onPickComplete,
    this.onError,
  });

  void pickFile() {
    try {
      final input = document.createElement('input') as HTMLInputElement;
      input.type = 'file';
      input.accept = acceptType ?? '*/*';

      input.addEventListener(
        'change',
        ((Event event) {
          final files = input.files;
          if (files != null && files.length > 0) {
            final file = files.item(0);
            if (file == null) {
              onError?.call('No file selected');
              return;
            }

            final reader = FileReader();

            reader.addEventListener(
              'loadend',
              ((Event event) {
                if (reader.readyState == FileReader.DONE) {
                  try {
                    // ArrayBuffer를 Uint8List로 변환
                    final buffer = reader.result as ByteBuffer;
                    final bytes = Uint8List.view(buffer);

                    final result = FilePickResult(
                      file.name,
                      bytes,
                    );
                    onPickComplete?.call(result);
                  } catch (e) {
                    onError?.call(e.toString());
                  }
                }
              }).toJS,
            );

            reader.addEventListener(
              'error',
              ((Event event) {
                onError?.call('Error reading file');
              }).toJS,
            );

            reader.readAsArrayBuffer(file);
          }
        }).toJS,
      );

      input.click();
    } catch (e) {
      onError?.call(e.toString());
    }
  }
}
