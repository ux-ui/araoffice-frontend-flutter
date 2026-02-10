enum DragTargetPosition { above, below, inside }

class TreeListModel {
  final String id;
  String parentId;
  final String title;
  final String idref;
  final bool linear;
  final String href;
  final String thumbnail;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final Map<String, String> properties;
  final String type;
  final String? editorUser;
  int? calculatedPage; // 계산된 페이지 번호

  TreeListModel({
    required this.id,
    required this.parentId,
    required this.title,
    required this.idref,
    required this.linear,
    required this.href,
    required this.thumbnail,
    required this.createdAt,
    required this.modifiedAt,
    this.type = 'normal',
    this.properties = const {},
    this.editorUser,
    this.calculatedPage,
  });

  // 모든 페이지가 이동 가능하도록 isFixed는 항상 false
  bool get isFixed => false;
  // 모든 페이지가 하위 페이지를 가질 수 있도록 canHaveChildren은 항상 true
  bool get canHaveChildren => true;

  // JSON 직렬화
  Map<String, dynamic> toJson() => {
        'id': id,
        'parentId': parentId,
        'title': title,
        'idref': idref,
        'linear': linear,
        'href': href,
        'thumbnail': thumbnail,
        'createdAt': createdAt.toIso8601String(),
        'modifiedAt': modifiedAt.toIso8601String(),
        'type': type,
        'properties': properties,
        'editorUser': editorUser,
        'calculatedPage': calculatedPage,
      };

  // JSON 역직렬화
  factory TreeListModel.fromJson(Map<String, dynamic> json) => TreeListModel(
        id: json['id'] as String,
        parentId: json['parentId'] as String? ?? '',
        title: json['title'] as String,
        idref: json['idref'] as String,
        linear: json['linear'] as bool,
        href: json['href'] as String,
        thumbnail: json['thumbnail'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        modifiedAt: DateTime.parse(json['modifiedAt'] as String),
        type: json['type'] as String? ?? 'normal',
        properties: (json['properties'] as Map<String, dynamic>?)?.map(
              (key, value) => MapEntry(key, value.toString()),
            ) ??
            {},
        editorUser: (json['editorUser'] as Map<String, dynamic>?) != null
            ? (json['editorUser'] as Map<String, dynamic>)
                    .containsKey('displayName')
                ? (json['editorUser'] as Map<String, dynamic>)['displayName']
                    as String?
                : null
            : null,
        calculatedPage: json['calculatedPage'] as int?,
      );

  // 리스트 변환 헬퍼 메서드
  static List<TreeListModel> listFromJson(List<Map<String, dynamic>> jsonList) {
    return jsonList.map((json) => TreeListModel.fromJson(json)).toList();
  }

  static List<Map<String, dynamic>> listToJson(List<TreeListModel> models) {
    return models.map((model) => model.toJson()).toList();
  }
}
