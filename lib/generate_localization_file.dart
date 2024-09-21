import 'package:generate_localization_file/src/stack_exception.dart';
import 'package:generate_localization_file/src/text_map_builder.dart';
import 'package:generate_localization_file/src/logger/print_helper.dart';
import 'package:string_literal_finder/string_literal_finder.dart' as slf;

typedef PathToSourceMap = Map<String, List<(String source, String value)>>;

class GenerateLocalizationFile {
  final String basePath;
  late final slf.StringLiteralFinder finder;
  PathToSourceMap mapFileToListStrings = {};
  final bool verbose = PrintHelper().verbose;
  int lengthOfFoundStrings = 0;

  GenerateLocalizationFile(this.basePath) {
    DateTime now = DateTime.now();
    finder = slf.StringLiteralFinder(basePath: basePath, excludePaths: [
      slf.ExcludePathChecker.excludePathCheckerEndsWith('_test.dart'),
      IncludeOnlyDartFiles(),
      ...slf.ExcludePathChecker.excludePathDefaults
    ]);
    print(DateTime.now().difference(now).inMilliseconds);
  }

  Future<void> analyzeProject() async {
    try {
      List<slf.FoundStringLiteral> foundStringLiteral = await finder.start();
      for (slf.FoundStringLiteral foundString in foundStringLiteral) {
        TextMapBuilder().addAString(foundString);
      }
      lengthOfFoundStrings = foundStringLiteral.length;
    } catch (e, s) {
      throw (StackException(
          message: 'Couldn\'t Start Dart Server', stack: '$e\n$s'));
    }
  }

  Future<void> getStrings() async {
    try {
      PrintHelper().addProgress('Analyzing Project (this could take time)');
      await analyzeProject();
      PrintHelper().addProgress(
          'Fetched Strings: $lengthOfFoundStrings Files: ${TextMapBuilder().pathToStrings.length}');
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
