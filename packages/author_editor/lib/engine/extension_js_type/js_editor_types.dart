import 'dart:js_interop';

import 'js_cell_format_option.dart';
import 'js_document_state.dart';
import 'js_list_style.dart';
import 'js_paragraph_style.dart';
import 'js_position.dart';
import 'js_text_style.dart';

@JS()
extension type EventCallback(JSObject _) implements JSObject {
  external factory EventCallback.create({
    JSFunction onLoad,
    JSFunction onUnload,
    JSFunction onInsertElement,
    JSFunction onSingleSelected,
    JSFunction onNoneSelected,
    JSFunction onCaretSelected,
    JSFunction onRangeSelected,
    JSFunction onMultiSelected,
    JSFunction onCellSelected,
    JSFunction onNodeRectChanged,
    JSFunction onStyleChanged,
    JSFunction onAttributeChanged,
    JSFunction onNodeInserted,
    JSFunction onNodeRemoved,
    JSFunction onUndoStackChanged,
    JSFunction onPointerMove,
    JSFunction onWidgetSelectionChanged,
    JSFunction onFrameClick,
    JSFunction onDocumentChanged,
  });
}

@JS()
extension type Editor(JSObject _) implements JSObject {
  // 기존 기본 함수들
  external void setLangUrl(String langUrl);
  external void load(String path);
  external void unload();
  external void updateHtmlAndReload(String htmlContent);
  external void updateEditorPosition();
  external void showGrid(bool visible);
  external void showRuler(bool visible);
  external void setContentSize(int width, int height);
  external JSDocumentState getDocumentState();
  external void scale(double factor);
  external void setZindex(String option); // 객체간 순서

  // 캡쳐 관련 함수들
  // html2canvas를 호출하는 메소드도 external로 선언
  external JSPromise<JSString> capture(JSObject node, int width, int height);
  external JSPromise<JSString> captureNode(JSObject node); // 특정 노드 캡처
  external JSPromise<JSString> captureSelectedNode(); // 현재 선택된 노드 캡처
  // capturePage도 external로 선언
  external JSPromise<JSString> capturePage();

  // 객체 삽입 관련 함수들
  external void insertTextbox(String type, String hint,
      [int width, int height]);
  external String isTextbox(JSObject node);
  external void convertTextbox(JSObject node, String type);

  external void insertTable(int row, int column);

  external void insertImage(String src);
  external void changeImageSource(String src); // 이미지 바꾸기
  external void applyNaturalImageSize(); //선택된 이미지 엘리먼트에 적용

  external void insertVideo(String src);
  external void insertAudio(String src);
  external void insertFigure(String parameter);
  external void insertText(String text);

  // 수식관련 함수들
  external void insertMath(
      String mathOuterHTML, String? svgOuterHTML, String? imagedata);
  external void updateMath(JSObject node, String mathOuterHTML,
      String? svgOuterHTML, String? imagedata);

  // 스타일 관련 함수들
  external JSTextStyle getSelectedTextStyle();
  external JSParagraphStyle getSelectedParagraphStyle();
  external String getSelectedParagraphTag();
  external void replaceParagraphTag(String tagName);

  // HTML 문자열 조작
  external String getHtmlString();

  // 포커스 관리
  external void focus();

  // 그리드 관리
  external void setGridGap(int gap);
  external void enableSnapToGrid(bool enable);

  // 스타일 관리 메서드들
  external void removeAllStyle();
  external void applyFontFamily(String fontFamily);
  external void removeFontFamily();
  external void applyFontSize(String fontSize);
  external void removeFontSize();
  external void applyTextColor(String color);
  external void removeTextColor();
  external void applyBackColor(String color);
  external void removeBackColor();
  external void applyBold();
  external void removeBold();
  external void applyItalic();
  external void removeItalic();
  external void applyUnderline();
  external void removeUnderline();
  external void applyOverline();
  external void removeOverline();
  external void applyStrike();
  external void removeStrike();
  external void applySubScript();
  external void removeSubScript();
  external void applySuperScript();
  external void removeSuperScript();
  external void applyLetterSpacing(String space);
  external void removeLetterSpacing();

  external void applyTextIndent(int range);
  external void removeTextIndent();
  external void applyFontWidth(String fontWidth);
  external void removeFontWidth();

  // 문단 스타일 관리
  external void applyTextAlign(String align);
  external void removeTextAlign();
  external void applyLineHeight(String height);
  external void removeLineHeight();
  external void applyPaddingLeft(int range);
  external void removePaddingLeft();
  external void applyLinePadding(String type, int range);
  external void removeLinePadding(String type);

  // 정렬 관련
  external void alignSelectedNodes(String option); //정렬
  external void matchSizeOfSelectedNodes(String option); //크기 맞추기
  external void distributeSelectedNodes(bool horizontal); //위치 배분

  // 토글 메서드들
  external void toggleBold();
  external void toggleItalic();
  external void toggleUnderline();
  external void toggleOverline();
  external void toggleStrike();
  external void toggleSubScript();
  external void toggleSuperScript();

