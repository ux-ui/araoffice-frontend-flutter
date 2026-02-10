class SignUpResponse {
  final bool isDuplicate;
  final bool isAvailable;
  final String message;

  SignUpResponse({
    required this.isDuplicate,
    required this.isAvailable,
    required this.message,
  });
}
