import 'package:mason_logger/mason_logger.dart';
import 'dart:io' as io;
import 'ansi_logo.dart';

class PrintHelper {
  /// Prints logo + App Name + Version + Generating Localization Message
  factory PrintHelper() {
    return _helper;
  }

  static final PrintHelper _helper = PrintHelper._internal();

  PrintHelper._internal();

  bool verbose = false;
  final Logger _logger = Logger(
    theme: LogTheme(
      success: (s) => green.wrap(s),
      err: (s) => red.wrap(s),
    ),
  );

  print(String text, [AnsiCode color = lightGray,AnsiCode style = lightGray]) => _logger.info(style.wrap(color.wrap(text)));

  /// Prints the logo in ./ansi_logo.dart
  void version() => _logger.info(
        logoFile(
          'genlocale: 0.0.1',
        ),
      );

  String msg = '';

  bool get _hasTerminal => io.stdout.hasTerminal;

  T chooseOne<T>(String message, List<T> choices, T defaultValue) =>
      _hasTerminal ? _logger.chooseOne(message, choices: choices, defaultValue: defaultValue) : defaultValue;

  String prompt(String message, String defaultValue) =>
      _hasTerminal ? _logger.prompt(message, defaultValue: defaultValue) : defaultValue;

  List<String> promptAny(String message, {List<String> defaultValue = const []}) =>
      _hasTerminal ? _logger.promptAny(message) : defaultValue;

   Progress? _progress;

  void addProgress(String message) {
    msg = message;
    _progress = _logger.progress(message);
  }

  void updateProgress(String message) {
    _progress?.complete(green.wrap(msg));
    msg = message;
    _progress = _logger.progress(message);
  }

  void updateCurrentProgress(String message) {
    msg = message;
    _progress?.update(yellow.wrap(msg) ?? msg);
  }

  void completeProgress() => _progress?.complete(green.wrap(msg));
  void fail(String error)=> _logger.err(error);
  void progressFailed(String error) =>_progress==null?_logger.err(error): _progress?.fail(red.wrap(error));
}
