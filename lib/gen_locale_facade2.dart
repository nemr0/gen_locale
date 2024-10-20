import 'package:gen_locale/src/logger/print_helper.dart';
import 'package:gen_locale/src/models/found_strings_analyzer_abs.dart';
import 'package:gen_locale/src/models/gen_locale_abstract.dart';
import 'package:gen_locale/src/models/string_data.dart';
import 'package:string_literal_finder/string_literal_finder.dart' as slf;

import 'src/models/exclude_path_checker_impl/exclude_path_that_contains.dart';
import 'src/models/exclude_path_checker_impl/include_only_dart_files.dart';

class GenLocaleFacade extends GenLocale {
  // declare all classes responsible for different main proccessing
  late final PrintHelper _printHelper;
  late final FoundedStringsAnalayzer _foundedStringsAnalyzer;
  late final Set<StringData> _setOfStringData;
  late final String _basePath;
  late final List<slf.ExcludePathChecker> _excludesList;
  late final slf.StringLiteralFinder _finder;

  void initFinder() => _finder =
      slf.StringLiteralFinder(basePath: _basePath, excludePaths: _excludesList);

  initExcludes(List<String> excludeStrings) {
    _excludesList = [
      slf.ExcludePathChecker.excludePathCheckerEndsWith('_test.dart'),
      IncludeOnlyDartFiles(),
      ...slf.ExcludePathChecker.excludePathDefaults,
      ...excludeStrings.map<ExcludePathThatContains>(
          (e) => ExcludePathThatContains(contains: e)),
    ];
  }

  @override
  Future<void> run() async {
    print('');
  }
}
