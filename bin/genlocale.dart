
import 'package:args/args.dart';
import 'package:gen_locale/gen_locale.dart';
import 'package:gen_locale/src/logger/print_helper.dart';

ArgParser buildParser() {
  return ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Print this usage information.',
    )
    ..addFlag(
      'verbose',
      abbr: 'v',
      negatable: false,
      help: 'Show additional command output.',
    )
    ..addFlag(
      'version',
      negatable: false,
      help: 'Print the tool version.',
    );
}

void printUsage(ArgParser argParser) {
  print('Usage: genLocale <flags> [arguments]');
  print(argParser.usage);
}

Future<void> main(List<String> arguments) async {
  final ArgParser argParser = buildParser();
  try {
    final ArgResults results = argParser.parse(arguments);


    // Process the parsed arguments.
    if (results.wasParsed('help')) {
      printUsage(argParser);
      return;
    }
    if (results.wasParsed('version')) {
      PrintHelper().version();
      return;
    }
    if (results.wasParsed('verbose')) {
      PrintHelper().verbose = true;
    }


    // Act on the arguments provided.
    // print('Positional arguments: ${results.rest}');
    if (PrintHelper().verbose) {
      print('[VERBOSE] All arguments: ${results.arguments}');
    }

    final genLocale=GenLocaleStringLiteralFinder();
     // genLocale.init();
    await genLocale.run();
  } catch(e,s) {
    PrintHelper().progressFailed('$e\n$s');
    // Print usage information if an invalid argument was provided.
    printUsage(argParser);
  }
}
