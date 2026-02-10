import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../../../../../app_ui.dart';

class HierarchicalListView extends StatefulWidget {
  final String ownerId;
  final String? selectedPageId; // 추가: 외부에서 선택된 페이지 ID
  final List<TreeListModel> pages;
  final bool hasToc;
  final bool hasCover;
  final Function(TreeListModel, TreeListModel, DragTargetPosition) onMove;
  final Function(String) onDelete;
  final Function(String) onCopyPage;
  final Function(TreeListModel) onEditPermission;
  final Function(TreeListModel) onSetStartPage;
  final Function(TreeListModel)? onSetCoverPage;
  final Function(TreeListModel)? onUnsetCoverPage;
  final Function(TreeListModel) onMemo;
  final Function(TreeListModel)? onCreateThumbnail;
  final Function(String, String) onUpdateTitle;
  final Function({String? parentId}) onAddChild;
  final Function(String type, bool isActive) onActivePage;
  final Function(TreeListModel) onClick;
  final bool onlyPageSelection;
  final String? startPageId;
  final bool showEditorUser;
  final String? currentUserId;

  const HierarchicalListView({
    super.key,
    required this.ownerId,
    this.selectedPageId, // 추가
    required this.pages,
    required this.hasToc,
    required this.hasCover,
    required this.onMove,
    required this.onDelete,
    required this.onCopyPage,
    required this.onEditPermission,
    required this.onSetStartPage,
    this.onSetCoverPage,
    this.onUnsetCoverPage,
    required this.onUpdateTitle,
    required this.onAddChild,
    required this.onActivePage,
    required this.onClick,
    this.onlyPageSelection = false,
    this.startPageId,
    this.showEditorUser = false,
    this.currentUserId,
    required this.onMemo,
    this.onCreateThumbnail,
  });

  @override
  HierarchicalListViewState createState() => HierarchicalListViewState();
}

class HierarchicalListViewState extends State<HierarchicalListView> {
  String? highlightedId;
  DragTargetPosition? highlightPosition;
  Set<String> expandedItems = {};
  String? _internalSelectedPageId; // 내부 선택 상태

  // 현재 선택된 페이지 ID를 반환하는 getter
  String? get selectedPageId =>
      widget.selectedPageId ?? _internalSelectedPageId;

  @override
  void initState() {
    super.initState();
    // 모든 페이지를 기본적으로 펼쳐진 상태로 설정
    _expandAllItems();

    // 초기 선택 페이지 설정
    if (widget.selectedPageId != null) {
      _internalSelectedPageId = widget.selectedPageId;
    } else if (widget.pages.isNotEmpty) {
      _internalSelectedPageId = widget.pages.first.id;
    }
  }

  void _expandAllItems() {
    // 모든 페이지 ID를 expandedItems에 추가
    for (final page in widget.pages) {
      if (hasChildren(page.id)) {
        expandedItems.add(page.id);
      }
    }
  }

  @override
  void didUpdateWidget(HierarchicalListView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 외부에서 selectedPageId가 변경된 경우 내부 상태 업데이트
    if (widget.selectedPageId != oldWidget.selectedPageId) {
      setState(() {
        _internalSelectedPageId = widget.selectedPageId;
      });
    }

    // 페이지 목록이 업데이트될 때마다 모든 항목을 펼쳐진 상태로 유지
    _expandAllItems();

    // 선택된 페이지가 없고 페이지 목록이 있는 경우 첫 번째 페이지 선택
    if (selectedPageId == null && widget.pages.isNotEmpty) {
      setState(() {
        _internalSelectedPageId = widget.pages.first.id;
      });
    }
  }

  List<TreeListModel> getChildrenOf(String? parentId) {
    return widget.pages.where((page) => page.parentId == parentId).toList();
  }

  bool hasChildren(String pageId) {
    return widget.pages.any((page) => page.parentId == pageId);
  }

  void toggleExpand(String pageId) {
    setState(() {
      if (expandedItems.contains(pageId)) {
        expandedItems.remove(pageId);
      } else {
        expandedItems.add(pageId);
      }
    });
  }

