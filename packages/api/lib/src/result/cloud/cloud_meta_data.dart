class CloudMetaData {
  final String? nextCursor;

  CloudMetaData({this.nextCursor});

  factory CloudMetaData.fromJson(Map<String, dynamic> json) {
    return CloudMetaData(
      nextCursor: json['nextCursor'],
    );
  }
}
