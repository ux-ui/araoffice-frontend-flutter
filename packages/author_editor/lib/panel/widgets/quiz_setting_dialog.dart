import 'package:author_editor/vulcan_editor_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuizSettingsDialog extends StatefulWidget {
  QuizSettingsDialog({super.key});

  @override
  State<QuizSettingsDialog> createState() => _QuizSettingsDialogState();
}

class _QuizSettingsDialogState extends State<QuizSettingsDialog> {
  final VulcanEditorController controller = Get.find<VulcanEditorController>();

  bool headerDisplay = true;
  String buttonPosition = 'circle';
  int multiple = 1;
  bool hint = true;
  bool answer = true;
  bool answerSelection = false;
  bool answerDisplayJump = false;
  bool specialEffects = true;
  bool audioSound = false;
  bool puzzleEvent = false;
  bool rightAnswerSound = true;
  bool rightAnswerDisplay = false;
  bool wrongAnswerSound = true;
  bool wrongAnswerDisplay = false;
  bool iconAnswerSound = true;
  bool iconAnswerDisplay = false;
  bool autoRetry = false;
  int autoRetryCount = 0;
  bool combineCorrect = false;
  bool combineCorrectDisplay = false;
  int attempts = 10;
  double progressValue = 50;

  String? markupData;
  String? selectedAnswer; // 'true' or 'false'

  TextEditingController quizContentController =
      TextEditingController(text: '질문을 입력하세요');

  @override
  void initState() {
    super.initState();
    quizContentController.text = '질문을 입력하세요';
    getQuizSettings();
  }

