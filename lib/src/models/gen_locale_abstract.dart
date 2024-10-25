import 'package:gen_locale/src/string_processor.dart';
import 'package:gen_locale/src/strings_getter.dart';
import 'package:string_literal_finder/string_literal_finder.dart' as slf;

import '../found_strings_analyzer.dart';

abstract class GenLocaleAbs {
  late final String basePath;
  late final FoundedStringsAnalyzer foundedStringsAnalyzer;
   final StringsGetter stringsGetter;
  late final List<slf.ExcludePathChecker> excludes;
  final StringProcessor stringProcessor;

  GenLocaleAbs( {required this.stringsGetter, required this.stringProcessor});
  Future<void> run();
}
