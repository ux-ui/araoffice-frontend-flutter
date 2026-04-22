import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../../../../../app_ui.dart';

class TreeListWidget extends StatefulWidget {
  final String ownerId;
  final String? startPageId;
  final String? selectedPageId; // 추가: 외부에서 선택된 페이지 ID 설정
  final bool onlyPageSelection; // 페이지 선택만 가능
  final bool isEditingPermission; // 페이지 추가 가능 여부
  final bool hasCover; // Cover 페이지 보호 여부
  final bool hasToc; // TOC 페이지 보호 여부
  final bool showEditorUser; // 편집자 표시 여부
  final List<TreeListModel>? initialPages;
  final Function(TreeListModel page) onPageClick;
  final Function(String? parentId) onAddPage;
  final Function(TreeListModel page) onDeletePage;
  final Function(TreeListModel page) onCopyPage;
  final Function(TreeListModel page, String newTitle) onUpdatePageTitle;
  final Function(String position) onAddContentsIcon;
  final Function(TreeListModel movedPage, TreeListModel targetPage,
      DragTargetPosition position) onPageMove;
  final Function(String type, bool isActive) onActivePage;
  final ValueChanged<String>? onPagesToHtml;
  final ValueChanged<String>? onPagesToJson;
  final Function(TreeListModel page) onEditPermission;
  final Function(TreeListModel page) onSetStartPage;
  final Function(TreeListModel page)? onSetCoverPage;
  final Function(TreeListModel page)? onUnsetCoverPage;
  final Function()? onOpenDocument;
  final Function(TreeListModel page) onMemo;
  final Function(TreeListModel page)? onCreateThumbnail;
  final void Function(TreeListModel page)? onThumbnailThenSetCover;
  final String? currentUserId;

  final Function() onViewColumn;
  final bool viewColumn;

  /// false이면 상단「새 페이지」등 추가 UI 비활성 — 생성 완료까지 중복 방지용
  final bool canAddPage;

  const TreeListWidget({
    super.key,
    required this.ownerId,
    this.selectedPageId, // 추가
    this.onlyPageSelection = false,
    required this.isEditingPermission,
    required this.hasCover,
    required this.hasToc,
    this.showEditorUser = false,
    this.initialPages,
    required this.onPageClick,
    required this.onAddPage,
    required this.onDeletePage,
    required this.onCopyPage,
    required this.onUpdatePageTitle,
    required this.onAddContentsIcon,
    required this.onPageMove,
    required this.onMemo,
    this.onPagesToHtml,
    this.onPagesToJson,
    required this.onActivePage,
    required this.onEditPermission,
    required this.onSetStartPage,
    this.onSetCoverPage,
    this.onUnsetCoverPage,
    this.onOpenDocument,
    this.onCreateThumbnail,
    this.onThumbnailThenSetCover,
    this.currentUserId,
    required this.onViewColumn,
    this.startPageId,
    this.viewColumn = true,
    this.canAddPage = true,
  });

  @override
  TreeListWidgetState createState() => TreeListWidgetState();
}

class TreeListWidgetState extends State<TreeListWidget> {
  late List<TreeListModel> pages;

  /// 버튼으로 진입한 순서 변경 모드 (true면 길게 누르지 않고 드래그만으로 순서 변경)
  bool _isReorderMode = false;
  bool _isMultiSelectMode = false;
  final Set<String> _selectedPageIds = <String>{};
  int _pageVersion = 0;

  @override
  void initState() {
    super.initState();

    // initialPages가 제공되면 사용하고, 아니면 기본 페이지 리스트 사용
    pages = widget.initialPages ??
        [
          TreeListModel(
            id: 'cover',
            parentId: '',
            title: 'cover'.tr,
            idref: 'cover',
            linear: true,
            href: 'cover.xhtml',
            thumbnail: 'cover.png',
            createdAt: DateTime.now(),
            modifiedAt: DateTime.now(),
            type: 'cover',
          ),
          TreeListModel(
            id: 'toc',
            parentId: '',
            title: 'toc'.tr,
            idref: 'toc',
            linear: true,
            href: 'toc.xhtml',
            thumbnail: 'toc.png',
            createdAt: DateTime.now(),
            modifiedAt: DateTime.now(),
            type: 'toc',
          ),
          TreeListModel(
            id: '1',
            parentId: '',
            title: 'Chapter 1',
            idref: 'ch1',
            linear: true,
            href: 'ch1.xhtml',
            thumbnail: 'ch1.png',
            createdAt: DateTime.now(),
            modifiedAt: DateTime.now(),
          ),
          TreeListModel(
            id: '2',
            parentId: '1',
            title: 'Chapter 1',
            idref: 'ch1',
            linear: true,
            href: 'ch1.xhtml',
            thumbnail: 'ch1.png',
            createdAt: DateTime.now(),
            modifiedAt: DateTime.now(),
          ),
        ];
  }