  void getQuizSettings() async {
    final result = await controller.apiService
        .addWidget('p4a80b18f', 'question', 'truefalse');
    if (result != null && result.markup != null) {
      setState(() {
        markupData = result.markup;
        // HTML에서 data-answer 속성 추출
        final answerMatch =
            RegExp(r'data-answer="([^"]+)"').firstMatch(result.markup!);
        if (answerMatch != null) {
          selectedAnswer = answerMatch.group(1);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Content
            Expanded(
              child: Row(
                children: [
                  // Left Sidebar
                  _buildLeftSidebar(),

                  // Center Panel
                  Expanded(child: _buildCenterPanel()),

                  // Right Preview Panel
                  _buildRightPreview(),
                ],
              ),
            ),

            // Footer
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '문제 템플릿 설정',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.help_outline),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeftSidebar() {
    return Container(
      width: 280,
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildToggleRow('헤더 표시', headerDisplay, (val) {
              setState(() => headerDisplay = val);
            }),
            const SizedBox(height: 16),

            // 버튼 위치
            const Text('버튼 위치',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildRadio('왼쪽', 'left'),
                const SizedBox(width: 16),
                _buildRadio('가운데', 'auto'),
                const SizedBox(width: 16),
                _buildRadio('오른쪽', 'circle'),
              ],
            ),
            const SizedBox(height: 16),

            // 배점
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('배점',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                Row(
                  children: [
                    SizedBox(
                      width: 60,
                      height: 32,
                      child: TextField(
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        controller: TextEditingController(text: '$multiple'),
                        onChanged: (val) =>
                            setState(() => multiple = int.tryParse(val) ?? 1),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildCustomSwitch(true, (val) {}),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildToggleRow('힌트', hint, (val) => setState(() => hint = val)),
            _buildToggleRow(
                '설명', answer, (val) => setState(() => answer = val)),
            _buildToggleRow('답 보기', answerSelection,
                (val) => setState(() => answerSelection = val)),
            _buildToggleRow('답 선택시 정답 표시', answerDisplayJump,
                (val) => setState(() => answerDisplayJump = val)),
            _buildToggleRow('특별 설명', specialEffects,
                (val) => setState(() => specialEffects = val)),

            const SizedBox(height: 16),
            _buildRowWithMenu('정답 소리'),
            const SizedBox(height: 16),
            _buildRowWithMenu('퍼즐 이벤트'),
            const SizedBox(height: 16),
            _buildRowWithMenu('오답 소리'),
            const SizedBox(height: 16),
            _buildRowWithMenu('퍼즐 이벤트'),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('아이콘 동일하게 적용'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterPanel() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Toolbar
          Row(
            children: [
              _buildToolbarButton('1'),
              const SizedBox(width: 8),
              _buildToolbarButton('+', icon: Icons.add),
              const SizedBox(width: 8),
              _buildToolbarButton('', icon: Icons.crop_square),
              const SizedBox(width: 8),
              _buildToolbarButton('✓', isActive: true),
            ],
          ),
          const SizedBox(height: 16),

          // Quiz Content Area
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD1D5DB), width: 2),
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFFF9FAFB),
              ),
              padding: const EdgeInsets.all(5),
              child: markupData != null
                  ? _buildTrueFalseWidget()
                  : const Center(
                      child: CircularProgressIndicator(),
                    ),
            ),
          ),
          const SizedBox(height: 16),

          // Progress Bar
          Slider(
            value: progressValue,
            min: 0,
            max: 100,
            activeColor: Colors.green,
            onChanged: (val) => setState(() => progressValue = val),
          ),
          const SizedBox(height: 16),

          // Bottom Options
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildToggleRow('원음 보조 설명', rightAnswerSound,
                        (val) => setState(() => rightAnswerSound = val)),
                    _buildToggleRow('답 선택시 표시', rightAnswerDisplay,
                        (val) => setState(() => rightAnswerDisplay = val)),
                    _buildToggleRow('오른쪽 보조 설명', wrongAnswerSound,
                        (val) => setState(() => wrongAnswerSound = val)),
                    _buildToggleRow('답 선택시 표시', wrongAnswerDisplay,
                        (val) => setState(() => wrongAnswerDisplay = val)),
                    _buildToggleRow('아래쪽 보조 설명', iconAnswerSound,
                        (val) => setState(() => iconAnswerSound = val)),
                    _buildToggleRow('답 선택시 표시', iconAnswerDisplay,
                        (val) => setState(() => iconAnswerDisplay = val)),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    _buildToggleRow('채점하기 버튼', autoRetry,
                        (val) => setState(() => autoRetry = val)),
                    _buildRowWithMenu('채점 소리'),
                    const SizedBox(height: 12),
                    _buildToggleRow('합격 특별 점수 표시', combineCorrect,
                        (val) => setState(() => combineCorrect = val)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('합격 최소 점수', style: TextStyle(fontSize: 14)),
                        SizedBox(
                          width: 60,
                          height: 32,
                          child: TextField(
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4)),
                            ),
                            controller:
                                TextEditingController(text: '$autoRetryCount'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('총점', style: TextStyle(fontSize: 14)),
                        Row(
                          children: [
                            SizedBox(
                              width: 60,
                              height: 32,
                              child: TextField(
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  contentPadding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4)),
                                ),
                                controller:
                                    TextEditingController(text: '$attempts'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                minimumSize: Size.zero,
                              ),
                              child: const Text('배점 균등 분포',
                                  style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRightPreview() {
    return Container(
      width: 320,
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: Color(0xFFE5E7EB))),
        color: Color(0xFFF9FAFB),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFBFDBFE),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(24),
            height: 280,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '문제 타입별 힌트 텍스트',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blue, width: 2),
                      ),
                      child: const Center(
                        child: Text(
                          'O',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 64),
                    const Text(
                      '×',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPreviewIcon('📷'),
                    const SizedBox(width: 8),
                    _buildPreviewIcon('🔊'),
                    const SizedBox(width: 8),
                    _buildPreviewIcon('✓', isActive: true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewIcon(String icon, {bool isActive = false}) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Center(
        child: Text(
          icon,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: () {},
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('적용'),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('확인'),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('취소'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(String label, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          _buildCustomSwitch(value, onChanged),
        ],
      ),
    );
  }

  Widget _buildCustomSwitch(bool value, Function(bool) onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 44,
        height: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: value ? const Color(0xFFEF4444) : const Color(0xFFE5E7EB),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRadio(String label, String value) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: buttonPosition,
          onChanged: (val) => setState(() => buttonPosition = val!),
        ),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildToolbarButton(String text,
      {IconData? icon, bool isActive = false}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(4),
        color: isActive ? const Color(0xFF1F2937) : Colors.white,
      ),
      child: Center(
        child: icon != null
            ? Icon(icon,
                size: 18, color: isActive ? Colors.white : Colors.black)
            : Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  color: isActive ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }

  Widget _buildRowWithMenu(String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        IconButton(
          icon: const Icon(Icons.more_horiz, size: 20),
          onPressed: () {},
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildTrueFalseWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header with buttons
        if (headerDisplay)
          Container(
            margin: const EdgeInsets.only(bottom: 5),
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildHeaderButton(Icons.lightbulb_outline, '힌트'),
                const SizedBox(width: 5),
                _buildHeaderButton(Icons.info_outline, '설명'),
                const SizedBox(width: 5),
                _buildHeaderButton(Icons.visibility_outlined, '정답 보기'),
                const SizedBox(width: 5),
                _buildHeaderButton(Icons.check_circle_outline, '채점'),
                const SizedBox(width: 5),
                _buildHeaderButton(Icons.refresh, '새로고침'),
              ],
            ),
          ),
        // Question input area
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.only(bottom: 5),
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: TextField(
              controller: quizContentController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.center,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
              ),
              decoration: const InputDecoration(
                hintText: '질문을 입력하세요',
                hintStyle: TextStyle(
                  color: Color(0xFF9CA3AF),
                ),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
            ),
          ),
        ),
        // Answer container with O/X
        Expanded(
          flex: 1,
          child: Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAnswerButton(
                  isO: true,
                  isSelected: selectedAnswer == 'true',
                ),
                const SizedBox(width: 20),
                _buildAnswerButton(
                  isO: false,
                  isSelected: selectedAnswer == 'false',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderButton(IconData icon, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(3),
          child: Container(
            width: 25,
            height: 25,
            padding: const EdgeInsets.all(2),
            child: Icon(
              icon,
              size: 20,
              color: const Color(0xFF374151),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerButton({required bool isO, required bool isSelected}) {
    final scale = isSelected ? 1.7 : 1.0;
    final color = isO ? Colors.blue : Colors.red;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAnswer = isO ? 'true' : 'false';
        });
      },
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Container(
          width: 30,
          height: 30,
          // margin: const EdgeInsets.symmetric(horizontal: 10),
          // decoration: isO
          //     ? BoxDecoration(
          //         shape: BoxShape.circle,
          //         border: Border.all(
          //           color: color,
          //           width: 3,
          //         ),
          //       )
          //     : null,
          child: isO
              ? Center(
                  child: Text(
                    'O',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                )
              : Text(
                  'X',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    quizContentController.dispose();
    super.dispose();
  }
}

// 사용 예시
void showQuizSettings(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => QuizSettingsDialog(),
  );
}
