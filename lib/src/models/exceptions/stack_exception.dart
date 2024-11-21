class StackException implements Exception{
  final String message;
  final String stack;
  StackException({required this.message, required this.stack});
}