  // 노드 속성 조작
  external void setStyle(JSObject node, String styleName, String value,
      [bool important]);
  external String getStyle(JSObject node, String styleName, [bool computed]);
  external void removeStyle(JSObject node, String styleName);
  external void setAttribute(JSObject node, String attributeName, String value);
  external String getAttribute(JSObject node, String attributeName);
  external void removeAttribute(JSObject node, String attributeName);
  external void addClass(JSObject node, String value);
  external bool hasClass(JSObject node, String value);
  external void removeClass(JSObject node, String value);

  // 클래스 적용 메서드들
  external void applyTextClass(int index);
  external void applyImageClass(int index);
  external void applyBackgroundClass(int index);
  external void applyTableClass(int index);

  // Shape 스타일 관련 메서드들
  external void insertShape(String type, int index);
  external void setShapeLineColor(String color);
  external void setShapeLineWidth(int width);
  external void setShapeLineHeadType(String type);
  external void setShapeLineTailType(String type);
  external void setShapeLineHeadTailSize(int size);
  external void setShapeBackColor(String color);

  // animation
  external void setAnimation(JSObject node, JSObject property);
  external void removeAnimation(JSObject node);
  external void runAnimation(JSObject node);
  external void stopAnimation(JSObject node);

  // 선택 상태 확인을 위한 함수들
  external String
      selectedType(); // 현재 선택 타입 반환 ('none', 'caret', 'range', 'single', 'multi')
  external JSArray<JSObject> selectedNodes(); // 현재 선택된 노드들 반환
  external JSArray<JSObject> selectedCells(); // 현재 선택된 테이블 셀들 반환

  // 링크 관리 함수들
  external void applyLink(String link); // 현재 선택에 링크 적용 함수 추가
  external String getAppliedLink(); // 현재 선택에 적용된 링크값 조회 함수 추가
  external void removeLink(); // 현재 선택에 적용된 링크 제거 함수 추가

  // 다단 관리 함수들
  external void setMultiColumn(
      int count, // 다단 개수
      String fill, // 채우기 방식 ('auto' 또는 'balance')
      int gap, // 다단 간격
      String ruleStyle, // 구분선 스타일
      int ruleWidth, // 구분선 두께
      String ruleColor); // 구분선 색상
  external void removeMultiColumn(); // 다단 설정 제거

  // 테이블 조작 함수들
  external void insertTableRow(
      String option); // 행 삽입 ('start', 'end', 'above', 'below')
  external void insertTableColumn(
      String option); // 열 삽입 ('start', 'end', 'left', 'right')
  external void removeTableRow(String option); // 선택된 행 제거
  external void removeTableColumn(String option); // 선택된 열 제거
  external void mergeTableCell(); // 선택된 셀들 병합
  external void unmergeTableCell(); // 병합 해제 기능
  external void splitTableCell(int row, int column); // 선택된 셀 분할
  external void calculateTableCellData(
      JSCellFormatOption option); // 선택된 셀들 데이터 계산
  external void tableToTextbox(); // 테이블을 텍스트박스로 변환
  external void transposeTable(); // 테이블 행과 열 바꾸기

  // 애니메이션 속성 getter
  external JSObject? getAnimation(JSObject node); // 노드의 애니메이션 속성 반환

  // 에디터 활성화/비활성화
  external void enable(bool enabled); // 에디터 입력 가능 상태 설정

  external void applyListStyle(String styleName);
  external JsListStyle getListStyle();
  external bool isInsideOrderedList();
  external bool applyImageList(String listStyleImage);

  // undo & redo
  external void undo();
  external void redo();
  external bool canUndo();
  external bool canRedo();

  // undo & redo 그룹화
  // 두 함수(beginUndoGroup, endUndoGroup)는 항상 쌍으로 호출되어야 함
  external bool beginUndoGroup();
  external bool endUndoGroup();

  // 목차 아이콘 삽입
  external void insertTocLinkImage(int left, int top);

  external JSPosition scrollPosition();

  external void equalizeTableRowHeight();
  external void equalizeTableColumnWidth();

  // 컨테이너
  external void insertContainer(String type);
  external String isContainer(JSObject node);
  external void convertContainer(JSObject node, String type);

  // 위젯
  external void insertWidget(String markup, String? cssPath, String? jsPath,
      String? left, String? top); // 위젯 삽입 함수
  external JSObject selectedWidget(); // 위젯 선택 이벤트 함수
  external JSObject getWidgetInfo(JSObject node); // 위젯 정보 조회 함수
  external JSAny getWidgetProperty(JSObject node, String name); // 위젯 속성 조회 함수
  external void setWidgetProperty(
      JSObject node, String name, JSAny value); // 위젯 속성 설정 함수

