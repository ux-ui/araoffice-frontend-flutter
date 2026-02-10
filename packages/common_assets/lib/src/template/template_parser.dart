import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:xml/xml.dart';

import '../../common_assets.dart';

/// Parse mode for template loading
enum TemplateParseMode {
  /// Load only category structure without template data
  shallow,
  /// Load all templates and their data immediately
  deep,
}

enum TemplateType {
  animation,
  book,
  clipart,
  cover,
  diagram,
  formula,
  layer,
  layout,
  page,
  widget,
  glogo,
}

/// Retrieve a template from asset bundle.
///
/// Example:
/// ```dart
/// try {
///   final templates = await TemplateParser.instance.parseTemplatesXml(
///     type: TemplateType.clipart,
///   );
///   templates.debug();
/// } catch (e) {
///   debugPrint('Error parsing XML: $e');
/// }
/// ```
class TemplateParser {
  factory TemplateParser() => _instance;
  static final TemplateParser _instance = TemplateParser._();
  static TemplateParser get instance => _instance;

  TemplateParser._();

  final Map<TemplateType, Templates> _templatesCache = {};
  final Map<String, Template> _individualTemplateCache = {}; // 개별 템플릿 캐시
  Templates? get templates => _templatesCache.values.isNotEmpty ? _templatesCache.values.first : null;
  String get _packageName => 'packages/${AssetGenImage.package}';

  /// Parse templates from asset bundle.
  ///
  /// [parseMode]:
  /// - [TemplateParseMode.shallow]: 카테고리 구조만 로드 (빠름)
  /// - [TemplateParseMode.deep]: 모든 템플릿 데이터까지 로드 (느림)
  ///
  /// Example:
  /// ```dart
  /// // 빠른 로딩 - 카테고리만
  /// final templates = await TemplateParser.instance.parseTemplatesXml(
  ///   type: TemplateType.clipart,
  ///   parseMode: TemplateParseMode.shallow,
  /// );
  /// 
  /// // 전체 로딩
  /// final templates = await TemplateParser.instance.parseTemplatesXml(
  ///   type: TemplateType.clipart,
  ///   parseMode: TemplateParseMode.deep,
  /// );
  /// ```
  Future<Templates> parseTemplatesXml({
    required TemplateType type,
    String? path,
    TemplateParseMode parseMode = TemplateParseMode.deep,
  }) async {
    // 캐시된 템플릿이 있으면 반환
    if (_templatesCache.containsKey(type)) {
      return _templatesCache[type]!;
    }
    
    try {
      final bundlePath = path ?? _assetPath(type);
      final xmlString = await rootBundle.loadString(bundlePath);
      final document = XmlDocument.parse(xmlString);
      final templatesElement = document.findAllElements('templates');
      if (templatesElement.isEmpty) {
        debugPrint('No element "templates"');
        return Templates.empty();
      }

      final rootPath = p.dirname(bundlePath);
      XmlElement foundElement;
      foundElement = templatesElement
          .firstWhere((element) => element.getAttribute('type') == type.name);

      // templates
      final templates = Templates.fromXmlElement(rootPath, foundElement);

      // templatedatas - parseMode에 따라 다르게 처리
      if (parseMode == TemplateParseMode.deep) {
        await _parseTemplateInfoXml(templates.children);
      }
      // shallow 모드에서는 템플릿 데이터를 로드하지 않음

      // 타입별로 캐시에 저장
      _templatesCache[type] = templates;
      return templates;
    } catch (e) {
      // throw FormatException('Failed to parse XML: $e "$type"');
      debugPrint('Failed to parse XML: $e "$type"');
    }

    return Templates.empty();
  }

