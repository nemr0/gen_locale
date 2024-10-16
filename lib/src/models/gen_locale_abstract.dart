import 'package:string_literal_finder/string_literal_finder.dart' as slf;

import '../text_map_builder.dart';

abstract class GenLocaleAbs {
  late final String basePath;
  late final FoundedStringsAnalyzer foundedStringsAnalyzer;
  late final List<slf.ExcludePathChecker> excludes;
  Future<void> run();
}
