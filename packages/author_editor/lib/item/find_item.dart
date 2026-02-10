import 'dart:async';

import 'package:author_editor/vulcan_editor_controller.dart';
import 'package:author_editor/vulcan_editor_eventbus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FindItem extends StatefulWidget {
  const FindItem({super.key});

  @override
  State<FindItem> createState() => _FindItemState();
}

class _FindItemState extends State<FindItem> with EditorEventbus {
  late final TextEditingController _searchController;
  late final VulcanEditorController _controller;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _controller = Get.find<VulcanEditorController>();

    // 검색어 변경 시 실시간 검색
    _searchController.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChanged);
    _debounceTimer?.cancel();

    // 검색 상태 초기화
    _controller.stopSearch();

    _searchController.dispose();
    super.dispose();
  }

  void _onSearchTextChanged() {
    final text = _searchController.text;
    if (text.isNotEmpty) {
      // 실시간 검색 시작
      _controller.startSearch(text);
    } else {
      // 검색어가 비어있으면 검색 종료
      _controller.stopSearch();
    }
  }

  void _onFindNext() {
    if (_searchController.text.isNotEmpty) {
      _controller.findNextWithCurrentSettings();
    }
  }

  void _onFindPrevious() {
    if (_searchController.text.isNotEmpty) {
      _controller.findPreviousWithCurrentSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 검색 입력 필드
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: controller.focusFindSearchNode,
                    decoration: InputDecoration(
                      // 검색어를 입력하세요
                      hintText: 'find_hint'.tr,
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    onSubmitted: (text) {
                      // if (text.isNotEmpty) {
                      //   // 엔터 입력 시 검색 시작하고 다음 항목으로 이동
                      //   _controller.startSearch(text);
                      //   Future.delayed(const Duration(milliseconds: 100), () {
                      //     _controller.findNextWithCurrentSettings();
                      //   });
                      // }
                      // 포커스 유지 (캐릿 보이기 유지)
                      _controller.focusFindSearchNode.requestFocus();
                    },
                  ),
                ),
                // 검색 결과 표시
                Obx(() {
                  if (_controller.rxIsSearching.value &&
                      _controller.rxTotalMatches.value > 0) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${_controller.rxCurrentMatch.value}/${_controller.rxTotalMatches.value}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 검색 옵션 체크박스
          Row(
            children: [
              Expanded(
                child: Obx(() => GestureDetector(
                      onTap: () {
                        _controller.rxCaseSensitive.toggle();
                        if (_searchController.text.isNotEmpty) {
                          _controller.startSearch(_searchController.text);
                        }
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: _controller.rxCaseSensitive.value
                                  ? Colors.blue
                                  : Colors.white,
                              border: Border.all(
                                color: _controller.rxCaseSensitive.value
                                    ? Colors.blue
                                    : Colors.grey.shade400,
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: _controller.rxCaseSensitive.value
                                ? const Icon(
                                    Icons.check,
                                    size: 12,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 8),
                          // 대소문자 구분
                          Text(
                            'case_sensitive'.tr,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    )),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: Obx(() => GestureDetector(
                      onTap: () {
                        _controller.rxWholeWord.toggle();
                        if (_searchController.text.isNotEmpty) {
                          _controller.startSearch(_searchController.text);
                        }
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: _controller.rxWholeWord.value
                                  ? Colors.blue
                                  : Colors.white,
                              border: Border.all(
                                color: _controller.rxWholeWord.value
                                    ? Colors.blue
                                    : Colors.grey.shade400,
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: _controller.rxWholeWord.value
                                ? const Icon(
                                    Icons.check,
                                    size: 12,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 8),
                          // 단어 단위로 찾기
                          Text(
                            'whole_word'.tr,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    )),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 이전/다음 버튼
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 32,
                  child: ElevatedButton(
                    onPressed: _onFindPrevious,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    // 이전
                    child: Text(
                      'previous'.tr,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 32,
                  child: ElevatedButton(
                    onPressed: _onFindNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    // 다음
                    child: Text(
                      'next'.tr,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // 일치 항목 없음 표시
          Obx(() {
            if (_controller.rxIsSearching.value &&
                _controller.rxTotalMatches.value == 0 &&
                _searchController.text.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.orange.shade600,
                    ),
                    const SizedBox(width: 8),
                    // 일치하는 항목이 없습니다
                    Text(
                      'no_matches'.tr,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}
