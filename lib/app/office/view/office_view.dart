import 'package:api/api.dart';
import 'package:app/app/login/view/login_controller.dart';
import 'package:author_editor/iframe/epub_viewer_iframe.dart';
import 'package:author_editor/iframe/iframe_mixin.dart';
import 'package:author_editor/iframe/office_iframe.dart';
import 'package:author_editor/mixins/dragdocs_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OfficeView extends StatefulWidget {
  final String? fileUrl;
  final String? fileName;
  final OnConvertCallback? onConvert;

  const OfficeView({
    super.key,
    this.fileUrl,
    this.fileName,
    this.onConvert,
  });

  @override
  State<OfficeView> createState() => _OfficeViewState();
}

/// 오피스 뷰어
class _OfficeViewState extends State<OfficeView> {
  late String _fileUrl;
  late String _fileName;
  final LoginController loginController = Get.find<LoginController>();
  bool _isInitialized = false;

  // OfficeIframe의 함수를 호출
  final GlobalKey _officeIframeKey = GlobalKey();
  void callExports(String pages) {
    final state = _officeIframeKey.currentState;
    if (state != null) {
      (state as dynamic).callExports(pages);
    }
  }

  int getCurrentPage() {
    final state = _officeIframeKey.currentState;
    if (state != null) {
      return (state as dynamic).getCurrentPage();
    }
    return 0;
  }

  int getTotalPages() {
    final state = _officeIframeKey.currentState;
    if (state != null) {
      return (state as dynamic).getTotalPages();
    }
    return 0;
  }

  @override
  void initState() {
    super.initState();
    _fileUrl = widget.fileUrl ?? '';
    //_fileUrl = '${file?.downloadUrl}&filename=${file?.fileName}';
    _fileName = widget.fileName ?? '';
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isInitialized) {
          _isInitialized = true;
          loginController.initOfficeViewer(context);
        }
      });
    }
    return Center(child: _buildWidget(context));
  }

  String get _fileExtension => _fileName.split('.').last.toLowerCase();

  String get _url {
    if (DragDocsMixin.allowedEpubExtensions.contains(_fileExtension)) {
      return '${ApiDio.apiHostAppServer.replaceAll('/api/v1', '')}epub_viewer/epub_viewer.html';
    } else {
      if (_fileExtension == 'txt') {
        return '${ApiDio.apiHostAppServer.replaceAll('/api/v1', '')}dragdocs/textviewer.html';
      } else {
        return '${ApiDio.apiHostAppServer.replaceAll('/api/v1', '')}dragdocs/index.html';
      }
    }
  }

  Widget _buildWidget(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (DragDocsMixin.allowedEpubExtensions.contains(_fileExtension)) {
      return EpubViewerIframe(
        url: _url,
        fileUrl: _fileUrl,
        width: size.width,
        height: size.height,
        onConvert: widget.onConvert,
      );
    } else {
      return OfficeIframe(
        key: _officeIframeKey,
        url: _url,
        fileUrl: _fileUrl,
        fileName: _fileName,
        width: size.width,
        height: size.height,
        readOnly: true,
        onConvert: widget.onConvert,
      );
    }
  }
}