  @override
  void didUpdateWidget(covariant TreeListWidget oldWidget) {
    pages = widget.initialPages!;
    _pageVersion++;
    _selectedPageIds.removeWhere(
      (id) => !pages.any((page) => page.id == id),
    );

    if (widget.onPagesToHtml != null) {
      final htmlString = convertPagesToHtml(pages);
      widget.onPagesToHtml!.call(htmlString);
    }

    if (widget.onPagesToJson != null) {
      final jsonString = convertPagesToJsonData(pages);
      widget.onPagesToJson!.call(jsonString);
    }
    super.didUpdateWidget(oldWidget);
  }

  void handlePageClick(TreeListModel page) {
    widget.onPageClick.call(page);
  }

  void addContentsIcon(String position) {
    widget.onAddContentsIcon.call(position);
  }

  void addPage({String? parentId}) {
    widget.onAddPage.call(parentId);
  }

  void deletePage(String pageId) {
    final page = pages.firstWhere((p) => p.id == pageId);
    widget.onDeletePage.call(page);
  }

  void copyPage(String pageId) {
    final page = pages.firstWhere((p) => p.id == pageId);
    widget.onCopyPage.call(page);
  }

  bool _isSelectablePage(TreeListModel page) => !page.type.startsWith('temp_');

  bool _isCopyablePage(TreeListModel page) =>
      _isSelectablePage(page) && page.type != 'toc' && page.type != 'toc_sub';