  // TOC 위젯 관련 추가 기능
  external void setTocItemCount(JSObject node, int count); // 목차 항목 수 설정
  external void setTocListType(
      JSObject node, String listType); // 목록 유형 설정 (none, ul, ol)
  external void setTocListStyleType(
      JSObject node, String styleType); // 목록 스타일 설정
  external void setTocItemSpacing(JSObject node, String spacing); // 항목 간격 설정
  external void selectTocItem(JSObject node, int index); // 목차 항목 선택
  external int increaseSelectedItemLevel(JSObject node); // 선택된 항목 들여쓰기
  external int decreaseSelectedItemLevel(JSObject node); // 선택된 항목 내어쓰기
  external void setTocIndentSize(JSObject node, String size); // 들여쓰기 크기 설정
  external void setTocFromJson(JSObject node, JSAny jsonData); // JSON에서 목차 설정
  external JSString getTocAsJson(JSObject node); // 목차 데이터 JSON으로 가져오기
  external void setTocExampleData(JSObject node); // 예제 데이터로 목차 설정

  //목록 _________________________________________________________

  // 선택 영역에 목록 적용
  external bool canApplyList();
  external void applyList(String listStyleType);

  // 선택된 목록을 문단 태그로 변환
  external bool canUnapplyList();
  external void unapplyList();

  // 선택된 목록 들여쓰기
  external bool canIndentList();
  external void indentList();

  // 선택된 목록 내어쓰기
  external bool canOutdentList();
  external void outdentList();

  // 목록 클래스 적용
  external void applyListClass(int index);

  // 페이지 번호 위젯의 페이지 번호 값 변경
  external JSArray<JSObject> getWidgets(String widgetId);

  // body 영역 조작 __________________________________________________

  // body 조회
  external JSObject getBody();

  // body 배경색 조회/설정
  external String getBodyBackColor();
  external void setBodyBackColor(String value);

  // body 배경이미지 경로 조회/설정
  external String getBodyBackImageUrl();
  external void setBodyBackImageUrl(String value);

  // body 배경이미지 크기 조회/설정
  external String getBodyBackImageSize();
  external void setBodyBackImageSize(String value);

  // body 배경이미지 위치 조회/설정
  external String getBodyBackImagePosition();
  external void setBodyBackImagePosition(String value);

  // body 배경이미지 반복 조회/설정
  external String getBodyBackImageRepeat();
  external void setBodyBackImageRepeat(String value);

  external void printPages(JSArray<JSString> pages);

  // whiteboard 그리기 모드 관리
  external bool isDrawingModeEnabled();
  external bool whiteBoardIsMouseDown();
  external JSObject getWhiteBoardCurrentPoint();
  external JSObject getWhiteBoardDrawingState();
  external void isDrawingEditorXY(int x, int y);
  external void publicDrawPoint(int x, int y);
  external void publicErasePoint(int x, int y);
  external void toggleDrawingMode(String type);
  external void setDrawingStyle(JSObject style);
  external void clearDrawing();
  external void startDrawing(int x, int y);
  external void endDrawing();
  external void loadWhiteBoard();
  external void unloadWhiteBoard();
  // find & replace
  external int countMatches(String text, bool caseSensitive, bool wholeWord);
  external bool findNext(String text, bool caseSensitive, bool wholeWord);
  external bool findPrevious(String text, bool caseSensitive, bool wholeWord);
  external bool replaceSelectedText(
      String from, String to, bool caseSensitive, bool wholeWord);
  external int replaceTextAll(
      String from, String to, bool caseSensitive, bool wholeWord);
  external bool isCurrentSelectionMatch(
      String text, bool caseSensitive, bool wholeWord);

  // 서식 복사 & 붙여넣기
  external bool copySelectedStyle();
  external JSTextStyle copiedTextStyle();
  external JSParagraphStyle copiedParagraphStyle();
  external bool pasteStyleToSelection(bool textStyle, bool paragraphStyle);
  external bool canPasteStyle();
  external void clearCopiedStyle();

  // 북마크
  external bool insertBookmark(String name);
  external JSArray<JSString> getBookmarks();
  external bool selectBookmark(String name);
  external bool removeBookmark(String name);

  // 가상 리스트
  external JSArray<JSNumber> getVirtualListCounts();
  external JSArray<JSString> getVirtualListStyles();
  external bool setVirtualListDepth(int depth);
  external JSArray<JSNumber>
      getVirtualListStartNumbers(); // 각 depth별 시작 번호 배열 반환
  external bool setVirtualListDepthWithStyle(int depth, String styleType);
  external bool hasVirtualListInSelection();
  external String getCurrentVirtualListStyle();
  external int getSelectedVirtualListDepth();

  //캡션
  external bool canInsertCaption();
  external bool insertCaption(String caption);
  external bool removeCaption();
  external bool setCaptionPosition(String position); //'top' | 'bottom'
  external String getCaptionPosition();
  external bool canRemoveCaption();

  // 설정 가능한 폰트 리스트 조회. [['family','name'], ...]
  external JSArray<JSArray<JSString>> getInstalledFonts();

  // 메모
  external String getMemo();
  external void setMemo(String memo);
}
