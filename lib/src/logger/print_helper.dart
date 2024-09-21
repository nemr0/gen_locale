
import 'package:mason_logger/mason_logger.dart';

import 'ansi_logo.dart';

class PrintHelper {
  /// Prints logo + App Name + Version + Generating Localization Message
  factory PrintHelper() {
    return _helper;
  }

  static final PrintHelper _helper = PrintHelper._internal();

  PrintHelper._internal();
  bool verbose = false;
  final Logger _print = Logger(theme: LogTheme(success: (s) => green.wrap(s), err: (s) => red.wrap(s),),);
  print(String text)=>_print.info(text);
  /// Prints the logo in ./ansi_logo.dart
  void version() => _print.info(
        logoFile(
          'generate_localization_file: 0.0.1',
        ),
      );

  String msg = '';


  late Progress _progress;

  void addProgress(String message) {
    msg = message;
    _progress = _print.progress(message);
  }

 void updateProgress(String message) {
    _progress.complete(green.wrap(msg));
    msg = message;
    _progress = _print.progress(message);

  }
  void updateCurrentProgress(String message){
    msg=message;
    _progress.update(yellow.wrap(msg)??msg);
  }

  void completeProgress() => _progress.complete(green.wrap(msg));

  void failed(String error) => _progress.fail(red.wrap(error));
}