  bool isChildOf(TreeListModel potentialChild, TreeListModel potentialParent) {
    String? currentParentId = potentialChild.parentId;

    while (currentParentId != null && currentParentId.isNotEmpty) {
      if (currentParentId == potentialParent.id) {
        return true;
      }
      final nextParent = widget.pages.firstWhere(
        (p) => p.id == currentParentId,
        orElse: () => TreeListModel(
          id: '',
          parentId: '',
          title: '',
          idref: '',
          linear: false,
          href: '',
          thumbnail: '',
          createdAt: DateTime.now(),
          modifiedAt: DateTime.now(),
        ),
      );
      currentParentId = nextParent.parentId;
      if (currentParentId.isEmpty) break;
    }
    return false;
  }

  bool canAcceptDrop(TreeListModel? draggedItem, TreeListModel targetItem,
      DragTargetPosition position) {
    if (draggedItem == null) return false;
    if (draggedItem.id == targetItem.id) return false;
    // 비활성화된 페이지는 드래그 불가
    if (draggedItem.type.startsWith('temp_') ||
        targetItem.type.startsWith('temp_')) return false;

    // toc_sub 타입 페이지는 드래그 불가 (이동 불가)
    if (draggedItem.type == 'toc_sub') {
      return false;
    }

    // TOC 페이지와 toc_sub 페이지는 하위 페이지를 가질 수 없음 (inside position 차단)
    if ((targetItem.type == 'toc' || targetItem.type == 'toc_sub') &&
        position == DragTargetPosition.inside) {
      return false;
    }

    // toc_sub 페이지 주변으로는 아무것도 이동할 수 없음 (above, below 차단)
    if (targetItem.type == 'toc_sub') {
      return false;
    }

    if (isChildOf(targetItem, draggedItem)) {
      return false;
    }

    return true;
  }

