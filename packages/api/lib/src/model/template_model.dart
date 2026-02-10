// template_model.dart 템플릿 단건 조회, 썸네일 포함한 모델
class TemplateModel {
  String id;
  final String name;
  final String authorNo;
  final String thumbnail;
  final int favoriteCount;
  final bool free;
  final bool fixed;
  final String category;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final String language;
  final List<TemplatePageModel> pages;

  TemplateModel({
    required this.id,
    required this.name,
    required this.authorNo,
    required this.thumbnail,
    required this.favoriteCount,
    required this.free,
    required this.fixed,
    required this.category,
    required this.createdAt,
    required this.modifiedAt,
    required this.pages,
    required this.language,
  });

  factory TemplateModel.fromJson(Map<String, dynamic> json) {
    return TemplateModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      authorNo: json['authorNo'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      favoriteCount: json['favoriteCount'] ?? 0,
      free: json['free'] ?? false,
      fixed: json['fixed'] ?? false,
      category: json['category'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      modifiedAt: DateTime.parse(json['modifiedAt']),
      language: json['language'] ?? '',
      pages: (json['pages'] as List<dynamic>?)
              ?.map(
                  (e) => TemplatePageModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'authorNo': authorNo,
        'thumbnail': thumbnail,
        'favoriteCount': favoriteCount,
        'free': free,
        'fixed': fixed,
        'category': category,
        'createdAt': createdAt.toIso8601String(),
        'modifiedAt': modifiedAt.toIso8601String(),
        'pages': pages.map((e) => e.toJson()).toList(),
        'language': language,
      };
}

// template_page_model.dart
class TemplatePageModel {
  final String idref;
  final bool linear;
  final String href;
  final String thumbnail;
  final Map<String, dynamic> properties;
  final DateTime createdAt;
  final DateTime modifiedAt;

  TemplatePageModel({
    required this.idref,
    required this.linear,
    required this.href,
    required this.thumbnail,
    required this.properties,
    required this.createdAt,
    required this.modifiedAt,
  });

  factory TemplatePageModel.fromJson(Map<String, dynamic> json) {
    return TemplatePageModel(
      idref: json['idref'] ?? '',
      linear: json['linear'] ?? false,
      href: json['href'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      properties: json['properties'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.parse(json['createdAt']),
      modifiedAt: DateTime.parse(json['modifiedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'idref': idref,
        'linear': linear,
        'href': href,
        'thumbnail': thumbnail,
        'properties': properties,
        'createdAt': createdAt.toIso8601String(),
        'modifiedAt': modifiedAt.toIso8601String(),
      };
}
