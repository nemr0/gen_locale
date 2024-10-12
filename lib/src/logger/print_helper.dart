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

  final List<String> _messages = [];

  _addToPrintMessages(String message) => _messages.add(message);

  final Stopwatch _stopwatch = Stopwatch();
  bool verbose = false;

  final Logger _logger = Logger(
    theme: LogTheme(
      success: (s) => green.wrap(s),
      err: (s) => red.wrap(s),
    ),
  );

  void print(String text,
      {AnsiCode color = lightGray,
      AnsiCode style = lightGray,
      bool addToMessages = false,bool flushAndRewrite = false}) {
    final message = style.wrap(color.wrap(text));
    _logger.info(message);
    if(flushAndRewrite){
      _flushAndRewrite(message!,'');
    }
    if (addToMessages && !flushAndRewrite) _addToPrintMessages(message!);
  }

  /// Prints the logo in ./ansi_logo.dart
  void version() => _logger.info(
        logoFile(
          'genlocale: 0.1.0',
        ),
      );

  String msg = '';

  bool get _hasTerminal => io.stdout.hasTerminal;

  void _flushAndRewrite(String promptMessage, String result) async {
    _logger.flush();
    version();

    _addToPrintMessages('$promptMessage ${cyan.wrap(result)}');
    for (String s in _messages) {
      print(s);
    }
  }

  T chooseOne<T>(String message, List<T> choices, T defaultValue) {
    if (!_hasTerminal) {
      return defaultValue;
    }
    T result = _logger.chooseOne(message, choices: choices, defaultValue: defaultValue);
    _flushAndRewrite(message, result.toString());
   return result;
  }

  String prompt(String message, String defaultValue,{bool skipFlush = false}) {
    if (!_hasTerminal) {
      return defaultValue;
    }
    String result = _logger.prompt(message, defaultValue: defaultValue);
   if(!skipFlush) _flushAndRewrite(message, result);
    return result;
  }

  List<String> promptAny(String message,
      {List<String> defaultValue = const []}) {
    if (!_hasTerminal) {
      return defaultValue;
    }
    final List<String> results = _logger.promptAny(message);
    _flushAndRewrite(message, results.toString());
    return results;
  }

  Progress? _progress;

  void addProgress(String message) {
    msg = message;
    _stopwatch.reset();
    _stopwatch.start();
    _progress = _logger.progress(message);
  }

  void updateProgress(String message) {
    _stopwatch.stop();
    _progress?.complete(green.wrap(msg));

    _messages.add(
      '''${lightGreen.wrap('✓')} $msg $_time\n''',
    );
    msg = message;
    _progress = _logger.progress(message);
  }

  void updateCurrentProgress(String message) {
    msg = message;
    _progress?.update(yellow.wrap(msg) ?? msg);
  }

  void completeProgress() {
    _stopwatch.stop();
    _messages.add(
      '''${lightGreen.wrap('✓')} $msg $_time\n''',
    );
    _progress?.complete(green.wrap(msg));
  }

  void fail(String error) => _logger.err(error);

  void progressFailed(String error) =>
      _progress == null ? _logger.err(error) : _progress?.fail(red.wrap(error));

  String get _time {
    final elapsedTime = _stopwatch.elapsed.inMilliseconds;
    final displayInMilliseconds = elapsedTime < 100;
    final time = displayInMilliseconds ? elapsedTime : elapsedTime / 1000;
    final formattedTime =
        displayInMilliseconds ? '${time}ms' : '${time.toStringAsFixed(1)}s';
    return '${darkGray.wrap('($formattedTime)')}';
  }
}
