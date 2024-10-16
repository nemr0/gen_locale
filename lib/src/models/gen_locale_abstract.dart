import 'package:gen_locale/src/models/text_map_builder.dart';
import 'package:string_literal_finder/string_literal_finder.dart' as slf;

abstract class GenLocaleAbs {
  late final String basePath;
  late final TextMapBuilder textMapBuilder;
  late final List<slf.ExcludePathChecker> excludes;
  Future<void> run();
}