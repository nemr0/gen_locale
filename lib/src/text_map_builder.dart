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

  addAString(FoundStringLiteral foundString) {
    String stringValue = foundString.stringValue == null
        ? foundString.stringLiteral.toSource().replaceAll('\'', '').replaceAll('"', '')
        : foundString.stringValue!;
      if (pathToStrings[foundString.filePath] == null) {
        pathToStrings[foundString.filePath] = [(foundString.stringLiteral.toSource(), stringValue)];
      } else {
        pathToStrings[foundString.filePath]!
            .add((foundString.stringLiteral.toSource(), stringValue));
      }
    print(foundString.stringLiteral.toSource());
    print(stringValue);
  }
}
