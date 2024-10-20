import 'package:analyzer/dart/ast/ast.dart';
import 'package:gen_locale/src/models/string_data.dart';
import 'package:string_literal_finder/string_literal_finder.dart';

/// Builds A Set of StringData for generating LOCALE.JSON and REPLACING CODE BASE
abstract class FoundedStringsAnalayzer {
  SetOfStringData get setOfStringData;
  PathToStringData get pathToStringData;

  /// All Keys for ENUM GENERATION.
  Set<String> get keys;
  Map<String, dynamic> get jsonMap;

  /// Extracts variables within the source text
  /// returns source replaced all variables with {}
  /// and a list of string with all variables names with no invocation ($,${})

  /// generates a [StringData] object and add it to [setOfStringData] through file path
  /// foundString could be [FoundStringLiteral]
  void addAFoundStringLiteral(FoundStringLiteral foundString);
  void addAStringData(StringData foundString);
  void addAllStringData(Set<StringData> foundString);

  /// Removes Quotations from variables wither it's a raw string or a normal one

  /// Checks whether current string function should have context to insure reactivity.
  bool containsContext(AstNode? node);
}

typedef SetOfStringData = Set<StringData>;
typedef PathToStringData = Map<String, List<StringData>>;
