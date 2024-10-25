import 'dart:isolate';

import 'package:gen_locale/src/found_strings_analyzer.dart';
import 'package:gen_locale/src/logger/print_helper.dart';
import 'package:gen_locale/src/models/exclude_path_checker_impl/exclude_path_that_contains.dart';
import 'package:gen_locale/src/models/exclude_path_checker_impl/include_only_dart_files.dart';
import 'package:gen_locale/src/models/string_data.dart';
import 'package:string_literal_finder/string_literal_finder.dart';

class StringsGetter {
  late final StringLiteralFinder _finder;
/// runs dart analyzer in isolate gets [FoundedStringLiteral] and add it to [FoundedStringsAnalyzer.setOfStringData]
 Future<FoundedStringsAnalyzer> run(String basePath, FoundedStringsAnalyzer foundedStringsAnalyzer) async {
    List<String> userExcludes = _getUserExcludes();

    List<Map<String, dynamic>> data = await Isolate.run(() async {
      _finder = StringLiteralFinder(basePath: basePath, excludePaths: [
        ExcludePathChecker.excludePathCheckerEndsWith('_test.dart'),
        IncludeOnlyDartFiles(),
        ...ExcludePathChecker.excludePathDefaults,
        ...userExcludes.map<ExcludePathThatContains>((e) => ExcludePathThatContains(contains: e)),
      ]);
      for (var found in (await _finder.start())) {
        foundedStringsAnalyzer.addAFoundStringLiteral(found);
      }
      return foundedStringsAnalyzer.setOfStringData.map((e) => e.toMap()).toList();
    });
    Set<StringData> dataSet = data.map((e) => StringData.fromJson(e)).toSet();
    foundedStringsAnalyzer.addAllStringData(dataSet);
    return foundedStringsAnalyzer;
  }

  List<String> _getUserExcludes() => PrintHelper().promptAny('excludes: to exclude files with specific path. for example: "presentation,business" excludes all paths that contain presentation or business');
}