  /// Retrieve a `Template` by template name.
  ///
  /// Example:
  /// ```dart
  /// final template = TemplateParser.instance.getTemplateByName('fall');
  /// debugPrint(template.toString());
  /// ```
  Template? getTemplateByName(String templateName) {
    // 모든 캐시된 템플릿에서 검색
    for (var templates in _templatesCache.values) {
      for (var e in templates.children) {
        final template = e.getTemplateByName(templateName);
        if (template != null) {
          return template;
        }
      }
    }
    return null;
  }

  /// Retrieve the list of `TemplateData` by template name.
  ///
  /// Example:
  /// ```dart
  /// final dataList = TemplateParser.instance.getTemplateDataByName('fall');
  /// debugPrint(dataList.toString());
  /// ```
  List<TemplateData> getTemplateDataByName(String templateName) {
    final template = getTemplateByName(templateName);
    return template?.templateInfo?.templateDatas ?? [];
  }

  /// Retrieve a `Template` by template name from specific type.
  ///
  /// Example:
  /// ```dart
  /// final template = TemplateParser.instance.getTemplateByNameFromType(
  ///   templateName: 'korea',
  ///   type: TemplateType.glogo,
  /// );
  /// debugPrint(template.toString());
  /// ```
  Template? getTemplateByNameFromType({
    required String templateName,
    required TemplateType type,
  }) {
    final templates = _templatesCache[type];
    if (templates == null) return null;
    
    for (var e in templates.children) {
      final template = e.getTemplateByName(templateName);
      if (template != null) {
        return template;
      }
    }
    return null;
  }

  /// Retrieve the list of `TemplateData` by template name from specific type.
  ///
  /// Example:
  /// ```dart
  /// final dataList = TemplateParser.instance.getTemplateDataByNameFromType(
  ///   templateName: 'korea',
  ///   type: TemplateType.glogo,
  /// );
  /// debugPrint(dataList.toString());
  /// ```
  List<TemplateData> getTemplateDataByNameFromType({
    required String templateName,
    required TemplateType type,
  }) {
    final template = getTemplateByNameFromType(
      templateName: templateName,
      type: type,
    );
    return template?.templateInfo?.templateDatas ?? [];
  }

  /// Get cached templates by type.
  ///
  /// Example:
  /// ```dart
  /// final glogoTemplates = TemplateParser.instance.getCachedTemplates(TemplateType.glogo);
  /// ```
  Templates? getCachedTemplates(TemplateType type) {
    return _templatesCache[type];
  }

  /// Clear all cached templates.
  void clearCache() {
    _templatesCache.clear();
    _individualTemplateCache.clear();
  }

  /// Clear cached templates for specific type.
  void clearCacheForType(TemplateType type) {
    _templatesCache.remove(type);
    // 해당 타입의 개별 템플릿 캐시도 제거
    final keysToRemove = _individualTemplateCache.keys
        .where((key) => key.startsWith('${type.name}:'))
        .toList();
    for (final key in keysToRemove) {
      _individualTemplateCache.remove(key);
    }
  }

  /// Load template data for specific template if not already loaded.
  /// 지연 로딩: 필요할 때만 템플릿 데이터를 로드
  ///
  /// Example:
  /// ```dart
  /// await TemplateParser.instance.loadTemplateData(
  ///   templateName: 'fall',
  ///   type: TemplateType.clipart,
  /// );
  /// ```
  Future<bool> loadTemplateData({
    required String templateName,
    required TemplateType type,
  }) async {
    final cacheKey = '${type.name}:$templateName';
    
    // 이미 로드된 경우 스킵
    if (_individualTemplateCache.containsKey(cacheKey)) {
      return true;
    }
    
    try {
      final template = getTemplateByNameFromType(
        templateName: templateName,
        type: type,
      );
      
      if (template == null) {
        debugPrint('템플릿을 찾을 수 없음: $templateName (타입: ${type.name})');
        return false;
      }
      
      // 이미 템플릿 데이터가 로드되어 있는지 확인
      if (template.templateInfo != null) {
        _individualTemplateCache[cacheKey] = template;
        return true;
      }
      
      // 템플릿 데이터 로드
      final xmlString = await rootBundle.loadString('${template.path}/template.xml');
      template.templateInfoFromXml(xmlString);
      
      // 캐시에 저장
      _individualTemplateCache[cacheKey] = template;
      
      debugPrint('템플릿 데이터 로드 완료: $templateName');
      return true;
      
    } catch (e) {
      debugPrint('템플릿 데이터 로드 실패: $templateName - $e');
      return false;
    }
  }

