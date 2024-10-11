
import 'package:gen_locale/src/models/string_data.dart';
/// Builds A Set of StringData for generating LOCALE.JSON and REPLACING CODE BASE
abstract class TextMapBuilder {
  SetOfStringData get setOfStringData;
  PathToStringData get pathToStringData;
  /// All Keys for ENUM GENERATION.
  Set<String> get keys;
  /// Extracts variables within the source text
  /// returns source replaced all variables with {}
  /// and a list of string with all variables names with no invocation ($,${})
  (String replacedSource, List<String>? variables) matchVariables(String source);
  /// generates a [StringData] object and add it to [setOfStringData] through file path
  /// foundString could be [FoundStringLiteral]
  void addAString(var foundString);
  void addAStringData(StringData foundString);
  void addAllStringData(Set<StringData> foundString);
  /// Removes Quotations from variables wither it's a raw string or a normal one
  String valueFromSource(String source);
  /// Checks whether current string function should have context to insure reactivity.
  bool containsContext(String path);
}

typedef SetOfStringData = Set<StringData>;
typedef PathToStringData = Map<String,List<StringData>>;
