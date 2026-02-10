import 'package:api/api.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:web/web.dart' as web;

class SsoSignUpPopup extends StatefulWidget {
  final Function(bool, bool)? onSignUpComplete;
  final Function()? onClose;

  const SsoSignUpPopup({
    super.key,
    this.onSignUpComplete,
    this.onClose,
  });

  /// 다이얼로그를 표시하는 static 메서드
  /// Returns: true if sign up was completed, false otherwise
  static Future<bool> show(
    BuildContext context, {
    Function(bool, bool)? onSignUpComplete,
    VoidCallback? onClose,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return SsoSignUpPopup(
          onSignUpComplete: (isPersonalInfoAgree, isMarketingAgree) =>
              onSignUpComplete?.call(
                  isPersonalInfoAgree, isMarketingAgree ?? false),
          onClose: onClose,
        );
      },
    ).then((value) => value ?? false);
  }

  @override
  State<SsoSignUpPopup> createState() => _SsoSignUpPopupState();
}

class _SsoSignUpPopupState extends State<SsoSignUpPopup> {
  // 전체 동의 상태
  bool _isAllAgreed = false;

  // 개별 약관 동의 상태
  bool _isPersonalInfoAgree = false; // 필수
  // bool _isMarketingAgree = false; // 선택

  // 전체 동의 체크박스 변경
  void _onAllAgreedChanged(bool value) {
    setState(() {
      _isAllAgreed = value;
      _isPersonalInfoAgree = value;
      // _isMarketingAgree = value;
    });
  }

  // 개별 약관 동의 변경
  void _onIndividualAgreedChanged(int index, bool value) {
    setState(() {
      switch (index) {
        case 0:
          _isPersonalInfoAgree = value;
          break;
        // case 1:
        //   _isMarketingAgree = value;
        //   break;
      }

      // 전체 동의: 개인정보 동의 시 자동 체크
      _isAllAgreed = _isPersonalInfoAgree;
      // 전체 동의: 개인정보와 마케팅 모두 동의 시 자동 체크
      // _isAllAgreed = _isPersonalInfoAgree && _isMarketingAgree;
    });
  }

  // 약관 보기
  void _showTerms(int index) {
    switch (index) {
      case 0: // 개인정보 약관
        final url = getUrlPrivacyPolicy();
        web.window.open(url, '_blank');
        break;
      // case 1: // 마케팅 약관
      //   final url = getUrlMarketingPolicy();
      //   web.window.open(url, '_blank');
      //   break;
    }
    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return AlertDialog(
    //       title: Text('약관 내용'),
    //       content: Text('약관 내용이 여기에 표시됩니다.'),
    //       actions: [
    //         TextButton(
    //           onPressed: () => Navigator.of(context).pop(),
    //           child: Text('닫기'),
    //         ),
    //       ],
    //     );
    //   },
    // );
  }

  bool get _canSignUp => _isPersonalInfoAgree; // 개인정보 동의만 필수

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: PointerInterceptor(
        child: Container(
          width: 320,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 전체 동의 섹션
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: InkWell(
                      onTap: () => _onAllAgreedChanged(!_isAllAgreed),
                      child: Row(
                        children: [
                          CircleCheckBox(
                            isChecked: _isAllAgreed,
                            buttonSize: 12,
                            onChanged: _onAllAgreedChanged,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'sso_sign_up_all_agree'.tr,
                              style: context.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 닫기 버튼
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 20,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                        widget.onClose?.call();
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              ),

              Container(
                height: 1,
                color: Colors.grey[300],
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildTermsItem(
                      0,
                      'sso_sign_up_privacy_collection'.tr,
                      true, // 필수
                    ),
                    // _buildTermsItem(
                    //   1,
                    //   'sso_sign_up_marketing'.tr,
                    //   false, // 선택
                    // ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  onPressed: _canSignUp
                      ? () {
                          Navigator.of(context).pop(true);
                          widget.onSignUpComplete?.call(
                            _isPersonalInfoAgree,
                            false, // _isMarketingAgree,
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _canSignUp ? context.primary : Colors.grey[300],
                    foregroundColor:
                        _canSignUp ? context.primary : Colors.grey[500],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'sso_sign_up_join'.tr,
                    style: context.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermsItem(int index, String title, bool isRequired) {
    bool isChecked = false;
    switch (index) {
      case 0:
        isChecked = _isPersonalInfoAgree;
        break;
      // case 1:
      //   isChecked = _isMarketingAgree;
      //   break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          CircleCheckBox(
            isChecked: isChecked,
            buttonSize: 12,
            onChanged: (value) => _onIndividualAgreedChanged(index, value),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: context.bodyMedium?.copyWith(
                color: Colors.black87,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _showTerms(index),
            child: Text(
              'view'.tr,
              style: context.bodySmall?.copyWith(color: context.surfaceDim),
            ),
          ),
        ],
      ),
    );
  }

  String getBaseUrl() {
    final baseUrl = ApiDio.apiHostAppServer.replaceAll('/api/v1', '');
    return baseUrl;
  }

  String getUrlTerms() {
    final baseUrl = getBaseUrl();
    return '${baseUrl}info/term-of-use';
  }

  String getUrlYouthProtectionPolicy() {
    final baseUrl = getBaseUrl();
    return '${baseUrl}info/term-of-youth';
  }

  String getUrlMarketingPolicy() {
    final baseUrl = getBaseUrl();
    return '${baseUrl}info/term-of-marketing';
  }

  String getUrlPrivacyPolicy() {
    final baseUrl = getBaseUrl();
    return '${baseUrl}info/privacy-policy';
  }

  String getUrl() {
    final baseUrl = getBaseUrl();
    return '${baseUrl}info/privacy-policy';
  }
}
