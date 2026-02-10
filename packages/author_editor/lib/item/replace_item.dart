import 'package:author_editor/vulcan_editor_controller.dart';
import 'package:author_editor/vulcan_editor_eventbus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReplaceItem extends StatefulWidget {
  final bool enableSync;

  const ReplaceItem({
    super.key,
    this.enableSync = true,
  });

  @override
  State<ReplaceItem> createState() => _ReplaceItemState();
}

class _ReplaceItemState extends State<ReplaceItem> with EditorEventbus {
  late final TextEditingController _searchController;
  late final TextEditingController _replaceController;
  late final VulcanEditorController _controller;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _replaceController = TextEditingController();
    _controller = Get.find<VulcanEditorController>();

    // 연동 모드가 아닐 때만 검색어 리스너 추가
    if (!widget.enableSync) {
      _searchController.addListener(_onSearchTextChanged);
    } else {
      // 연동 모드일 때는 컨트롤러의 검색어를 동기화
      _searchController.text = _controller.rxSearchText.value;
      _controller.rxSearchText.listen((value) {
        if (_searchController.text != value) {
          _searchController.text = value;
        }
      });
    }

    _replaceController.addListener(_onReplaceTextChanged);
  }

  @override
  void dispose() {
    if (!widget.enableSync) {
      _searchController.removeListener(_onSearchTextChanged);
    }
    _replaceController.removeListener(_onReplaceTextChanged);

    // 검색 상태 초기화
    _controller.stopSearch();

    _searchController.dispose();
    _replaceController.dispose();
    // FocusNode는 FocusNodeMixin에서 관리하므로 여기서 dispose하지 않음
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

  void _onReplaceTextChanged() {
    _controller.rxReplaceText.value = _replaceController.text;
  }

  void _onReplace() {
    _controller.replaceAndFindNext();
  }

  void _onReplaceAll() {
    _controller.replaceAllText();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
      child: Column(
        children: [
          // 연동 모드가 아닐 때만 검색 입력 필드 표시
          if (!widget.enableSync) ...[
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
                      focusNode: _controller.focusReplaceSearchNode,
                      decoration: InputDecoration(
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
                        if (text.isNotEmpty) {
                          // 엔터 입력 시 검색 시작하고 바꾸기 실행
                          _controller.startSearch(text);
                          Future.delayed(const Duration(milliseconds: 100), () {
                            _onReplace();
                          });
                        }
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
          ] else ...[
            // 연동 모드일 때는 현재 검색어 표시
            Obx(() {
              final searchText = _controller.rxSearchText.value;
              if (searchText.isNotEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    border: Border.all(color: Colors.blue.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        size: 16,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 8),

                      // 검색어:
                      Text(
                        'search_term'.trArgs([': ']),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          searchText,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // 검색 결과 표시
                      if (_controller.rxIsSearching.value &&
                          _controller.rxTotalMatches.value > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_controller.rxCurrentMatch.value}/${_controller.rxTotalMatches.value}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '찾기에서 검색어를 입력하세요',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
          ],

          // 바꿀 텍스트 입력 필드
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _replaceController,
              focusNode: _controller.focusReplaceTextNode,
              decoration: InputDecoration(
                // 바꿀 텍스트를 입력하세요
                hintText: 'replace_hint'.tr,
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
              //onSubmitted: (_) => _onReplace(),
            ),
          ),
          const SizedBox(height: 12),

          // 바꾸기 버튼들
          Column(
            children: [
              // 선택된 텍스트 바꾸기 버튼
              SizedBox(
                width: double.infinity,
                height: 36,
                child: ElevatedButton.icon(
                  onPressed: _onReplace,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade50,
                    foregroundColor: Colors.blue.shade700,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.blue.shade200),
                    ),
                  ),
                  icon: Icon(
                    Icons.find_replace,
                    size: 16,
                    color: Colors.blue.shade700,
                  ),
                  label: Text(
                    'replace_selected_text'.tr,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // 모두 바꾸기 버튼
              SizedBox(
                width: double.infinity,
                height: 36,
                child: Obx(() => ElevatedButton.icon(
                      onPressed: _onReplaceAll,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _controller.rxTotalMatches.value > 0
                            ? Colors.orange.shade50
                            : Colors.grey.shade50,
                        foregroundColor: _controller.rxTotalMatches.value > 0
                            ? Colors.orange.shade700
                            : Colors.grey.shade500,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: _controller.rxTotalMatches.value > 0
                                ? Colors.orange.shade200
                                : Colors.grey.shade300,
                          ),
                        ),
                      ),
                      icon: Icon(
                        Icons.swap_horiz,
                        size: 16,
                        color: _controller.rxTotalMatches.value > 0
                            ? Colors.orange.shade700
                            : Colors.grey.shade500,
                      ),
                      label: Text(
                        '${'replace_all'.tr} (${_controller.rxTotalMatches.value}${'count'.tr})',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: _controller.rxTotalMatches.value > 0
                              ? Colors.orange.shade700
                              : Colors.grey.shade500,
                        ),
                      ),
                    )),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 현재 선택 표시
          Obx(() {
            if (_controller.rxIsSearching.value &&
                _controller.rxTotalMatches.value > 0) {
              final isMatched = _controller.isCurrentSelectionMatch(
                _controller.rxSearchText.value,
                caseSensitive: _controller.rxCaseSensitive.value,
                wholeWord: _controller.rxWholeWord.value,
              );

              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isMatched ? Colors.blue.shade50 : Colors.grey.shade50,
                  border: Border.all(
                    color:
                        isMatched ? Colors.blue.shade200 : Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: isMatched
                          ? Colors.blue.shade600
                          : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isMatched
                          ? 'current_selection_matched'.tr
                          : 'current_selection_not_matched'.tr,
                      style: TextStyle(
                        fontSize: 12,
                        color: isMatched
                            ? Colors.blue.shade600
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // 일치 항목 없음 표시
          Obx(() {
            final searchText = widget.enableSync
                ? _controller.rxSearchText.value
                : _searchController.text;

            if (_controller.rxIsSearching.value &&
                _controller.rxTotalMatches.value == 0 &&
                searchText.isNotEmpty) {
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