  Widget buildPageItem(TreeListModel page, int level) {
    final children = getChildrenOf(page.id);
    final hasChildItems = children.isNotEmpty;
    final isExpanded = expandedItems.contains(page.id);

    final isTempPage = page.type.startsWith('temp_');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: level * 32.0),
          child: Stack(
            children: [
              Column(
                children: [
                  // above 드롭 타겟 (temp 페이지는 드롭 타겟 기능만 비활성화)
                  DragTarget<TreeListModel>(
                    onWillAcceptWithDetails: !isTempPage
                        ? (details) => canAcceptDrop(
                            details.data, page, DragTargetPosition.above)
                        : null,
                    onAcceptWithDetails: !isTempPage
                        ? (details) {
                            widget.onMove(
                                details.data, page, DragTargetPosition.above);
                            setState(() {
                              highlightedId = null;
                              highlightPosition = null;
                            });
                          }
                        : null,
                    onMove: !isTempPage
                        ? (details) {
                            setState(() {
                              highlightedId = page.id;
                              highlightPosition = DragTargetPosition.above;
                            });
                          }
                        : null,
                    onLeave: !isTempPage
                        ? (_) {
                            setState(() {
                              if (highlightedId == page.id &&
                                  highlightPosition ==
                                      DragTargetPosition.above) {
                                highlightedId = null;
                                highlightPosition = null;
                              }
                            });
                          }
                        : null,
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        height: 5,
                        decoration: BoxDecoration(
                          border: highlightedId == page.id &&
                                  highlightPosition == DragTargetPosition.above
                              ? Border.all(color: Colors.blue, width: 1)
                              : null,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: highlightedId == page.id &&
                                highlightPosition == DragTargetPosition.above
                            ? Center(
                                child: Container(
                                  height: 1,
                                  color: Colors.blue,
                                ),
                              )
                            : null,
                      );
                    },
                  ),
                  // inside 드롭 타겟 (temp 페이지는 드롭 타겟 기능만 비활성화)
                  DragTarget<TreeListModel>(
                    onWillAcceptWithDetails: !isTempPage
                        ? (details) => canAcceptDrop(
                            details.data, page, DragTargetPosition.inside)
                        : null,
                    onAcceptWithDetails: !isTempPage
                        ? (details) {
                            if (canAcceptDrop(details.data, page,
                                DragTargetPosition.inside)) {
                              widget.onMove(details.data, page,
                                  DragTargetPosition.inside);
                              setState(() {
                                expandedItems.add(page.id);
                              });
                            }
                            setState(() {
                              highlightedId = null;
                              highlightPosition = null;
                            });
                          }
                        : null,
                    onMove: !isTempPage
                        ? (details) {
                            final draggedItem = details.data;
                            if (canAcceptDrop(
                                draggedItem, page, DragTargetPosition.inside)) {
                              setState(() {
                                highlightedId = page.id;
                                highlightPosition = DragTargetPosition.inside;
                              });
                            }
                          }
                        : null,
                    onLeave: !isTempPage
                        ? (_) {
                            setState(() {
                              if (highlightedId == page.id &&
                                  highlightPosition ==
                                      DragTargetPosition.inside) {
                                highlightedId = null;
                                highlightPosition = null;
                              }
                            });
                          }
                        : null,
                    builder: (context, candidateData, rejectedData) {
                      return GestureDetector(
                        onTap: isTempPage
                            ? null
                            : () {
                                // 외부에서 selectedPageId가 제어되지 않는 경우에만 내부 상태 업데이트
                                if (widget.selectedPageId == null) {
                                  setState(() {
                                    _internalSelectedPageId = page.id;
                                  });
                                }
                                widget.onClick(page);
                              },
                        child: PointerInterceptor(
                          child: LongPressDraggable<TreeListModel>(
                            maxSimultaneousDrags: widget.onlyPageSelection ||
                                    isTempPage ||
                                    page.type == 'toc_sub'
                                ? 0
                                : 1,
                            data: page,
                            feedback: Material(
                              color: Colors.transparent,
                              elevation: 0,
                              child: Container(
                                width: 200,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.blue),
                                ),
                                child: Text(processTranslation(page.title)),
                              ),
                            ),
                            childWhenDragging: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.withAlpha(51),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: Colors.grey.withAlpha(77)),
                              ),
                              child: Text(processTranslation(page.title)),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isTempPage
                                    ? Colors.grey.withAlpha(26)
                                    : highlightedId == page.id &&
                                            highlightPosition ==
                                                DragTargetPosition.inside
                                        ? Colors.blue.withAlpha(26)
                                        : Colors.white,
                                border: selectedPageId == page.id && !isTempPage
                                    // ? Border.all(color: Colors.red, width: 2)
                                    ? Border.all(
                                        color: const Color(0xff000000),
                                        width: 2)
                                    : isTempPage
                                        ? Border.all(
                                            color: Colors.grey.withAlpha(128),
                                            width: 1)
                                        : highlightedId == page.id &&
                                                highlightPosition ==
                                                    DragTargetPosition.inside
                                            ? Border.all(
                                                color: Colors.blue, width: 2)
                                            : Border.all(
                                                color:
                                                    Colors.grey.withAlpha(77),
                                                width: 1,
                                              ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(13),
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // temp 페이지는 하위 페이지 확장/축소 버튼 비활성화
                                  if (hasChildItems && !isTempPage)
                                    IconButton(
                                      constraints: const BoxConstraints(),
                                      padding: const EdgeInsets.all(5),
                                      icon: Icon(
                                        isExpanded
                                            ? Icons.expand_more
                                            : Icons.chevron_right,
                                        size: 20,
                                      ),
                                      onPressed: () => toggleExpand(page.id),
                                      tooltip: isExpanded
                                          ? 'collapse'.tr
                                          : 'expand'.tr,
                                    )
                                  else
                                    const SizedBox(width: 15),
                                  Expanded(
                                    flex: 10,
                                    child: Tooltip(
                                      message: processTranslation(page.title),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  processTranslation(
                                                      page.title),
                                                  maxLines: 2,
                                                  // style: TextStyle(
                                                  //     color: isTempPage
                                                  //         ? Colors.grey
                                                  //         : widget.startPageId ==
                                                  //                 page.id
                                                  //             ? Colors.blue
                                                  //             : null,
                                                  //     overflow: TextOverflow
                                                  //         .ellipsis),
                                                ),
                                              ),
                                              // 커버 페이지에 "표지" 배지 표시
                                              if (page.type == 'cover' &&
                                                  !isTempPage)
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      left: 8),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Text(
                                                    'cover'.tr,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              // TOC 페이지에 "목차" 배지 표시
                                              if ((page.type == 'toc' ||
                                                      page.type == 'toc_sub') &&
                                                  !isTempPage)
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      left: 8),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Text(
                                                    'toc'.tr,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          // temp 페이지는 편집자 정보 비활성화
                                          // 편집자 닉네임 표시
                                          if (widget.showEditorUser &&
                                              !isTempPage)
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                  '${'editor'.tr} : ${page.editorUser ?? 'no_editor'.tr}',
                                                  style: const TextStyle(
                                                      fontSize: 10,
                                                      color: Color.fromARGB(
                                                          255, 20, 18, 18))),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  (widget.onlyPageSelection)
                                      ? const SizedBox(height: 35)
                                      : Row(
                                          children: [
                                            if (page.type.startsWith('temp_'))
                                              IconButton(
                                                constraints:
                                                    const BoxConstraints(),
                                                padding:
                                                    const EdgeInsets.all(5),
                                                onPressed: isTempPage
                                                    ? () {
                                                        final type = page.type
                                                            .replaceFirst(
                                                                'temp_', '');
                                                        widget.onActivePage(
                                                            type, true); // 활성화
                                                      }
                                                    : () {
                                                        final type = page.type;
                                                        widget.onActivePage(
                                                            type,
                                                            false); // 비활성화
                                                      },
                                                tooltip: isTempPage
                                                    ? 'show_page'.tr
                                                    : 'hide_page'.tr,
                                                icon: Icon(
                                                  isTempPage
                                                      ? Icons
                                                          .visibility_off_outlined
                                                      : Icons
                                                          .remove_red_eye_outlined,
                                                  size: 20,
                                                ),
                                              ),
                                            // 일반 페이지에만 메뉴 버튼 표시
                                            if (!page.type.startsWith('temp_'))
                                              VulcanXMoreMenu(
                                                items: [
                                                  // TOC 페이지와 toc_sub 페이지가 아닌 경우에만 하위 페이지 추가 메뉴 표시
                                                  if (page.type != 'toc' &&
                                                      page.type != 'toc_sub')
                                                    PopupMenuItem(
                                                      value: 'page_add_child',
                                                      child: Text(
                                                          'page_add_child'.tr),
                                                      onTap: () {
                                                        widget.onAddChild(
                                                            parentId: page.id);
                                                        setState(() {
                                                          expandedItems
                                                              .add(page.id);
                                                        });
                                                      },
                                                    ),
                                                  PopupMenuItem(
                                                    value: 'page_rename_title',
                                                    child: Text(
                                                        'page_rename_title'.tr),
                                                    onTap: () =>
                                                        _showEditTitleDialog(
                                                            context, page),
                                                  ),
                                                  // TOC 페이지와 toc_sub 페이지가 아닌 경우에만 페이지 복사 메뉴 표시
                                                  if (page.type != 'toc' &&
                                                      page.type != 'toc_sub')
                                                    PopupMenuItem(
                                                      value: 'page_copy',
                                                      child:
                                                          Text('page_copy'.tr),
                                                      onTap: () => widget
                                                          .onCopyPage(page.id),
                                                    ),
                                                  PopupMenuItem(
                                                    value: 'page_delete',
                                                    child:
                                                        Text('page_delete'.tr),
                                                    onTap: () =>
                                                        _showDeleteConfirmDialog(
                                                            context, page),
                                                  ),
                                                  // TOC 페이지와 toc_sub 페이지가 아닌 경우에만 시작 페이지 설정 메뉴 표시
                                                  if (page.type != 'toc' &&
                                                      page.type != 'toc_sub')
                                                    PopupMenuItem(
                                                      value:
                                                          'page_set_start_page',
                                                      child: Text(
                                                          'page_set_start_page'
                                                              .tr),
                                                      onTap: () => widget
                                                          .onSetStartPage(page),
                                                    ),
                                                  // 커버 설정/해제 메뉴 (TOC 페이지와 toc_sub 페이지가 아니고 해당 함수가 제공된 경우에만 표시)
                                                  if (widget.onSetCoverPage !=
                                                          null &&
                                                      widget.onUnsetCoverPage !=
                                                          null &&
                                                      page.type != 'toc' &&
                                                      page.type != 'toc_sub')
                                                    PopupMenuItem(
                                                      value: page.type ==
                                                              'cover'
                                                          ? 'page_unset_cover'
                                                          : 'page_set_cover',
                                                      child: Text(
                                                          // 표지 해제, 표지 설정
                                                          page.type == 'cover'
                                                              ? 'page_unset_cover'
                                                                  .tr
                                                              : 'page_set_cover'
                                                                  .tr),
                                                      onTap: () {
                                                        if (page.type ==
                                                            'cover') {
                                                          widget.onUnsetCoverPage!(
                                                              page);
                                                        } else {
                                                          widget.onSetCoverPage!(
                                                              page);
                                                        }
                                                      },
                                                    ),
                                                  if (page.id == selectedPageId)
                                                    PopupMenuItem(
                                                      value: 'memo_view',
                                                      child:
                                                          Text('memo_view'.tr),
                                                      onTap: () {
                                                        widget.onMemo(page);
                                                      },
                                                    ),
                                                  if (page.id == selectedPageId &&
                                                      widget.onCreateThumbnail !=
                                                          null &&
                                                      widget.currentUserId ==
                                                          'arasoft')
                                                    PopupMenuItem(
                                                      value: 'create_thumbnail',
                                                      child: Text(
                                                          'create_thumbnail'.tr),
                                                      onTap: () {
                                                        widget.onCreateThumbnail!(
                                                            page);
                                                      },
                                                    ),
                                                ],
                                              ),
                                          ],
                                        ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  // below 드롭 타겟 (temp 페이지는 드롭 타겟 기능만 비활성화)
                  DragTarget<TreeListModel>(
                    onWillAcceptWithDetails: !isTempPage
                        ? (details) => canAcceptDrop(
                            details.data, page, DragTargetPosition.below)
                        : null,
                    onAcceptWithDetails: !isTempPage
                        ? (details) {
                            widget.onMove(
                                details.data, page, DragTargetPosition.below);
                            setState(() {
                              highlightedId = null;
                              highlightPosition = null;
                            });
                          }
                        : null,
                    onMove: !isTempPage
                        ? (details) {
                            setState(() {
                              highlightedId = page.id;
                              highlightPosition = DragTargetPosition.below;
                            });
                          }
                        : null,
                    onLeave: !isTempPage
                        ? (_) {
                            setState(() {
                              if (highlightedId == page.id &&
                                  highlightPosition ==
                                      DragTargetPosition.below) {
                                highlightedId = null;
                                highlightPosition = null;
                              }
                            });
                          }
                        : null,
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        height: 5,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          border: highlightedId == page.id &&
                                  highlightPosition == DragTargetPosition.below
                              ? Border.all(color: Colors.blue, width: 1)
                              : null,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: highlightedId == page.id &&
                                highlightPosition == DragTargetPosition.below
                            ? Center(
                                child: Container(height: 1, color: Colors.blue),
                              )
                            : null,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        // canHaveChildren은 이제 항상 true이므로 체크 불필요
        if (isExpanded)
          ...children.map((child) => buildPageItem(child, level + 1)),
      ],
    );
  }

  Future<void> _showEditTitleDialog(
      BuildContext context, TreeListModel page) async {
    final String initialTitle = processTranslation(page.title);

    final TextEditingController titleController =
        TextEditingController(text: initialTitle);

    return showDialog(
      context: context,
      builder: (context) => PointerInterceptor(
        child: AlertDialog(
          title: Text('page_rename_title_text'.tr),
          content: TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'page_rename_title_text_hint'.tr,
                hintText: 'page_rename_title_text_message'.tr,
              ),
              autofocus: true,
              onSubmitted: (value) =>
                  widget.onUpdateTitle(page.id, titleController.text)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr),
            ),
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  widget.onUpdateTitle(page.id, titleController.text);
                  Navigator.pop(context);
                }
              },
              child: Text('save'.tr),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmDialog(
      BuildContext context, TreeListModel page) async {
    // 비활성화된 페이지는 삭제 확인 다이얼로그 표시하지 않음
    if (page.type.startsWith('temp_')) return;

    return showDialog(
      context: context,
      builder: (context) => PointerInterceptor(
        child: AlertDialog(
          title: Text('page_delete'.tr),
          content: Text(
            'page_delete_confirm_message'
                .trArgs([processTranslation(page.title)]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr),
            ),
            TextButton(
              onPressed: () {
                widget.onDelete(page.id);
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('delete'.tr),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 모든 루트 레벨 페이지를 rootItems로 수집
    List<TreeListModel> rootItems =
        widget.pages.where((page) => page.parentId.isEmpty).toList();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // temp 페이지가 최상단에 위치하도록 finalRootItems 사용
            ...rootItems.map((page) => buildPageItem(page, 0)),
          ],
        ),
      ),
    );
  }
}
