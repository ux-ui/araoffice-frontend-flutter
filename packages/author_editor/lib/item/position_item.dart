import 'package:app_ui/app_ui.dart';
import 'package:author_editor/vulcan_editor_eventbus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../enum/enums.dart';
import '../utill/position_storage.dart';

class PositionItem extends StatefulWidget {
  final EdgeInsets? padding;
  final String? type;
  final String? unit;
  final bool? disabledTitle;
  final String? saveId;
  final FocusNode? xFocusNode;
  final FocusNode? yFocusNode;
  const PositionItem(
      {super.key,
      this.type,
      this.unit,
      this.padding,
      this.saveId,
      this.disabledTitle = false,
      this.xFocusNode,
      this.yFocusNode});

  @override
  State<PositionItem> createState() => _PositionItemState();
}

class _PositionItemState extends State<PositionItem> with EditorEventbus {
  final TextEditingController xController = TextEditingController(text: '0');
  final TextEditingController yController = TextEditingController(text: '0');
  PositionType? currentPositionType;

  bool _isPositionChanging = false; // 위치 그리드 변경 중 플래그
  Map<String, dynamic>? _savedPosition; // 저장된 위치 정보

  @override
  void initState() {
    super.initState();

    // 초기 위치 타입 설정
    if (widget.type == 'location') {
      // location type인 경우 rxLocationX, rxLocationY 값으로부터 설정
      _updatePositionTypeFromLocationValues();
      // 초기 텍스트 필드 값도 설정
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateFromLocationValues();
      });
    } else {
      // 기존 방식
      currentPositionType =
          PositionType.fromPositionValue(controller.rxObjectBackPosition.value);
      // 초기 X, Y 값 설정
      _updateXYFromPositionType(currentPositionType);
    }

    // 저장된 위치 정보 로드
    if (widget.saveId != null) {
      _loadSavedPositionInfo();
    }
  }

  /// 저장된 위치 정보를 로드하는 함수
  Future<void> _loadSavedPositionInfo() async {
    if (widget.saveId == null) return;

    try {
      final savedPosition = await PositionStorage.loadPosition(widget.saveId!);
      if (mounted) {
        setState(() {
          _savedPosition = savedPosition;
        });
      }
    } catch (e) {
      debugPrint('저장된 위치 정보 로드 실패: $e');
    }
  }

  /// 현재 위치를 브라우저 저장소에 저장하는 함수
  Future<void> _saveCurrentPosition() async {
    if (widget.saveId == null) return;

    try {
      // 현재 X, Y 값 가져오기
      double currentX = double.tryParse(xController.text) ?? 0.0;
      double currentY = double.tryParse(yController.text) ?? 0.0;

      // 현재 위치 타입의 문자열 값
      String currentPositionValue =
          currentPositionType?.getPositionValue() ?? '0% 0%';

      // PositionStorage를 사용하여 저장
      bool success = await PositionStorage.savePosition(
        saveId: widget.saveId!,
        x: currentX,
        y: currentY,
        positionType: currentPositionValue,
      );

      if (success) {
        // 저장 성공 시 저장된 정보 업데이트
        await _loadSavedPositionInfo();
      }

      // 저장 결과에 따른 메시지 표시
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('position_saved'.tr), // '위치가 저장되었습니다'
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.black,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('position_save_failed'.tr), // '위치 저장에 실패했습니다'
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('위치 저장 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('position_save_failed'.tr), // '위치 저장에 실패했습니다'
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 버튼에 표시할 텍스트를 생성하는 함수
  String _getButtonText() {
    String baseText = 'position_save'.tr;

    if (_savedPosition != null) {
      double x = _savedPosition!['x'];
      double y = _savedPosition!['y'];
      String unit = widget.unit ?? '%';

      return '$baseText (X: ${x.toInt()}$unit, Y: ${y.toInt()}$unit)';
    }

    return baseText;
  }

  void _updatePositionTypeFromLocationValues() {
    double x = controller.rxLocationX.value;
    double y = controller.rxLocationY.value;

    // px 값을 퍼센트로 변환하여 currentPositionType 설정
    double xPercent = _convertPxToPercent(x, true);
    double yPercent = _convertPxToPercent(y, false);

    String positionValue = "${xPercent.toInt()}% ${yPercent.toInt()}%";
    currentPositionType = PositionType.fromPositionValue(positionValue);

    // 텍스트 필드도 업데이트
    _updateTextFields(x, y, xPercent, yPercent);
  }

  void _updateTextFields(double x, double y, double xPercent, double yPercent) {
    // 빌드 중에 TextEditingController를 변경하지 않기 위해 다음 프레임에서 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return; // 위젯이 마운트되지 않은 경우 리턴

      // 포커스가 있으면 업데이트하지 않음
      if (widget.xFocusNode == null || !widget.xFocusNode!.hasFocus) {
        String newXValue;
        if (widget.unit == 'px') {
          newXValue = x.toInt().toString();
        } else {
          newXValue = xPercent.toInt().toString();
        }
        if (xController.text != newXValue) {
          try {
            xController.text = newXValue;
          } catch (e) {
            debugPrint('X 텍스트 필드 업데이트 실패: $e');
          }
        }
      }

      if (widget.yFocusNode == null || !widget.yFocusNode!.hasFocus) {
        String newYValue;
        if (widget.unit == 'px') {
          newYValue = y.toInt().toString();
        } else {
          newYValue = yPercent.toInt().toString();
        }
        if (yController.text != newYValue) {
          try {
            yController.text = newYValue;
          } catch (e) {
            debugPrint('Y 텍스트 필드 업데이트 실패: $e');
          }
        }
      }
    });
  }

  @override
  void didUpdateWidget(PositionItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    // location 타입일 때 위치 타입 업데이트
    if (widget.type == 'location') {
      PositionType? newPositionType = _getCurrentPositionType();
      if (currentPositionType != newPositionType) {
        setState(() {
          currentPositionType = newPositionType;
        });
      }

      // 텍스트 필드도 업데이트
      _updateFromLocationValues();
    }
  }

  @override
  void dispose() {
    xController.dispose();
    yController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ?? const EdgeInsets.all(0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.disabledTitle == false) ...[
            VulcanXText(
                //위치
                text: 'position'.tr,
                suffixIcon: const Icon(Icons.expand_more_rounded, size: 16.0)),
            const SizedBox(height: 8)
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                // width: 110,
                // height: 110,
                padding: const EdgeInsets.only(top: 9),
                width: 96,
                height: 102,
                child: VulcanXPosition<PositionType>(
                    key: ValueKey(currentPositionType?.name ?? 'none'),
                    initialEnumValue: currentPositionType,
                    enumValues: PositionType.values,
                    onPositionSelected: (row, col, enumValue) =>
                        _onPositionSelected(enumValue!)),
              ),
              const Spacer(),
              SizedBox(
                height: 110,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('X', style: context.bodyMedium),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 130,
                          child: VulcanXTextField(
                            controller: xController,
                            focusNode: widget.xFocusNode,
                            inputFormatters: [
                              // 숫자만 입력
                              // FilteringTextInputFormatter.allow(
                              //     RegExp(r'^\d*\.?\d*$')),
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d*')),
                            ],
                            textAlign: TextAlign.right,
                            suffixText: widget.unit ?? '%',
                            onChanged: (value) => _onXYChanged(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text('Y', style: context.bodyMedium),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 130,
                          child: VulcanXTextField(
                            controller: yController,
                            focusNode: widget.yFocusNode,
                            textAlign: TextAlign.right,
                            inputFormatters: [
                              // 숫자만 입력
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            suffixText: widget.unit ?? '%',
                            onChanged: (value) => _onXYChanged(),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (widget.saveId != null) ...[
            const SizedBox(height: 8),
            Flexible(
              child: VulcanXOutlinedButton(
                  width: double.infinity,
                  onPressed: _saveCurrentPosition, // 위치 저장 함수 연결
                  // 위치 저장
                  child: Text(_getButtonText())),
            ),
            const SizedBox(height: 8),
          ]
        ],
      ),
    );
  }

  void _updateFromLocationValues() {
    if (widget.type == 'location' && !_isPositionChanging) {
      double x = controller.rxLocationX.value;
      double y = controller.rxLocationY.value;

      double xPercent = _convertPxToPercent(x, true);
      double yPercent = _convertPxToPercent(y, false);

      _updateTextFields(x, y, xPercent, yPercent);
    }
  }

  /// 현재 위치 타입을 계산하여 반환 (상태 변경 없음)
  PositionType? _getCurrentPositionType() {
    if (widget.type == 'location') {
      double x = controller.rxLocationX.value;
      double y = controller.rxLocationY.value;

      double xPercent = _convertPxToPercent(x, true);
      double yPercent = _convertPxToPercent(y, false);

      String positionValue = "${xPercent.toInt()}% ${yPercent.toInt()}%";
      return PositionType.fromPositionValue(positionValue);
    }
    return currentPositionType;
  }

  void _onPositionSelected(PositionType positionType) {
    // 위치 변경 중 플래그 설정
    _isPositionChanging = true;

    // 포커스 해제
    widget.xFocusNode?.unfocus();
    widget.yFocusNode?.unfocus();

    // 직접 텍스트 필드 업데이트
    String positionValue = positionType.getPositionValue();

    // 우선 컨트롤러에 변경사항 적용 (이것이 rxLocationX/Y를 변경함)
    _updatePositionTypeAndController(positionValue);

    // 지연된 텍스트 필드 업데이트
    Future.delayed(const Duration(milliseconds: 50), () {
      List<String> parts = positionValue.split(' ');

      if (parts.length == 2) {
        String xValue = parts[0].replaceAll('%', '');
        String yValue = parts[1].replaceAll('%', '');

        if (widget.unit == 'px') {
          double xPercent = double.tryParse(xValue) ?? 0.0;
          double yPercent = double.tryParse(yValue) ?? 0.0;

          double xPx = _convertPercentToPx(xPercent, true);
          double yPx = _convertPercentToPx(yPercent, false);

          try {
            xController.text = xPx.toInt().toString();
            yController.text = yPx.toInt().toString();
          } catch (e) {
            debugPrint('위치 그리드 선택 시 텍스트 필드 업데이트 실패: $e');
          }
        } else {
          try {
            xController.text = xValue;
            yController.text = yValue;
          } catch (e) {
            debugPrint('위치 그리드 선택 시 텍스트 필드 업데이트 실패: $e');
          }
        }
      }

      // 플래그 해제
      _isPositionChanging = false;
    });
  }

  void _onXYChanged() {
    // X, Y 값으로부터 해당하는 PositionType 찾기
    String xValue = xController.text;
    String yValue = yController.text;

    // 숫자가 아닌 경우 무시
    if (xValue.isEmpty || yValue.isEmpty) return;

    try {
      double x = double.parse(xValue);
      double y = double.parse(yValue);

      // unit이 px인 경우 px 값을 퍼센트로 변환
      if (widget.unit == 'px') {
        double xPercent = _convertPxToPercent(x, true);
        double yPercent = _convertPxToPercent(y, false);

        // X, Y 값을 "X% Y%" 형태로 변환
        String positionValue = "${xPercent.toInt()}% ${yPercent.toInt()}%";
        _updatePositionTypeAndController(positionValue);
      } else {
        // X, Y 값을 "X% Y%" 형태로 변환
        String positionValue = "${x.toInt()}% ${y.toInt()}%";
        _updatePositionTypeAndController(positionValue);
      }
    } catch (e) {
      // 숫자 파싱 실패 시 무시
    }
  }

  void _updateXYFromPositionType(PositionType? positionType) {
    if (positionType == null) return;

    // PositionType의 getPositionValue()에서 "X% Y%" 형태의 문자열을 파싱
    String positionValue = positionType.getPositionValue();
    List<String> parts = positionValue.split(' ');

    if (parts.length == 2) {
      // X, Y 값에서 % 제거
      String xValue = parts[0].replaceAll('%', '');
      String yValue = parts[1].replaceAll('%', '');

      // unit이 px인 경우 퍼센트 값을 px로 환산
      if (widget.unit == 'px') {
        double xPercent = double.tryParse(xValue) ?? 0.0;
        double yPercent = double.tryParse(yValue) ?? 0.0;

        double xPx = _convertPercentToPx(xPercent, true);
        double yPx = _convertPercentToPx(yPercent, false);

        // 강제로 텍스트 필드 업데이트 (위치 그리드 클릭 시)
        try {
          xController.text = xPx.toInt().toString();
          yController.text = yPx.toInt().toString();
        } catch (e) {
          debugPrint('PositionType에서 텍스트 필드 업데이트 실패: $e');
        }
      } else {
        // X, Y 컨트롤러 값 업데이트
        try {
          xController.text = xValue;
          yController.text = yValue;
        } catch (e) {
          debugPrint('PositionType에서 텍스트 필드 업데이트 실패: $e');
        }
      }
    }
  }

  void _updatePositionTypeAndController(String positionValue) {
    // 현재 위치 타입 업데이트
    setState(() {
      currentPositionType = PositionType.fromPositionValue(positionValue);
    });

    // 컨트롤러에 변경사항 적용
    if (widget.type == 'body') {
      controller.setBodyBackImagePosition(positionValue);
    } else if (widget.type == 'location') {
      // location type인 경우 개별적으로 left, top 값 설정
      List<String> parts = positionValue.split(' ');
      if (parts.length == 2) {
        String xValue = parts[0].replaceAll('%', '');
        String yValue = parts[1].replaceAll('%', '');

        // unit이 px인 경우 px 값을 직접 사용, 아니면 퍼센트 값 사용
        if (widget.unit == 'px') {
          double xPercent = double.tryParse(xValue) ?? 0.0;
          double yPercent = double.tryParse(yValue) ?? 0.0;

          double xPx = _convertPercentToPx(xPercent, true);
          double yPx = _convertPercentToPx(yPercent, false);

          controller.setLeft(xPx.toString());
          controller.setTop(yPx.toString());
        } else {
          // 퍼센트 값을 그대로 사용
          controller.setLeft(xValue);
          controller.setTop(yValue);
        }
      }
    } else {
      controller.setObjectBackPosition(
          position: positionValue, type: widget.type);
    }
  }

  /// 퍼센트 값을 px로 변환 (위치별 기준점 고려)
  /// [percent] 퍼센트 값 (0-100)
  /// [isX] X축인지 Y축인지 구분
  double _convertPercentToPx(double percent, bool isX) {
    if (isX) {
      // X축: 위치에 따라 기준점 변경
      double pageWidth =
          controller.documentState.rxDocumentSizeWidth.value.toDouble();
      double objectWidth = controller.rxWidth.value;

      if (percent == 0) {
        // 0%: 왼쪽 기준 (오브젝트 왼쪽 = 페이지 왼쪽)
        return 0;
      } else if (percent == 100) {
        // 100%: 오른쪽 기준 (오브젝트 오른쪽 = 페이지 오른쪽)
        return pageWidth - objectWidth;
      } else {
        // 중간값: 선형 보간
        return (percent / 100) * (pageWidth - objectWidth);
      }
    } else {
      // Y축: 위치에 따라 기준점 변경
      double pageHeight =
          controller.documentState.rxDocumentSizeHeight.value.toDouble();
      double objectHeight = controller.rxHeight.value;

      if (percent == 0) {
        // 0%: 상단 기준 (오브젝트 상단 = 페이지 상단)
        return 0;
      } else if (percent == 100) {
        // 100%: 하단 기준 (오브젝트 하단 = 페이지 하단)
        return pageHeight - objectHeight;
      } else {
        // 중간값: 선형 보간
        return (percent / 100) * (pageHeight - objectHeight);
      }
    }
  }

  /// px 값을 퍼센트로 변환 (위치별 기준점 고려)
  /// [px] 픽셀 값
  /// [isX] X축인지 Y축인지 구분
  double _convertPxToPercent(double px, bool isX) {
    if (isX) {
      // X축: 오브젝트 크기를 고려한 퍼센트 계산
      double pageWidth =
          controller.documentState.rxDocumentSizeWidth.value.toDouble();
      double objectWidth = controller.rxWidth.value;
      double availableWidth = pageWidth - objectWidth;

      if (availableWidth <= 0) {
        // 오브젝트가 페이지보다 크거나 같은 경우
        return px <= 0 ? 0 : 100;
      }

      // px 값을 사용 가능한 대비 퍼센트로 변환
      double percent = (px / availableWidth) * 100;
      return percent.clamp(0, 100);
    } else {
      // Y축: 오브젝트 크기를 고려한 퍼센트 계산
      double pageHeight =
          controller.documentState.rxDocumentSizeHeight.value.toDouble();
      double objectHeight = controller.rxHeight.value;
      double availableHeight = pageHeight - objectHeight;

      if (availableHeight <= 0) {
        // 오브젝트가 페이지보다 크거나 같은 경우
        return px <= 0 ? 0 : 100;
      }

      // px 값을 사용 가능한 대비 퍼센트로 변환
      double percent = (px / availableHeight) * 100;
      return percent.clamp(0, 100);
    }
  }
}