  /// Load template data for multiple templates.
  /// 여러 템플릿을 동시에 로드
  ///
  /// Example:
  /// ```dart
  /// await TemplateParser.instance.loadMultipleTemplateData(
  ///   templateNames: ['fall', 'winter', 'spring'],
  ///   type: TemplateType.clipart,
  /// );
  /// ```
  Future<Map<String, bool>> loadMultipleTemplateData({
    required List<String> templateNames,
    required TemplateType type,
  }) async {
    final results = <String, bool>{};
    
    final futures = templateNames.map((name) async {
      final success = await loadTemplateData(
        templateName: name,
        type: type,
      );
      results[name] = success;
      return success;
    });
    
    await Future.wait(futures);
    return results;
  }

  /// Get template data with lazy loading.
  /// 지연 로딩으로 템플릿 데이터 가져오기
  ///
  /// Example:
  /// ```dart
  /// final templateData = await TemplateParser.instance.getTemplateDataLazy(
  ///   templateName: 'fall',
  ///   type: TemplateType.clipart,
  /// );
  /// ```
  Future<List<TemplateData>> getTemplateDataLazy({
    required String templateName,
    required TemplateType type,
  }) async {
    // 템플릿 데이터 로드 (아직 로드되지 않았다면)
    await loadTemplateData(
      templateName: templateName,
      type: type,
    );
    
    // 로드된 데이터 반환
    return getTemplateDataByNameFromType(
      templateName: templateName,
      type: type,
    );
  }

  /// Check if template data is loaded.
  /// 템플릿 데이터가 로드되어 있는지 확인
  bool isTemplateDataLoaded({
    required String templateName,
    required TemplateType type,
  }) {
    final cacheKey = '${type.name}:$templateName';
    return _individualTemplateCache.containsKey(cacheKey);
  }

  /// Get all loaded template names for a specific type.
  /// 특정 타입에서 로드된 모든 템플릿 이름 반환
  List<String> getLoadedTemplateNames(TemplateType type) {
    return _individualTemplateCache.keys
        .where((key) => key.startsWith('${type.name}:'))
        .map((key) => key.split(':')[1])
        .toList();
  }

  String _assetPath(TemplateType type) {
    var path = '';
    switch (type) {
      case TemplateType.clipart:
        path = 'assets/templates/templates.xml';
        break;
      case TemplateType.glogo:
        path = 'assets/templates/templates.xml';
        break;
      default:
        break;
    }
    return '$_packageName/$path';
  }

  Future<void> _parseTemplateInfoXml(List<Template> children) async {
    for (var template in children) {
      if (template.haveChildElements) {
        await _parseTemplateInfoXml(template.children);
      } else {
        try {
          final xmlString =
              await rootBundle.loadString('${template.path}/template.xml');
          template.templateInfoFromXml(xmlString);
        } catch (e) {
          throw FormatException('Failed to parse XML: $e');
        }
      }
    }
  }
}

// IDS_GALLERY_PICTURE_TEMPLATE "그림 템플릿"
// IDS_GALLERY_GALLERY_TEMPLATE "갤러리 템플릿"
// IDS_GALLERY_CLIPART_TEMPLATE "클립아트 템플릿"
// IDS_GALLERY_VIDEO_TEMPLATE "비디오 템플릿"
// IDS_GALLERY_AUDIO_TEMPLATE "오디오 템플릿"

