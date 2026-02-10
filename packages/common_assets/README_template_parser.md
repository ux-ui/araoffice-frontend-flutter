# Template Parser

Flutter 앱에서 XML 기반 템플릿을 파싱하고 관리하는 라이브러리입니다.
**지연 로딩(Lazy Loading)** 기능으로 성능을 크게 향상시켰습니다.

## 🚀 성능 최적화 특징

- **지연 로딩**: 필요한 템플릿만 선택적으로 로드
- **타입별 캐싱**: 각 템플릿 타입별로 독립적인 캐시 관리
- **병렬 처리**: 여러 템플릿을 동시에 로드
- **메모리 최적화**: 사용하지 않는 캐시 자동/수동 제거

## 지원하는 템플릿 타입

- **Clipart**: 클립아트 템플릿 (계절 배경, 교육, 인물 등)
- **Glogo**: 관공서 로고 템플릿 (대한민국정부, 행정안전부 등)
- **기타**: Animation, Book, Cover, Diagram, Formula, Layer, Layout, Page, Widget 등

## 파싱 모드

### TemplateParseMode.shallow (빠른 로딩 - 권장)
- 카테고리 구조만 먼저 로드
- 템플릿 데이터는 필요할 때 지연 로딩
- 앱 시작 시간 대폭 단축

### TemplateParseMode.deep (전체 로딩)
- 모든 템플릿 데이터를 한번에 로드
- 기존 방식과 동일
- 초기 로딩 시간이 오래 걸림

## 🔥 권장 사용 패턴

### 1. 앱 초기화 - 빠른 시작
```dart
// 카테고리 구조만 빠르게 로드 (1-2초)
final templates = await TemplateParser.instance.parseTemplatesXml(
  type: TemplateType.clipart,
  parseMode: TemplateParseMode.shallow, // 빠른 모드
);

// UI에 카테고리 목록 즉시 표시 가능
for (var category in templates.children) {
  print('카테고리: ${category.description}');
}
```

### 2. 사용자 선택 시 - 지연 로딩
```dart
// 사용자가 특정 카테고리 선택 시에만 로드
final seasonTemplates = ['fall', 'winter', 'spring', 'summer'];
final results = await TemplateParser.instance.loadMultipleTemplateData(
  templateNames: seasonTemplates,
  type: TemplateType.clipart,
);
```

### 3. 데이터 사용 - 즉시 사용
```dart
// 이미 로드된 데이터는 즉시 사용 가능
final fallData = TemplateParser.instance.getTemplateDataByNameFromType(
  templateName: 'fall',
  type: TemplateType.clipart,
);
```

### 4. 메모리 최적화
```dart
// 사용하지 않는 템플릿 타입 제거
TemplateParser.instance.clearCacheForType(TemplateType.clipart);

// 또는 전체 캐시 제거
TemplateParser.instance.clearCache();
```

## 사용법

### 1. 기본 사용법

```dart
import 'package:common_assets/src/template/template_parser.dart';

// Clipart 템플릿 파싱
final clipartTemplates = await TemplateParser.instance.parseTemplatesXml(
  type: TemplateType.clipart,
);

// Glogo 템플릿 파싱
final glogoTemplates = await TemplateParser.instance.parseTemplatesXml(
  type: TemplateType.glogo,
);
```

### 2. 특정 템플릿 검색

```dart
// 전체 캐시에서 검색
final template = TemplateParser.instance.getTemplateByName('korea');

// 특정 타입에서만 검색
final glogoTemplate = TemplateParser.instance.getTemplateByNameFromType(
  templateName: 'korea',
  type: TemplateType.glogo,
);
```

### 3. 템플릿 데이터 가져오기

```dart
// 템플릿 데이터 리스트 가져오기
final templateData = TemplateParser.instance.getTemplateDataByName('fall');

// 특정 타입에서 템플릿 데이터 가져오기
final glogoData = TemplateParser.instance.getTemplateDataByNameFromType(
  templateName: 'korea',
  type: TemplateType.glogo,
);
```

### 4. 캐시 관리

```dart
// 캐시된 템플릿 가져오기
final cachedTemplates = TemplateParser.instance.getCachedTemplates(TemplateType.glogo);

// 특정 타입 캐시 제거
TemplateParser.instance.clearCacheForType(TemplateType.clipart);

// 전체 캐시 제거
TemplateParser.instance.clearCache();
```

### 5. 병렬 로딩

```dart
// 여러 템플릿을 동시에 로드
final results = await Future.wait([
  TemplateParser.instance.parseTemplatesXml(type: TemplateType.clipart),
  TemplateParser.instance.parseTemplatesXml(type: TemplateType.glogo),
]);

final clipartTemplates = results[0];
final glogoTemplates = results[1];
```

## 예시 코드

자세한 사용 예시는 `example/template_parser_example.dart` 파일을 참고하세요.

```dart
import 'package:common_assets/example/template_parser_example.dart';

// 모든 예시 실행
await TemplateParserExample.runAllExamples();

// Glogo 템플릿만 테스트
await TemplateParserExample.exampleGlogo();
```

## 템플릿 구조

### Clipart 템플릿
- 계절 배경 (가을, 겨울, 날씨, 봄, 여름)
- 교육 (과학, 미술, 수학, 영어 등)
- 인물 (가족, 남성, 여성, 어린이 등)
- 동식물 (동물, 새, 꽃, 나무 등)
- 기타 다양한 카테고리

### Glogo 템플릿
- 대한민국정부 로고
- 행정안전부 로고
- 소방청 로고
- 기타 관공서 로고

## 폴더 구조

```
assets/templates/
├── templates.xml          # 메인 템플릿 정의
├── clipart/              # 클립아트 이미지들
│   ├── seasons/
│   ├── education/
│   └── ...
└── glogo/               # 관공서 로고들
    ├── korea/
    ├── mois/
    └── ...
```

## 성능 최적화

- **캐싱**: 한번 로드된 템플릿은 메모리에 캐시되어 재사용
- **타입별 관리**: 각 템플릿 타입별로 독립적인 캐시 관리
- **지연 로딩**: 필요한 템플릿만 선택적으로 로드
- **메모리 해제**: 불필요한 캐시는 수동으로 제거 가능

## 에러 처리

템플릿 파싱 중 오류가 발생하면 빈 Templates 객체가 반환되며, 디버그 모드에서 오류 메시지가 출력됩니다.

```dart
try {
  final templates = await TemplateParser.instance.parseTemplatesXml(
    type: TemplateType.glogo,
  );
} catch (e) {
  debugPrint('템플릿 파싱 오류: $e');
}
```
