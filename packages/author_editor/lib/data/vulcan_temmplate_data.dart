// template_model.dart 템플릿 단건 조회, 썸네일 포함한 모델
class VulcanTemplateData {
  String id;
  final String name;
  final String authorNo;
  final String thumbnail;
  final String thumbnailUrl;
  final int favoriteCount;
  final bool free;
  final bool fixed;
  final String category;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final String templageUrl;
  final List<VulcanTemplatePage> pages;

  VulcanTemplateData({
    required this.id,
    required this.name,
    required this.authorNo,
    required this.thumbnail,
    required this.thumbnailUrl,
    required this.favoriteCount,
    required this.free,
    required this.fixed,
    required this.category,
    required this.createdAt,
    required this.modifiedAt,
    required this.templageUrl,
    required this.pages,
  });

  factory VulcanTemplateData.fromJson(Map<String, dynamic> json) {
    return VulcanTemplateData(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      authorNo: json['authorNo'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      templageUrl: json['templageUrl'] ?? '',
      favoriteCount: json['favoriteCount'] ?? 0,
      free: json['free'] ?? false,
      fixed: json['fixed'] ?? false,
      category: json['category'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      modifiedAt: DateTime.parse(json['modifiedAt']),
      pages: (json['pages'] as List<dynamic>?)
              ?.map(
                  (e) => VulcanTemplatePage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'authorNo': authorNo,
        'thumbnail': thumbnail,
        'thumbnailUrl': thumbnailUrl,
        'templageUrl': templageUrl,
        'favoriteCount': favoriteCount,
        'free': free,
        'fixed': fixed,
        'category': category,
        'createdAt': createdAt.toIso8601String(),
        'modifiedAt': modifiedAt.toIso8601String(),
        'pages': pages.map((e) => e.toJson()).toList(),
      };
}

// template_page_model.dart
class VulcanTemplatePage {
  final String idref;
  final bool linear;
  final String href;
  final String thumbnail;
  final String thumbnailUrl;
  final Map<String, dynamic> properties;
  final DateTime createdAt;
  final DateTime modifiedAt;

  VulcanTemplatePage({
    required this.idref,
    required this.linear,
    required this.href,
    required this.thumbnail,
    required this.thumbnailUrl,
    required this.properties,
    required this.createdAt,
    required this.modifiedAt,
  });

  factory VulcanTemplatePage.fromJson(Map<String, dynamic> json) {
    return VulcanTemplatePage(
      idref: json['idref'] ?? '',
      linear: json['linear'] ?? false,
      href: json['href'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
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
        'thumbnailUrl': thumbnailUrl,
        'properties': properties,
        'createdAt': createdAt.toIso8601String(),
        'modifiedAt': modifiedAt.toIso8601String(),
      };
}
