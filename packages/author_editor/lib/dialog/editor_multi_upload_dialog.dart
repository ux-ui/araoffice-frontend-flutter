// file: multi_upload_dialog.dart
import 'package:app_ui/app_ui.dart';
import 'package:common_util/common_util.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class EditorMultiUploadDialog extends StatefulWidget {
  final List<PlatformFile> files;
  final Future<void> Function(PlatformFile file) onUpload;

  const EditorMultiUploadDialog({
    super.key,
    required this.files,
    required this.onUpload,
  });

  static Future<bool?> show(
    BuildContext context, {
    required List<PlatformFile> files,
    required Future<void> Function(PlatformFile file) onUpload,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => EditorMultiUploadDialog(
        files: files,
        onUpload: onUpload,
      ),
    );
  }

  @override
  State<EditorMultiUploadDialog> createState() =>
      _EditorMultiUploadDialogState();
}

class _EditorMultiUploadDialogState extends State<EditorMultiUploadDialog> {
  final Map<String, double> _uploadProgress = {};
  final Map<String, bool> _uploadComplete = {};
  bool _isUploading = false;
  int _currentFileIndex = 0;

  @override
  void initState() {
    super.initState();
    // 초기 진행률을 0으로 설정
    for (var file in widget.files) {
      _uploadProgress[file.name] = 0;
      _uploadComplete[file.name] = false;
    }
  }

  Future<void> _startUpload() async {
    setState(() => _isUploading = true);

    for (var i = 0; i < widget.files.length; i++) {
      final file = widget.files[i];
      setState(() => _currentFileIndex = i);

      // 파일 업로드 시작
      try {
        // 업로드 진행 상황을 시뮬레이션
        for (var progress = 0.0; progress <= 1.0; progress += 0.1) {
          await Future.delayed(const Duration(milliseconds: 100));
          setState(() {
            _uploadProgress[file.name] = progress;
          });
        }

        // 실제 파일 업로드
        await widget.onUpload(file);

        setState(() {
          _uploadProgress[file.name] = 1.0;
          _uploadComplete[file.name] = true;
        });
      } catch (e) {
        logger.e('파일 업로드 실패: ${file.name}', e);
        // 에러 처리
      }
    }

    setState(() => _isUploading = false);

    // 모든 업로드가 완료되면 3초 후 다이얼로그 닫기
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PointerInterceptor(
      child: Dialog(
        backgroundColor: Colors.white,
        child: Container(
          width: 400,
          height: 300,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'upload_file_title'.tr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (!_isUploading)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'upload_multiple_files_message'
                    .trArgs(['${widget.files.length}']),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.files.length,
                  itemBuilder: (context, index) {
                    final file = widget.files[index];
                    final progress = _uploadProgress[file.name] ?? 0.0;
                    final isComplete = _uploadComplete[file.name] ?? false;
                    final isCurrentFile = _currentFileIndex == index;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  file.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (isComplete)
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 16,
                                )
                              else if (isCurrentFile && _isUploading)
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: context.outline.withAlpha(51),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isComplete ? Colors.green : context.primary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!_isUploading) ...[
                    Expanded(
                      child: VulcanXOutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text('cancel'.tr),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: VulcanXElevatedButton.primary(
                        onPressed: _startUpload,
                        child: Text('upload_file'.tr),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                    const SizedBox(width: 5),
                    Text(
                      '${_currentFileIndex + 1}/${widget.files.length} ${'uploading'.tr}...',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
