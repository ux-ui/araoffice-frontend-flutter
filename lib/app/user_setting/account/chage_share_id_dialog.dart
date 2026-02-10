import 'package:app/app/login/view/login_controller.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class ShareIdChangeDialog extends StatefulWidget {
  final LoginController loginController;
  final Future<void> Function(String) onConfirm;

  const ShareIdChangeDialog({
    required this.loginController,
    required this.onConfirm,
  });

  @override
  State<ShareIdChangeDialog> createState() => _ShareIdChangeDialogState();
}

class _ShareIdChangeDialogState extends State<ShareIdChangeDialog> {
  String? _selectedNickname;
  List<String> _candidates = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _generateInitialNickname();
  }

  Future<void> _generateInitialNickname() async {
    setState(() => _isLoading = true);
    try {
      final response = await widget.loginController.nickNameApiService
          // .generateUniqueNickname();
          .generateUniqueShareId();
      if (response != null && mounted) {
        setState(() {
          _selectedNickname = response.nickname;
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('닉네임 생성 오류: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _regenerateNickname() async {
    setState(() => _isLoading = true);
    try {
      final response =
          await widget.loginController.nickNameApiService.regenerateNickname();
      if (response != null && mounted) {
        setState(() {
          _selectedNickname = response.nickname;
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('닉네임 재생성 오류: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadCandidates() async {
    EasyLoading.show(status: '후보 생성 중...');
    try {
      final response = await widget.loginController.nickNameApiService
          // .generateUniqueNicknameCandidates(count: 5);
          .generateUniqueShareIdCandidates(count: 5);
      if (response != null && mounted) {
        setState(() {
          _candidates = response.candidates;
        });
      }
    } catch (e) {
      debugPrint('후보 생성 오류: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 현재 선택된 닉네임 표시
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedNickname ?? '생성 중...',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (_isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 재생성 버튼
          Row(
            children: [
              Expanded(
                child: VulcanXOutlinedButton(
                  onPressed: _isLoading ? null : _regenerateNickname,
                  child: const Text('다시 생성'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: VulcanXOutlinedButton(
                  onPressed: _isLoading ? null : _loadCandidates,
                  child: const Text('후보 보기'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 후보 목록
          if (_candidates.isNotEmpty) ...[
            const Text(
              '후보 목록 (클릭하여 선택)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _candidates.map((candidate) {
                    final isSelected = candidate == _selectedNickname;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedNickname = candidate;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue[50] : Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.grey[300]!,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Text(
                          candidate,
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected ? Colors.blue : Colors.black,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 확인 버튼
          VulcanXElevatedButton(
            onPressed: _selectedNickname == null || _isLoading
                ? null
                : () async {
                    if (_selectedNickname != null) {
                      await widget.onConfirm(_selectedNickname!);
                    }
                  },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
