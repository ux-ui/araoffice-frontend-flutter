import 'dart:js_interop';

import 'package:author_editor/engine/engines.dart';
import 'package:author_editor/enum/quiz_align_both_type.dart';
import 'package:common_util/common_util.dart';
import 'package:get/get.dart';
import 'package:web/web.dart' as web;

mixin QuizWidgetMixin on GetxController {
  Editor? get editor;

  // 문제 형식 설정
  final RxBool rxShowHeader = true.obs; // 헤더 표시
  final RxString rxHeaderContentPosition = 'left'.obs; // 헤더 내용 위치
  final RxBool rxShowHints = false.obs; // 비듬 위치
  final RxInt rxScore = 2.obs; // 배점
  final RxInt rxChoiceCount = 4.obs; // 보기 개수

  // 버튼 위치
  final Rx<QuizAlignBothType> rxButtonPosition =
      QuizAlignBothType.left.obs; // 버튼 위치

  // 배점 표시
  final RxBool rxShowScore = true.obs; // 배점 표시 (hasPoint)
  final RxBool rxShowQuestion = true.obs; // 지시문 표시 (hasQuestion)
  final RxBool rxShowCorrectIfWrong = false.obs; // 오답시 정답 표시

  final RxBool rxShowDescription = true.obs; // 설명 표시 (hasExplain)
  final RxBool rxShowAnswer = true.obs; // 답 보기 (hasShowAnswer)

  // 보조 설명 표시
  final RxBool rxHasLeftHelp = false.obs; // 왼쪽 보조 설명
  final RxBool rxHasRightHelp = false.obs; // 오른쪽 보조 설명
  final RxBool rxHasTopHelp = false.obs; // 위쪽 보조 설명
  final RxBool rxHasBottomHelp = false.obs; // 아래쪽 보조 설명
  final RxBool rxShowAnswerInput = true.obs; // 답안 입력 표시
  final RxBool rxShowResults = true.obs; // 해결 결과 표시
  final RxBool rxShowPassFail = true.obs; // 합격 불합격 표시
  final RxBool rxPlayAnswerSound = true.obs; // 답안 소리

  // 보조 설명 표시 (레거시 - 호환성 유지)
  final RxBool rxShowQuestionDescription = true.obs; // 문제 설명 표시
  final RxBool rxShowSubDescription = true.obs; // 보조 설명 표시
  final RxBool rxShowAnswerDescription = true.obs; // 답 선택시 보조 설명 표시

  // 채점 소리
  final RxBool rxPlayResultsSound = true.obs; // 채점 소리
  final RxString rxResultsSoundFile = ''.obs; // 채점 소리 파일

  // 힌트 설정
  final RxBool rxPlayCorrectSound = true.obs; // 정답 소리
  final RxString rxCorrectSoundFile = ''.obs; // 정답 소리 파일
  final RxBool rxPlayIncorrectSound = true.obs; // 오답 소리
  final RxString rxIncorrectSoundFile = ''.obs; // 오답 소리 파일
  final RxBool rxShowCheckedAnswer = true.obs; // 체크된 정답 표시
  final RxBool rxPlaySaveSound = false.obs; // 저장 소리
  final RxString rxSaveSoundFile = ''.obs; // 저장 소리 파일

  // 학습 활동 표시
  final RxInt rxQuestionCount = 5.obs; // 문제 갯수
  final RxInt rxTotalScore = 100.obs; // 총점
  final RxInt rxPassingScore = 60.obs; // 합격 점수

  // 원래 저장용 변수들
  bool? _originalShowHeader;
  String? _originalHeaderContentPosition;
  bool? _originalShowScore;
  int? _originalScore;
  bool? _originalShowHints;
  bool? _originalShowDescription;
  bool? _originalShowAnswer;
  bool? _originalShowQuestion;
  bool? _originalShowCorrectIfWrong;
  bool? _originalHasLeftHelp;
  bool? _originalHasRightHelp;
  bool? _originalHasTopHelp;
  bool? _originalHasBottomHelp;
  bool? _originalPlayCorrectSound;
  bool? _originalPlayIncorrectSound;
  bool? _originalShowCheckedAnswer;
  bool? _originalPlaySaveSound;
  String? _originalSaveSoundFile;
  bool? _originalPlayAnswerSound;
  String? _originalCorrectSoundFile;
  String? _originalIncorrectSoundFile;

  void initQuiz() {
    rxShowHeader.value = true;
    rxShowScore.value = true;
    rxScore.value = 2;
    rxShowHints.value = false;
    rxChoiceCount.value = 4;
  }

  void editInit() {
    if (editor == null) return;

    final selectedWidget = editor?.selectedWidget() as web.Node?;
    if (selectedWidget == null) return;

    try {
      // CommonQuestionWidgetInfo 속성들
      final hasHeader = editor?.getWidgetProperty(selectedWidget, 'hasHeader');
      if (hasHeader != null) {
        final dynamic dynamicHasHeader = hasHeader;
        if (dynamicHasHeader is bool) {
          rxShowHeader.value = dynamicHasHeader;
        }
      }

      final headerContentPosition =
          editor?.getWidgetProperty(selectedWidget, 'headerContentPosition');
      if (headerContentPosition != null) {
        final dynamic dynamicHeaderContentPosition = headerContentPosition;
        if (dynamicHeaderContentPosition is String) {
          rxHeaderContentPosition.value = dynamicHeaderContentPosition;
        }
      }

      final hasPoint = editor?.getWidgetProperty(selectedWidget, 'hasPoint');
      if (hasPoint != null) {
        final dynamic dynamicHasPoint = hasPoint;
        if (dynamicHasPoint is bool) {
          rxShowScore.value = dynamicHasPoint;
        }
      }

      final point = editor?.getWidgetProperty(selectedWidget, 'point');
      if (point != null) {
        final dynamic dynamicPoint = point;
        if (dynamicPoint is int) {
          rxScore.value = dynamicPoint;
        } else if (dynamicPoint is num) {
          rxScore.value = dynamicPoint.toInt();
        }
      }

      final hasHint = editor?.getWidgetProperty(selectedWidget, 'hasHint');
      if (hasHint != null) {
        final dynamic dynamicHasHint = hasHint;
        if (dynamicHasHint is bool) {
          rxShowHints.value = dynamicHasHint;
        }
      }

      final hasExplain =
          editor?.getWidgetProperty(selectedWidget, 'hasExplain');
      if (hasExplain != null) {
        final dynamic dynamicHasExplain = hasExplain;
        if (dynamicHasExplain is bool) {
          rxShowDescription.value = dynamicHasExplain;
        }
      }

      final hasShowAnswer =
          editor?.getWidgetProperty(selectedWidget, 'hasShowAnswer');
      if (hasShowAnswer != null) {
        final dynamic dynamicHasShowAnswer = hasShowAnswer;
        if (dynamicHasShowAnswer is bool) {
          rxShowAnswer.value = dynamicHasShowAnswer;
        }
      }

      final hasQuestion =
          editor?.getWidgetProperty(selectedWidget, 'hasQuestion');
      if (hasQuestion != null) {
        final dynamic dynamicHasQuestion = hasQuestion;
        if (dynamicHasQuestion is bool) {
          rxShowQuestion.value = dynamicHasQuestion;
        }
      }

      final showCorrectIfWrong =
          editor?.getWidgetProperty(selectedWidget, 'showCorrectIfWrong');
      if (showCorrectIfWrong != null) {
        final dynamic dynamicShowCorrectIfWrong = showCorrectIfWrong;
        if (dynamicShowCorrectIfWrong is bool) {
          rxShowCorrectIfWrong.value = dynamicShowCorrectIfWrong;
        }
      }

      final hasLeftHelp =
          editor?.getWidgetProperty(selectedWidget, 'hasLeftHelp');
      if (hasLeftHelp != null) {
        final dynamic dynamicHasLeftHelp = hasLeftHelp;
        if (dynamicHasLeftHelp is bool) {
          rxHasLeftHelp.value = dynamicHasLeftHelp;
        }
      }

      final hasRightHelp =
          editor?.getWidgetProperty(selectedWidget, 'hasRightHelp');
      if (hasRightHelp != null) {
        final dynamic dynamicHasRightHelp = hasRightHelp;
        if (dynamicHasRightHelp is bool) {
          rxHasRightHelp.value = dynamicHasRightHelp;
        }
      }

      final hasTopHelp =
          editor?.getWidgetProperty(selectedWidget, 'hasTopHelp');
      if (hasTopHelp != null) {
        final dynamic dynamicHasTopHelp = hasTopHelp;
        if (dynamicHasTopHelp is bool) {
          rxHasTopHelp.value = dynamicHasTopHelp;
        }
      }

      final hasBottomHelp =
          editor?.getWidgetProperty(selectedWidget, 'hasBottomHelp');
      if (hasBottomHelp != null) {
        final dynamic dynamicHasBottomHelp = hasBottomHelp;
        if (dynamicHasBottomHelp is bool) {
          rxHasBottomHelp.value = dynamicHasBottomHelp;
        }
      }

      final correctAudioPath =
          editor?.getWidgetProperty(selectedWidget, 'correctAudioPath');
      if (correctAudioPath != null) {
        rxCorrectSoundFile.value = correctAudioPath.toString();
      }

      final wrongAudioPath =
          editor?.getWidgetProperty(selectedWidget, 'wrongAudioPath');
      if (wrongAudioPath != null) {
        rxIncorrectSoundFile.value = wrongAudioPath.toString();
      }

      // 원본 값 저장
      _originalShowHeader = rxShowHeader.value;
      _originalHeaderContentPosition = rxHeaderContentPosition.value;
      _originalShowScore = rxShowScore.value;
      _originalScore = rxScore.value;
      _originalShowHints = rxShowHints.value;
      _originalShowDescription = rxShowDescription.value;
      _originalShowAnswer = rxShowAnswer.value;
      _originalShowQuestion = rxShowQuestion.value;
      _originalShowCorrectIfWrong = rxShowCorrectIfWrong.value;
      _originalHasLeftHelp = rxHasLeftHelp.value;
      _originalHasRightHelp = rxHasRightHelp.value;
      _originalHasTopHelp = rxHasTopHelp.value;
      _originalHasBottomHelp = rxHasBottomHelp.value;
      _originalCorrectSoundFile = rxCorrectSoundFile.value;
      _originalIncorrectSoundFile = rxIncorrectSoundFile.value;
    } catch (e) {
      logger.e('퀴즈 위젯 초기화 오류: $e');
    }
  }

  void setProperty(String name, dynamic value) {
    if (editor == null) return;

    final selectedWidget = editor?.selectedWidget() as web.Node?;
    if (selectedWidget == null) return;

    if (value == null) {
      logger.e('경고: $name 속성에 null 값이 전달되었습니다.');
      return;
    }

    // dynamic 값을 JS로 변환하는 로직
    dynamic jsValue;
    try {
      if (value is String) {
        jsValue = value.toJS;
      } else if (value is bool) {
        jsValue = value.toJS;
      } else if (value is num) {
        jsValue = value.toJS;
      } else {
        // 다른 타입에 대한 처리 로직
        jsValue = value.toString().toJS;
      }
    } catch (e) {
      logger.e('속성 설정 중 오류 발생: $name, 값: $value, 오류: $e');
      return;
    }

    editor?.setWidgetProperty(selectedWidget, name, jsValue);
  }

  dynamic getProperty(String name) {
    if (editor == null) return null;

    final selectedWidget = editor?.selectedWidget() as web.Node?;
    if (selectedWidget == null) return null;

    try {
      final property = editor?.getWidgetProperty(selectedWidget, name);
      if (property == null) return null;

      final dynamic dynamicProperty = property;

      if (dynamicProperty is String) {
        return dynamicProperty;
      } else if (dynamicProperty is bool) {
        return dynamicProperty;
      } else if (dynamicProperty is int) {
        return dynamicProperty;
      } else if (dynamicProperty is num) {
        return dynamicProperty;
      } else {
        // 다른 타입의 경우 문자열로 변환
        return dynamicProperty.toString();
      }
    } catch (e) {
      logger.e('속성 가져오기 중 오류 발생: $name, 오류: $e');
      return null;
    }
  }

  void syncPropertiesFromWidget() {
    if (editor == null) return;

    final selectedWidget = editor?.selectedWidget() as web.Node?;
    if (selectedWidget == null) return;

    try {
      // CommonQuestionWidgetInfo 속성들
      final hasHeader = getProperty('hasHeader');
      if (hasHeader != null && hasHeader is bool) {
        rxShowHeader.value = hasHeader;
      }

      final headerContentPosition = getProperty('headerContentPosition');
      if (headerContentPosition != null && headerContentPosition is String) {
        rxHeaderContentPosition.value = headerContentPosition;
        try {
          rxButtonPosition.value = QuizAlignBothType.values.firstWhere(
            (e) => e.name == headerContentPosition,
            orElse: () => QuizAlignBothType.left,
          );
        } catch (e) {}
      }

      final hasPoint = getProperty('hasPoint');
      if (hasPoint != null && hasPoint is bool) {
        rxShowScore.value = hasPoint;
      }

      final point = getProperty('point');
      if (point != null) {
        if (point is int) {
          rxScore.value = point;
        } else if (point is num) {
          rxScore.value = point.toInt();
        }
      }

      final hasHint = getProperty('hasHint');
      if (hasHint != null && hasHint is bool) {
        rxShowHints.value = hasHint;
      }

      final hasExplain = getProperty('hasExplain');
      if (hasExplain != null && hasExplain is bool) {
        rxShowDescription.value = hasExplain;
      }

      final hasShowAnswer = getProperty('hasShowAnswer');
      if (hasShowAnswer != null && hasShowAnswer is bool) {
        rxShowAnswer.value = hasShowAnswer;
      }

      final hasQuestion = getProperty('hasQuestion');
      if (hasQuestion != null && hasQuestion is bool) {
        rxShowQuestion.value = hasQuestion;
        rxShowQuestionDescription.value = hasQuestion;
      }

      final showCorrectIfWrong = getProperty('showCorrectIfWrong');
      if (showCorrectIfWrong != null && showCorrectIfWrong is bool) {
        rxShowCorrectIfWrong.value = showCorrectIfWrong;
      }

      final hasLeftHelp = getProperty('hasLeftHelp');
      if (hasLeftHelp != null && hasLeftHelp is bool) {
        rxHasLeftHelp.value = hasLeftHelp;
      }

      final hasRightHelp = getProperty('hasRightHelp');
      if (hasRightHelp != null && hasRightHelp is bool) {
        rxHasRightHelp.value = hasRightHelp;
      }

      final hasTopHelp = getProperty('hasTopHelp');
      if (hasTopHelp != null && hasTopHelp is bool) {
        rxHasTopHelp.value = hasTopHelp;
      }

      final hasBottomHelp = getProperty('hasBottomHelp');
      if (hasBottomHelp != null && hasBottomHelp is bool) {
        rxHasBottomHelp.value = hasBottomHelp;
      }

      final correctAudioPath = getProperty('correctAudioPath');
      if (correctAudioPath != null) {
        rxCorrectSoundFile.value = correctAudioPath.toString();
      }

      final wrongAudioPath = getProperty('wrongAudioPath');
      if (wrongAudioPath != null) {
        rxIncorrectSoundFile.value = wrongAudioPath.toString();
      }

      // 원본 값 저장 (동기화 후)
      _originalShowHeader = rxShowHeader.value;
      _originalHeaderContentPosition = rxHeaderContentPosition.value;
      _originalShowScore = rxShowScore.value;
      _originalScore = rxScore.value;
      _originalShowHints = rxShowHints.value;
      _originalShowDescription = rxShowDescription.value;
      _originalShowAnswer = rxShowAnswer.value;
      _originalShowQuestion = rxShowQuestion.value;
      _originalShowCorrectIfWrong = rxShowCorrectIfWrong.value;
      _originalHasLeftHelp = rxHasLeftHelp.value;
      _originalHasRightHelp = rxHasRightHelp.value;
      _originalHasTopHelp = rxHasTopHelp.value;
      _originalHasBottomHelp = rxHasBottomHelp.value;
      _originalCorrectSoundFile = rxCorrectSoundFile.value;
      _originalIncorrectSoundFile = rxIncorrectSoundFile.value;
    } catch (e) {
      logger.e('위젯 속성 동기화 중 오류 발생: $e');
    }
  }

  // === Quiz Widget 관련 메서드들 ===

  // 문제 형식 설정 메서드들
  void setButtonPosition(QuizAlignBothType value) {
    rxButtonPosition.value = value;
    setProperty('headerContentPosition', value.name);
  }

  void setShowScore(bool value) {
    rxShowScore.value = value;
    setProperty('hasPoint', value);
  }

  void setShowHeader(bool value) {
    rxShowHeader.value = value;
    setProperty('hasHeader', value);
  }

  void hasHeader(bool value) {
    rxShowHeader.value = value;
    setProperty('hasHeader', value);
  }

  void setShowHints(bool value) {
    rxShowHints.value = value;
    setProperty('hasHint', value);
  }

  void setScore(int score) {
    rxScore.value = score;
    setProperty('point', score);
  }

  void setChoiceCount(int count) {
    if (count >= 2 && count <= 6) {
      rxChoiceCount.value = count;
      // Choice 위젯 전용 속성
    }
  }

  void setShowDescription(bool value) {
    rxShowDescription.value = value;
    setProperty('hasExplain', value);
  }

  void setShowQuestionDescription(bool value) {
    rxShowQuestionDescription.value = value;
    setProperty('hasQuestion', value);
  }

  void setShowQuestion(bool value) {
    rxShowQuestion.value = value;
    setProperty('hasQuestion', value);
  }

  void setShowCorrectIfWrong(bool value) {
    rxShowCorrectIfWrong.value = value;
    setProperty('showCorrectIfWrong', value);
  }

  void setHeaderContentPosition(String value) {
    // left, center, right
    rxHeaderContentPosition.value = value;
    setProperty('headerContentPosition', value);
  }

  void setShowAnswer(bool value) {
    rxShowAnswer.value = value;
    setProperty('hasShowAnswer', value);
  }

  void setHasLeftHelp(bool value) {
    rxHasLeftHelp.value = value;
    setProperty('hasLeftHelp', value);
  }

  void setHasRightHelp(bool value) {
    rxHasRightHelp.value = value;
    setProperty('hasRightHelp', value);
  }

  void setHasTopHelp(bool value) {
    rxHasTopHelp.value = value;
    setProperty('hasTopHelp', value);
  }

  void setHasBottomHelp(bool value) {
    rxHasBottomHelp.value = value;
    setProperty('hasBottomHelp', value);
  }

  // 레거시 메서드들 (호환성 유지)
  void setShowAnswerInput(bool value) {
    rxShowAnswerInput.value = value;
  }

  void setShowSubDescription(bool value) {
    rxShowSubDescription.value = value;
  }

  void setShowAnswerDescription(bool value) {
    rxShowAnswerDescription.value = value;
  }

  void setPlayResultsSound(bool value) {
    rxPlayResultsSound.value = value;
  }

  void setResultsSoundFile(String filePath) {
    rxResultsSoundFile.value = filePath;
  }

  // 힌트 설정 메서드들
  void setPlayCorrectSound(bool value) {
    rxPlayCorrectSound.value = value;
  }

  void setCorrectSoundFile(String filePath) {
    rxCorrectSoundFile.value = filePath;
    setProperty('correctAudioPath', filePath);
  }

  void setPlayIncorrectSound(bool value) {
    rxPlayIncorrectSound.value = value;
  }

  void setIncorrectSoundFile(String filePath) {
    rxIncorrectSoundFile.value = filePath;
    setProperty('wrongAudioPath', filePath);
  }

  void setShowCheckedAnswer(bool value) {
    rxShowCheckedAnswer.value = value;
  }

  void setPlaySaveSound(bool value) {
    rxPlaySaveSound.value = value;
  }

  void setSaveSoundFile(String filePath) {
    rxSaveSoundFile.value = filePath;
  }

  void setPlayAnswerSound(bool value) {
    rxPlayAnswerSound.value = value;
  }

  // 학습 활동 표시 메서드들
  void setQuestionCount(int count) {
    if (count >= 1 && count <= 20) {
      rxQuestionCount.value = count;
    }
  }

  void setTotalScore(int score) {
    if (score >= 10 && score <= 1000) {
      rxTotalScore.value = score;
      // 합격 점수가 총점을 초과하지 않도록 조정
      if (rxPassingScore.value > score) {
        rxPassingScore.value = score;
      }
    }
  }

  void setPassingScore(int score) {
    if (score >= 0 && score <= rxTotalScore.value) {
      rxPassingScore.value = score;
    }
  }

  void setShowResults(bool value) {
    rxShowResults.value = value;
  }

  void setShowPassFail(bool value) {
    rxShowPassFail.value = value;
  }

  // 설정 초기화 메서드
  void resetQuizSettings() {
    if (_originalShowHeader == null) return; // 저장된 값이 없으면 실행하지 않음

    try {
      // UI 값 복원
      rxShowHeader.value = _originalShowHeader ?? true;
      rxHeaderContentPosition.value = _originalHeaderContentPosition ?? 'left';
      rxShowScore.value = _originalShowScore ?? true;
      rxScore.value = _originalScore ?? 2;
      rxShowHints.value = _originalShowHints ?? false;
      rxShowDescription.value = _originalShowDescription ?? true;
      rxShowAnswer.value = _originalShowAnswer ?? true;
      rxShowQuestion.value = _originalShowQuestion ?? true;
      rxShowCorrectIfWrong.value = _originalShowCorrectIfWrong ?? false;
      rxHasLeftHelp.value = _originalHasLeftHelp ?? false;
      rxHasRightHelp.value = _originalHasRightHelp ?? false;
      rxHasTopHelp.value = _originalHasTopHelp ?? false;
      rxHasBottomHelp.value = _originalHasBottomHelp ?? false;
      rxCorrectSoundFile.value = _originalCorrectSoundFile ?? '';
      rxIncorrectSoundFile.value = _originalIncorrectSoundFile ?? '';

      // 실제 위젯 속성 설정
      setProperty('hasHeader', rxShowHeader.value);
      setProperty('headerContentPosition', rxHeaderContentPosition.value);
      setProperty('hasPoint', rxShowScore.value);
      setProperty('point', rxScore.value);
      setProperty('hasHint', rxShowHints.value);
      setProperty('hasExplain', rxShowDescription.value);
      setProperty('hasShowAnswer', rxShowAnswer.value);
      setProperty('hasQuestion', rxShowQuestion.value);
      setProperty('showCorrectIfWrong', rxShowCorrectIfWrong.value);
      setProperty('hasLeftHelp', rxHasLeftHelp.value);
      setProperty('hasRightHelp', rxHasRightHelp.value);
      setProperty('hasTopHelp', rxHasTopHelp.value);
      setProperty('hasBottomHelp', rxHasBottomHelp.value);
      setProperty('correctAudioPath', rxCorrectSoundFile.value);
      setProperty('wrongAudioPath', rxIncorrectSoundFile.value);
    } catch (e) {
      logger.e('원래 설정으로 되돌리기 중 오류 발생: $e');
    }
  }
}