// ID_FONT_EMPHASIS_FILLED_DOUBLE_CIRCLE "채움 이중 원"
// ID_FONT_EMPHASIS_FILLED_TRIANGLE "채움 삼각형"
// ID_FONT_EMPHASIS_FILLED_SESAME "채움 강조"
// ID_INSERT_INSERTPICTURE "그림을 삽입합니다.\n그림"
// ID_INSERT_GALLERY       "갤러리를 삽입합니다.\n갤러리"
// ID_INSERT_VIDEO         "비디오를 삽입합니다.\n비디오"
// ID_INSERT_AUDIO         "오디오를 삽입합니다.\n오디오"
// ID_INSERT_SCREENSHOT    "화면 캡처 모드로 전환하여, 선택한 영역의 화면을 그림으로 삽입합니다.\n화면캡처"
// ID_INSERT_CLIPART       "클립아트를 삽입합니다.\n클립아트"
// ID_INSERT_ANIMATION     "애니메이션 효과를 삽입합니다.\n애니메이션"
// ID_INSERT_FIGURE        "도형을 삽입합니다.\n도형"

/**
[Book]
Book/Fixed
경제 고급
경제 입문
소설 입문
시 초급
에세이 중급
에세이 초급
영단어 고급
영어단어장 입문
음식기행 입문
음식기행 초급
F-Book001
F-Book002
F-Book003
F-Book004
Book/Reflow
1 메밀꽃필무렵
2 진달래꽃
3 대한민국헌법
4 나모오서가이드
소설1
소설2
역사
자서전
R-Book001
R-Book002
R-Book003
R-Book004
R-Book005

[Clipart]
계절 배경
계절 배경/가을
계절 배경/겨울
계절 배경/날씨
계절 배경/봄
계절 배경/여름
교육
교육/과학
교육/미술
교육/수학
교육/시간표
교육/영어
교육/음악
교육/지리
교육/체육
교육/학교생활
교육/학생용품
교통
교통/교통
기호 문자
기호 문자/기호
기호 문자/꽃모양 알파벳
기호 문자/박스형 알파벳
기호 문자/숫자
기호 문자/알파벳
기호 문자/특수문자
기호 문자/화살표
동식물
동식물/곤충 파충류
동식물/꽃
동식물/나무
동식물/동물
동식물/새
동식물/어류
라이프 스타일
라이프 스타일/의학건강
라이프 스타일/이벤트
라이프 스타일/패션뷰티
문화
문화/과일 야채
문화/기독교
문화/디저트
문화/불교
문화/음식
문화/전통문화
비즈니스
비즈니스/직업
소품
소품/가정용품
소품/사무용품
소품/스마트기기
소품/스포츠 레저용품
소품/장난감
스포츠
스포츠/농구
스포츠/당구
스포츠/등산
스포츠/배드민턴
스포츠/볼링
스포츠/스키
스포츠/야구
스포츠/축구
스포츠/하키
스포츠/핸드볼
인물
인물/가족
인물/남성
인물/어린이
인물/여성
인물/유아
인물/중년 노인
인물/청소년
인물/캐틱터

[Formula]
기호 및 부호
단위 수식
대표 수식

[Page]
Page/Fixed
경제 문서 1
경제 문서 2
경제 문서 3
에세이 문서 1
에세이 문서 2
영단어 문서 1
영단어 문서 2
영단어 문서 3
영단어 문서 4
영어단어장 문서 1
영어단어장 문서 2
영어단어장 문서 3
음식기행 문서 1
음식기행 문서 2
음식기행 문서 3
음식기행 문서 4
음식기행 문서 5
F-Page001
F-Page003
F-Page005
F-Page007
F-Page008
F-Page009
F-Page010
F-Page011
F-Page012
Page/Reflow
R-Page001
R-Page002
R-Page003
R-Page004
R-Page005
R-Page006
R-Page008
R-Page009
R-Page010
 */
