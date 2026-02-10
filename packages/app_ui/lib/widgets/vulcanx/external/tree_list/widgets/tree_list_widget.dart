import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  final String? currentUserId;

  final Function() onViewColumn;
  final bool viewColumn;

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
    this.currentUserId,
    required this.onViewColumn,
    this.startPageId,
    this.viewColumn = true,
  });

  @override
  TreeListWidgetState createState() => TreeListWidgetState();
}

class TreeListWidgetState extends State<TreeListWidget> {
  late List<TreeListModel> pages;

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
          actions: [
            // TODO 목차 아이콘 추가
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: SizedBox(
            //     width: widget.isEditingPermission ? 138 : 131,
            //     child: VulcanXOutlinedButton.icon(
            //       padding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
            //       iconAlignment: IconAlignment.end,
            //       onPressed: () {},
            //       disabled: !widget.isEditingPermission,
            //       icon: (!widget.isEditingPermission)
            //           ? const SizedBox(width: 16)
            //           : VulcanXMoreMenu(
            //               iconSize: 15,
            //               items: [
            //                 PopupMenuItem(
            //                   child: Text('add_contents_icon_top_left'.tr),
            //                   onTap: () => addContentsIcon('top_left'),
            //                 ),
            //                 PopupMenuItem(
            //                   child: Text('add_contents_icon_top_right'.tr),
            //                   onTap: () => addContentsIcon('top_right'),
            //                 ),
            //                 PopupMenuItem(
            //                   child: Text('add_contents_icon_bottom_left'.tr),
            //                   onTap: () => addContentsIcon('bottom_left'),
            //                 ),
            //                 PopupMenuItem(
            //                   child: Text('add_contents_icon_bottom_right'.tr),
            //                   onTap: () => addContentsIcon('bottom_right'),
            //                 ),
            //               ],
            //             ),
            //       child: AutoSizeText(
            //         'add_contents_icon'.tr,
            //         maxLines: 1,
            //         overflow: TextOverflow.ellipsis,
            //         maxFontSize: 12,
            //         minFontSize: 10,
            //       ),
            //     ),
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 105,
                child: VulcanXOutlinedButton.icon(
                  disabled: widget.onlyPageSelection,
                  padding: const EdgeInsets.all(5),
                  icon: const Icon(
                    Icons.add,
                    size: 20,
                  ),
                  onPressed: () => widget.onlyPageSelection ? null : addPage(),
                  child: AutoSizeText(
                    'add_new_page'.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                      icon: const Icon(Icons.file_open_outlined, size: 20),
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
                child: VulcanXOutlinedButton.icon(
                  padding: const EdgeInsets.all(7),
                  icon: const Icon(Icons.view_column_outlined, size: 20),
                  onPressed: () => widget.onViewColumn(),
                  child: const SizedBox.shrink(),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: HierarchicalListView(
            ownerId: widget.ownerId,
            selectedPageId: widget.selectedPageId, // 추가: 외부 selectedPageId 전달
            onlyPageSelection: widget.onlyPageSelection,
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
          ),
        ),
      ],
    );
  }
}
