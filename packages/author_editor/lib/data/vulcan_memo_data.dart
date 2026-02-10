class VulcanMemoData {
  final String? id;
  final String? memo;
  final DateTime? createdAt;
  final String? nickname;
  final String? pageId;

  VulcanMemoData({
    this.id,
    this.memo,
    this.createdAt,
    this.nickname,
    this.pageId,
  });

  factory VulcanMemoData.fromJson(Map<String, dynamic> json) {
    return VulcanMemoData(
      id: json['id'],
      memo: json['memo'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      nickname: json['nickname'],
      pageId: json['pageId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memo': memo,
      'createdAt': createdAt?.toIso8601String(),
      'nickname': nickname,
      'pageId': pageId,
    };
  }

  VulcanMemoData copyWith({
    String? id,
    String? memo,
    DateTime? createdAt,
    String? nickname,
    String? pageId,
  }) {
    return VulcanMemoData(
      id: id ?? this.id,
      memo: memo ?? this.memo,
      createdAt: createdAt ?? this.createdAt,
      nickname: nickname ?? this.nickname,
      pageId: pageId ?? this.pageId,
    );
  }

  @override
  String toString() {
    return 'VulcanMemoData(memo: $memo, createdAt: $createdAt, nickname: $nickname)';
  }
}
