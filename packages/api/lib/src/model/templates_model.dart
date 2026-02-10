// templates_model.dart 내 탬플릿, 간단한 템플릿 정보 모델
class TemplatesModel {
  final String id;
  final String name;
  final String authorNo;
  final String thumbnail;
  final int favoriteCount;
  final bool free;
  final bool fixed;
  final String category;
  final DateTime createdAt;
  final DateTime modifiedAt;

  TemplatesModel({
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
  });

  factory TemplatesModel.fromJson(Map<String, dynamic> json) {
    return TemplatesModel(
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
      };
}
