class IntializeException implements Exception {
  final String message;
  final String stack;
  IntializeException({required this.message, required this.stack});
}
