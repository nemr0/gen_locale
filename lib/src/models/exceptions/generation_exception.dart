import 'package:gen_locale/src/models/exceptions/stack_exception.dart';

class GenerationException extends StackException {
  GenerationException({required super.message, required super.stack});
}