  Future<void> _waitForPageVersionChange(
    int previousVersion, {
    Duration timeout = const Duration(seconds: 4),
  }) async {
    final start = DateTime.now();
    while (mounted && _pageVersion == previousVersion) {
      if (DateTime.now().difference(start) >= timeout) {
        break;
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<void> _copySelectedPages() async {
    final selectedPages = pages.where((p) => _selectedPageIds.contains(p.id));
    final copyTargets = selectedPages.where(_isCopyablePage).toList();
    if (copyTargets.isEmpty) return;

    for (final page in copyTargets) {
      final beforeVersion = _pageVersion;
      widget.onCopyPage.call(page);
      await _waitForPageVersionChange(beforeVersion);
    }
  }

  Future<void> _deleteSelectedPages() async {
    final selectedPages = pages.where((p) => _selectedPageIds.contains(p.id));
    final deleteTargets = selectedPages.where(_isSelectablePage).toList();
    if (deleteTargets.isEmpty) return;

    for (final page in deleteTargets) {
      final beforeVersion = _pageVersion;
      widget.onDeletePage.call(page);
      await _waitForPageVersionChange(beforeVersion);
    }
  }

  Future<void> _showMultiDeleteConfirmDialog() async {
    final selectedCount = _selectedPageIds.length;
    if (selectedCount == 0) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => PointerInterceptor(
        child: AlertDialog(
          title: Text('page_delete'.tr),
          content:
              Text('${'selected_items'.trArgs([selectedCount.toString()])}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('cancel'.tr),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _deleteSelectedPages();
                if (!mounted) return;
                setState(() {
                  _selectedPageIds.clear();
                  _isMultiSelectMode = false;
                });
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('delete'.tr),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = !_isMultiSelectMode;
      if (_isMultiSelectMode) {
        _isReorderMode = false;
      } else {
        _selectedPageIds.clear();
      }
    });
  }

  void updatePageTitle(String pageId, String newTitle) {
    final page = pages.firstWhere((p) => p.id == pageId);
    widget.onUpdatePageTitle.call(page, newTitle);
  }

  void handlePageMove(
    TreeListModel movedPage,
    TreeListModel targetPage,
    DragTargetPosition position,
  ) {
    widget.onPageMove.call(movedPage, targetPage, position);
  }

  bool isChildOf(TreeListModel potentialChild, TreeListModel potentialParent) {
    String? currentParentId = potentialChild.parentId;

    while (currentParentId != null && currentParentId.isNotEmpty) {
      if (currentParentId == potentialParent.id) {
        return true;
      }
      final nextParent = pages.firstWhere(
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

  String convertPagesToHtml(List<TreeListModel> pages) {
    // Helper function to get children of a page
    List<TreeListModel> getChildrenOf(String? parentId) {
      return pages.where((page) => page.parentId == parentId).toList();
    }

    // startPageId와 일치하는 페이지부터 번호 부여를 위한 플래그
    bool foundStartPage = widget.startPageId == null;

    // 재귀적으로 HTML 목록 생성
    String buildHtmlList(List<TreeListModel> items, Counter pageNumber) {
      if (items.isEmpty) return '';

      StringBuffer html = StringBuffer('<ol>');

      for (var item in items) {
        html.write('<li>');

        // 페이지 제목과 링크
        html.write(
            '<a href="${item.href}">${processTranslation(item.title)}</a>');

        // startPageId와 일치하는 페이지를 찾았으면 번호 부여 시작
        if (!foundStartPage && item.id == widget.startPageId) {
          foundStartPage = true;
          pageNumber.value = 1;
        }

        // 모든 페이지에 페이지 번호와 점선 추가 (타입 구분 제거)
        if (foundStartPage) {
          html.write('''
            <div class="page-dots" data-ve-alias="img">
              <div class="dots" data-ve-alias="img"></div>
              <span class="page-number" data-ve-alias="img">${pageNumber.value}</span>
            </div>
          ''');
          pageNumber.value++;
        } else {
          html.write('''
            <div class="page-dots" data-ve-alias="img">
              <div class="dots" data-ve-alias="img"></div>
              <span class="page-number" data-ve-alias="img">-</span>
            </div>
          ''');
        }

        // 자식 페이지가 있으면 재귀적으로 처리
        final children = getChildrenOf(item.id);
        if (children.isNotEmpty) {
          html.write(buildHtmlList(children, pageNumber));
        }

        html.write('</li>');
      }

      html.write('</ol>');
      return html.toString();
    }

    // 루트 레벨의 모든 페이지 찾기 (타입 구분 없음)
    final rootItems = pages.where((page) => page.parentId.isEmpty).toList();

    // 최종 HTML 생성
    StringBuffer html = StringBuffer();
    html.write('<nav epub:type="toc" id="toc" data-ve-alias="img">');
    html.write('<ol class="list-number" data-ve-alias="img">');

    // Counter 객체를 생성하여 페이지 번호 추적
    Counter counter = Counter(1);

    // 모든 페이지들을 계층 구조로 추가
    html.write(buildHtmlList(rootItems, counter).substring(4)); // 초기 <ol> 태그 제거

    html.write('</nav>');

    return html.toString();
  }

  /// TreeListModel 리스트를 TocItemData JSON 형식으로 변환
  String convertPagesToJsonData(List<TreeListModel> pages) {
    // 페이지 번호 추적용 카운터
    Counter pageNumber = Counter(1);

    // startPageId와 일치하는 페이지부터 번호 부여를 위한 플래그
    bool foundStartPage = widget.startPageId == null;

    // 헬퍼 함수: 특정 부모 ID를 가진 모든 자식 페이지 찾기
    List<TreeListModel> getChildrenOf(String? parentId) {
      return pages.where((page) => page.parentId == parentId).toList();
    }

    // 모든 페이지의 calculatedPage 초기화
    for (var page in pages) {
      page.calculatedPage = null;
    }

    // 재귀적으로 TocItemData 구조 생성 및 페이지 번호 설정
    Map<String, dynamic> buildTocItem(TreeListModel item, int level) {
      // startPageId와 일치하는 페이지를 찾았으면 번호 부여 시작
      if (!foundStartPage && item.id == widget.startPageId) {
        foundStartPage = true;
        pageNumber.value = 1;
      }

      // 계산된 페이지 번호 (모든 페이지에 적용)
      int? calculatedPageNumber;
      if (foundStartPage) {
        calculatedPageNumber = pageNumber.value;
        item.calculatedPage =
            calculatedPageNumber; // TreeListModel에 계산된 페이지 번호 저장
      }

      // 기본 TocItemData 생성
      final Map<String, dynamic> tocItem = {
        'title': processTranslation(item.title),
        'page': calculatedPageNumber,
        'level': level,
        'listType': 'ol', // 모든 항목에 대해 순서 있는 목록으로 설정
        'listStyleType': 'decimal', // 모든 항목에 대해 십진수 스타일로 설정
        'url': item.href,
      };

      // 모든 페이지에 대해 페이지 번호 증가
      if (foundStartPage) {
        pageNumber.value++;
      }

      // 자식 페이지 처리
      final children = getChildrenOf(item.id);
      if (children.isNotEmpty) {
        tocItem['children'] =
            children.map((child) => buildTocItem(child, level + 1)).toList();
      }

      return tocItem;
    }

    // 루트 레벨의 모든 페이지 찾기 (타입 구분 없음)
    final rootItems = pages.where((page) => page.parentId.isEmpty).toList();

    // 루트 아이템들을 TocItemData 배열로 변환
    final List<Map<String, dynamic>> result =
        rootItems.map((item) => buildTocItem(item, 0)).toList();

    // JSON 문자열로 변환
    return json.encode(result);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          toolbarHeight: _isMultiSelectMode ? 100 : null,
          actions: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 105,
                        child: VulcanXOutlinedButton.icon(
                          disabled:
                              widget.onlyPageSelection || !widget.canAddPage,
                          padding: const EdgeInsets.all(5),
                          icon: const Icon(
                            Icons.add,
                            size: 20,
                          ),
                          onPressed: () =>
                              (widget.onlyPageSelection || !widget.canAddPage)
                                  ? null
                                  : addPage(),
                          child: AutoSizeText(
                            'add_new_page'.tr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: SizedBox(
                        width: 43,
                        child: Tooltip(
                          message: _isMultiSelectMode
                              ? 'close'.tr
                              : 'select_item_list'.tr,
                          child: VulcanXOutlinedButton.icon(
                            padding: const EdgeInsets.all(7),
                            icon: Icon(
                              _isMultiSelectMode ? Icons.close : Icons.list_alt,
                              size: 20,
                            ),
                            onPressed: widget.onlyPageSelection
                                ? null
                                : () => _toggleMultiSelectMode(),
                            child: const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ),
                    if (widget.onOpenDocument != null) ...[
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: SizedBox(
                          width: 43,
                          child: Tooltip(
                            message: 'office_import'.tr,
                            child: VulcanXOutlinedButton.icon(
                              padding: const EdgeInsets.all(7),
                              icon: const Icon(Icons.file_open_outlined,
                                  size: 20),
                              onPressed: () => widget.onOpenDocument?.call(),
                              child: const SizedBox.shrink(),
                            ),
                          ),
                        ),
                      ),
                    ],
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: SizedBox(
                        width: 43,
                        child: Tooltip(
                          message: widget.viewColumn
                              ? 'view_column_close_tooltip'.tr
                              : 'view_column_open_tooltip'.tr,
                          child: VulcanXOutlinedButton.icon(
                            padding: const EdgeInsets.all(7),
                            icon: const Icon(Icons.view_column_outlined,
                                size: 20),
                            onPressed: () => widget.onViewColumn(),
                            child: const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_isMultiSelectMode)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          '${'selected_item'.tr}: ${_selectedPageIds.length}${'count'.tr}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: SizedBox(
                          width: 43,
                          child: PointerInterceptor(
                            child: Tooltip(
                              message: 'page_copy'.tr,
                              child: VulcanXOutlinedButton.icon(
                                padding: const EdgeInsets.all(7),
                                icon: const Icon(Icons.copy_outlined, size: 20),
                                onPressed: _selectedPageIds.isEmpty
                                    ? null
                                    : () async {
                                        await _copySelectedPages();
                                        if (!mounted) return;
                                        setState(() {
                                          _selectedPageIds.clear();
                                          _isMultiSelectMode = false;
                                        });
                                      },
                                child: const SizedBox.shrink(),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: SizedBox(
                          width: 43,
                          child: PointerInterceptor(
                            child: Tooltip(
                              message: 'page_delete'.tr,
                              child: VulcanXOutlinedButton.icon(
                                padding: const EdgeInsets.all(7),
                                icon:
                                    const Icon(Icons.delete_outline, size: 20),
                                onPressed: _selectedPageIds.isEmpty
                                    ? null
                                    : () => _showMultiDeleteConfirmDialog(),
                                child: const SizedBox.shrink(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
        Expanded(
          child: HierarchicalListView(
            ownerId: widget.ownerId,
            selectedPageId: widget.selectedPageId, // 추가: 외부 selectedPageId 전달
            onlyPageSelection: widget.onlyPageSelection,
            isReorderMode: _isReorderMode && !_isMultiSelectMode,
            onToggleReorderMode: () =>
                setState(() => _isReorderMode = !_isReorderMode),
            canAddPage: widget.canAddPage,
            hasToc: widget.hasToc,
            hasCover: widget.hasCover,
            pages: pages,
            onMove: handlePageMove,
            onDelete: deletePage,
            onUpdateTitle: updatePageTitle,
            onAddChild: addPage,
            onCopyPage: copyPage,
            onActivePage: widget.onActivePage,
            onClick: handlePageClick,
            onEditPermission: widget.onEditPermission,
            onSetStartPage: widget.onSetStartPage,
            onSetCoverPage: widget.onSetCoverPage,
            onUnsetCoverPage: widget.onUnsetCoverPage,
            showEditorUser: widget.showEditorUser,
            startPageId: widget.startPageId,
            currentUserId: widget.currentUserId,
            onMemo: widget.onMemo,
            onCreateThumbnail: widget.onCreateThumbnail,
            onThumbnailThenSetCover: widget.onThumbnailThenSetCover,
            isMultiSelectMode: _isMultiSelectMode,
            selectedPageIds: _selectedPageIds,
            onTogglePageSelection: (pageId) {
              setState(() {
                if (_selectedPageIds.contains(pageId)) {
                  _selectedPageIds.remove(pageId);
                } else {
                  _selectedPageIds.add(pageId);
                }
              });
            },
          ),
        ),
      ],
    );
  }
}
