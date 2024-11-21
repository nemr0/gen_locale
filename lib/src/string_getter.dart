import 'dart:isolate';

import 'package:gen_locale/src/found_strings_analyzer.dart';
import 'package:string_literal_finder/string_literal_finder.dart';

import 'logger/print_helper.dart';
import 'models/exclude_path_checker_impl/exclude_path_that_contains.dart';
import 'models/exclude_path_checker_impl/include_only_dart_files.dart';

class StringsGetter {
  final PrintHelper printHelper;

  StringsGetter(this.printHelper);

  Future<List<Map<String, dynamic>>> run(String basePath) async {
    List<String> userExcludes = printHelper.getUserExcludes();

    List<Map<String, dynamic>> data = await Isolate.run(() async {
      // all rescources needs to be intialized inside isolate
      final FoundedStringsAnalyzerImpl localAnalyzer =
          FoundedStringsAnalyzerImpl();

      // Create a new StringLiteralFinder instance within the isolate
      final StringLiteralFinder localFinder = StringLiteralFinder(
        basePath: basePath,
        excludePaths: [
          ExcludePathChecker.excludePathCheckerEndsWith('_test.dart'),
          IncludeOnlyDartFiles(),
          ...ExcludePathChecker.excludePathDefaults,
          ...userExcludes.map((e) => ExcludePathThatContains(contains: e)),
        ],
      );

      // Perform the string literal finding
      List<FoundStringLiteral> foundStrings = await localFinder.start();
      for (var found in foundStrings) {
        localAnalyzer.addAFoundStringLiteral(found);
      }

      // Return serializable data from the isolate
      return localAnalyzer.setOfStringData.map((e) => e.toMap()).toList();
    });

    return data;
  }
}
