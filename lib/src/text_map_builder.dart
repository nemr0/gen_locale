import 'package:generate_localization_file/src/file_manager.dart';
import 'package:string_literal_finder/string_literal_finder.dart';

typedef PathToSourceMap = Map<String, List<(String source, String value)>>;

class TextMapBuilder extends FileManager {
  factory TextMapBuilder() {
    return _textMapBuilder;
  }

  static final TextMapBuilder _textMapBuilder = TextMapBuilder._internal();

  TextMapBuilder._internal();

  PathToSourceMap pathToStrings = {};

  Iterable<String>? getSourcesOrValues(String path, {bool source = true}) =>
      pathToStrings[path]?.map((e) => source ? e.$1 : e.$2);

  addAString(FoundStringLiteral s) {
    String stringValue = s.stringValue == null
        ? s.stringLiteral.toSource().replaceAll('\'', '').replaceAll('"', '')
        : s.stringValue!;

    if (pathToStrings[s.filePath] == null) {
      if (s.stringValue != null) {
        pathToStrings[s.filePath] = [(s.stringLiteral.toSource(), stringValue)];
      }
    } else {
      if (s.stringValue != null) {
        pathToStrings[s.filePath]!
            .add((s.stringLiteral.toSource(), stringValue));
      }
    }
    print(s.stringLiteral.toSource());
    print(stringValue);
  }
}
