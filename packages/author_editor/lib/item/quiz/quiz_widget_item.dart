import 'package:app_ui/app_ui.dart';
import 'package:author_editor/enum/quiz_align_both_type.dart';
import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../vulcan_editor_eventbus.dart';

class QuizWidgetDesignItem extends StatelessWidget with EditorEventbus {
  QuizWidgetDesignItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 문제 형식 설정
          VulcanXText(
            text: '문제 템플릿 설정',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Obx(() => VulcanXSwitch(
                label: '헤더 표시',
                value: controller.rxShowHeader.value,
                onChanged: (value) => controller.setShowHeader(value),
              )),
          const SizedBox(height: 16),

          // 버튼 위치
          Obx(() => VulcanXSvgButtonSelector(
              //배치
              label: '버튼 위치'.tr,
              width: 150,
              initialEnum: controller.rxButtonPosition.value,
              enumValues: QuizAlignBothType.values,
              svgAssets: [
                CommonAssets.icon.alignHorizontalLeft,
                CommonAssets.icon.alignHorizontalCenter,
                CommonAssets.icon.alignHorizontalRight,
              ],
              onSelectedEnum: (placement) =>
                  {controller.setButtonPosition(placement!)})),
          const SizedBox(height: 16),
          // 배점 표시
          Obx(() => VulcanXSwitch(
                label: '배점 표시',
                value: controller.rxShowScore.value,
                onChanged: (value) => controller.setShowScore(value),
              )),
          const SizedBox(height: 16),
          Obx(() {
            if (!controller.rxShowScore.value) {
              return const SizedBox.shrink();
            }

            return Column(
              children: [
                // 보기 수 설정
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('배점  '),
                    CounterWidget(
                      initialValue: controller.rxScore.value.toString(),
                      width: 120,
                      height: 40,
                      minValue: 1,
                      maxValue: 100,
                      inputFormatters: [
                        // 숫자만 입력
                        FilteringTextInputFormatter.allow(
                            // RegExp(r'^\d*\.?\d*$')),
                            RegExp(r'^\d*\.?\d*')),
                      ],
                      unit: '점',
                      onChanged: (value) {
                        int? count = int.tryParse(
                            value.replaceAll(RegExp(r'[^0-9]'), ''));
                        controller.setScore(count ?? 2);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            );
          }),
          const HorDivider(), const SizedBox(height: 16),

          // 힌트 설정
          Obx(() => VulcanXSwitch(
                label: '힌트',
                value: controller.rxShowHints.value,
                onChanged: (value) => controller.setShowHints(value),
              )),
          const SizedBox(height: 16),

          // 설명 스위치
          Obx(() => VulcanXSwitch(
                label: '설명',
                value: controller.rxShowDescription.value,
                onChanged: (value) => controller.setShowDescription(value),
              )),
          const SizedBox(height: 16),
          const HorDivider(), const SizedBox(height: 16),

          // 답 보기 스위치
          Obx(() => VulcanXSwitch(
                label: '답 보기',
                value: controller.rxShowAnswer.value,
                onChanged: (value) => controller.setShowAnswer(value),
              )),
          const SizedBox(height: 16),

          // 체크된 정답 표시 스위치
          Obx(() => VulcanXSwitch(
                label: '체크된 정답 표시',
                value: controller.rxShowCheckedAnswer.value,
                onChanged: (value) => controller.setShowCheckedAnswer(value),
              )),
          const SizedBox(height: 16),

          // 문제 설명
          Obx(() => VulcanXSwitch(
                label: '문제 설명',
                value: controller.rxShowQuestionDescription.value,
                onChanged: (value) =>
                    controller.setShowQuestionDescription(value),
              )),
          const SizedBox(height: 16),
          const HorDivider(),
          const SizedBox(height: 16),
          // 보조 설명 표시 스위치
          Obx(() => VulcanXSwitch(
                label: '보조 설명 표시',
                value: controller.rxShowSubDescription.value,
                onChanged: (value) => controller.setShowSubDescription(value),
              )),
          const SizedBox(height: 16),
          // 답 선택시 보조 설명 표시
          Obx(() => VulcanXSwitch(
                label: '답 선택시 보조 설명 표시',
                value: controller.rxShowAnswerDescription.value,
                onChanged: (value) =>
                    controller.setShowAnswerDescription(value),
              )),
          const SizedBox(height: 16),
          const HorDivider(), const SizedBox(height: 16),

          // 정답 소리 스위치
          Obx(() => VulcanXSwitch(
                label: '정답 소리',
                value: controller.rxPlayCorrectSound.value,
                onChanged: (value) => controller.setPlayCorrectSound(value),
              )),
          const SizedBox(height: 16),

          // 정답 소리 파일 선택 (정답 소리가 켜진 경우에만)
          Obx(() {
            if (!controller.rxPlayCorrectSound.value) {
              return const SizedBox.shrink();
            }

            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                controller.rxCorrectSoundFile.value.isEmpty
                                    ? 'correct-answer-sample001.mp3'
                                    : controller.rxCorrectSoundFile.value,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            );
          }),

          // 오답 소리 스위치
          Obx(() => VulcanXSwitch(
                label: '오답 소리',
                value: controller.rxPlayIncorrectSound.value,
                onChanged: (value) => controller.setPlayIncorrectSound(value),
              )),
          const SizedBox(height: 16),

          // 오답 소리 파일 선택 (오답 소리가 켜진 경우에만)
          Obx(() {
            if (!controller.rxPlayIncorrectSound.value) {
              return const SizedBox.shrink();
            }

            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                controller.rxIncorrectSoundFile.value.isEmpty
                                    ? 'incorrect-answer-sample001.mp3'
                                    : controller.rxIncorrectSoundFile.value,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            );
          }),

          // 채점하기 표시 버튼
          Obx(() => VulcanXSwitch(
                label: '채점하기 표시',
                value: controller.rxShowResults.value,
                onChanged: (value) => controller.setShowResults(value),
              )),
          const SizedBox(height: 16),

          // 채점 소리 스위치
          Obx(() => VulcanXSwitch(
                label: '채점 소리',
                value: controller.rxPlayResultsSound.value,
                onChanged: (value) => controller.setPlayResultsSound(value),
              )),
          const SizedBox(height: 16),
          // 채점 소리 파일 선택 (채점 소리가 켜진 경우에만)
          Obx(() {
            if (!controller.rxPlayResultsSound.value) {
              return const SizedBox.shrink();
            }

            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                controller.rxResultsSoundFile.value.isEmpty
                                    ? 'results-sample001.mp3'
                                    : controller.rxResultsSoundFile.value,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            );
          }),
          const HorDivider(),
          const SizedBox(height: 16),

          // 합격 불합격 표시 버튼
          Obx(() => VulcanXSwitch(
                label: '합격 불합격 표시',
                value: controller.rxShowPassFail.value,
                onChanged: (value) => controller.setShowPassFail(value),
              )),
          const SizedBox(height: 16),

          // 합격 최소 점수 설정
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('합격 최소 점수'),
              CounterWidget(
                initialValue: controller.rxPassingScore.value.toString(),
                width: 120,
                height: 40,
                minValue: 10,
                maxValue: 1000,
                inputFormatters: [
                  // 숫자만 입력
                  // FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                unit: '',
                onChanged: (value) {
                  int? score =
                      int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), ''));
                  controller.setPassingScore(score ?? 100);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          const HorDivider(),
          const SizedBox(height: 16),

          // 총점 설정
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('총점'),
              CounterWidget(
                initialValue: controller.rxTotalScore.value.toString(),
                width: 120,
                height: 40,
                minValue: 10,
                maxValue: 1000,
                inputFormatters: [
                  // 숫자만 입력
                  // FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                unit: '',
                onChanged: (value) {
                  int? score =
                      int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), ''));
                  controller.setTotalScore(score ?? 100);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox.shrink(),
              LabelRectangleCheckbox(
                  label: '배점 균등 분할',
                  isChecked: controller.rxShowQuestionDescription.value,
                  onChanged: (value) => {
                        // controller.setShowQuestionDescription(value),
                      }),
            ],
          ),

          // Checkbox(
          //   value: controller.rxShowQuestionDescription.value,
          //   onChanged: (value) => controller.setShowQuestionDescription(value!),
          // ),
          const SizedBox(height: 16),
          const HorDivider(),
          const SizedBox(height: 16),
          // 원래대로 버튼
          VulcanXOutlinedButton.icon(
            width: double.infinity,
            onPressed: () => controller.resetQuizSettings(),
            icon: CommonAssets.icon.replay.svg(),
            child: Text('원래대로'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
