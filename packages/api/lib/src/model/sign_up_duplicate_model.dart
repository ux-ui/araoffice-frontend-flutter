class SignUpDuplicateModel {
  final bool isDuplicate;
  final bool? isAvailable;
  final String message;

  SignUpDuplicateModel({
    required this.isDuplicate,
    this.isAvailable = true,
    required this.message,
  });

  factory SignUpDuplicateModel.fromJson(Map<String, dynamic> json) {
    return SignUpDuplicateModel(
      isDuplicate: json['isDuplicate'],
      isAvailable: json['isAvailable'] ?? true,
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() => {
        'isDuplicate': isDuplicate,
        'isAvailable': isAvailable ?? true,
        'message': message,
      };
}
