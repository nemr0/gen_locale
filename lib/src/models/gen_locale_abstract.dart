import 'package:gen_locale/src/models/found_strings_analyzer_abs.dart';
import 'package:string_literal_finder/string_literal_finder.dart' as slf;

import '../found_strings_analyzer.dart';

abstract class GenLocale {
  late final String basePath;
  late final FoundedStringsAnalayzer foundedStringsAnalyzer;
  late final List<slf.ExcludePathChecker> excludes;
  Future<void> run();
}
