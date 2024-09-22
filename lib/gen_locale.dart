import 'package:gen_locale/src/stack_exception.dart';
import 'package:gen_locale/src/text_map_builder.dart';
import 'package:gen_locale/src/logger/print_helper.dart';
import 'package:string_literal_finder/string_literal_finder.dart' as slf;

class GenLocale {
  final String basePath;
  late final slf.StringLiteralFinder finder;
  final bool verbose = PrintHelper().verbose;
  late final TextMapBuilder textMapBuilder;
  late final List<slf.ExcludePathChecker>? excludes;
  PathToStringsMap get pathToStringsMap => textMapBuilder.pathToStrings;
  int lengthOfFoundStrings = 0;

  initFinder() => finder = slf.StringLiteralFinder(basePath: basePath, excludePaths:excludes?? [
    slf.ExcludePathChecker.excludePathCheckerEndsWith('_test.dart'),
    IncludeOnlyDartFiles(),
    ...slf.ExcludePathChecker.excludePathDefaults
  ]);

  GenLocale(this.basePath, {this.excludes}) {
    initFinder();
    textMapBuilder = TextMapBuilder();
  }

  Future<void> analyzeProject() async {
    try {
      List<slf.FoundStringLiteral> foundStringLiteral = await finder.start();
      for (slf.FoundStringLiteral foundString in foundStringLiteral) {
        textMapBuilder.addAString(foundString);
      }
      lengthOfFoundStrings = foundStringLiteral.length;
    } catch (e, s) {
      print(e);
      print(s);
      throw (StackException(message: 'Couldn\'t Start Dart Server', stack: '$e\n$s'));
    }
  }

  Future<void> getStrings() async {
    try {
      PrintHelper().addProgress('Analyzing Project (this could take time)');
      await analyzeProject();
      PrintHelper()
          .addProgress('Fetched Strings: $lengthOfFoundStrings Files: ${TextMapBuilder().pathToStrings.length}');
    } on StackException catch (e) {
      PrintHelper().failed(e.message);
      if (verbose) {
        print(e.stack);
      }
    }
  }
}

class IncludeOnlyDartFiles extends slf.ExcludePathChecker {
  @override
  bool shouldExclude(String path) {
    return path.endsWith('.dart') == false;
  }
}
