import 'dart:io';

import 'package:gen_locale/src/file_manager.dart';
import 'package:gen_locale/src/models/string_data.dart';
import 'package:string_literal_finder/string_literal_finder.dart';

typedef PathToStringsMap = Map<String, List<StringData>>;

class TextMapBuilder extends FileManager {
  PathToStringsMap pathToStrings = {};

  /// generates a [StringData] object and add it to [pathToStrings] through file path
  addAString(FoundStringLiteral foundString) {
    if (_valueFromSource(foundString.stringLiteral.toSource()).isEmpty) return;
    final matched = _matchVariables(foundString.stringLiteral.toSource());
    StringData stringData = StringData(
        source: matched.$1,
        value: _valueFromSource(matched.$1),
        variables: matched.$2,
        withContext: _containsContext(foundString.filePath));
    if (pathToStrings[foundString.filePath] == null) {
      pathToStrings[foundString.filePath] = [stringData];
    } else {
      pathToStrings[foundString.filePath]!.add(stringData);
    }
    print(stringData);
  }

  String _valueFromSource(String source) {
    // if starts as a raw string
    if (source.startsWith("r'") || source.startsWith('r"')) {
      return source.replaceFirst("r'", '').replaceFirst('r"', '').replaceAll("'", '').replaceAll('"', '');
    }
    return source.replaceAll('\'', '').replaceAll('"', '');
  }

  /// Checks if file contains context
  /// just checks if one of material, cupertino or widgets libraries is imported
  bool _containsContext(String path) {
    final file = File(path);
    if (file.existsSync() == false) return false;
    final contents = file.readAsStringSync();
    if (contents.contains("import 'package:flutter/material.dart';") ||
        contents.contains("import 'package:flutter/cupertino.dart';") ||
        contents.contains("import 'package:flutter/widgets.dart';")) {
      return true;
    }
    return false;
  }

  /// Extracts variables within the source text
  /// returns source replaced all variables with {}
  /// and a list of string with all variables names with no invocation ($,${})
  (String replacedSource, List<String>? variables) _matchVariables(String source) {
    // skips no vars strings and raw strings
    if (source.contains('\$') == false || source.startsWith('r"') || source.startsWith("r'")) {
      return (source, null);
    }
    List<String> variables = [];
    // all matches for all variables
    final matches = RegExp(r"""\$\{?([a-zA-Z_][a-zA-Z0-9_\.]*)\}?""").allMatches(source);
    for (var match in matches) {
      String? matchString = match.group(0);
      print('matchString:$matchString');
      if (matchString == null) continue;
      variables.add(match.group(1) ?? matchString.replaceFirst("\${", "").replaceFirst("}", "").replaceFirst("\$", ""));
      source = source.replaceFirst(matchString, "{}");
    }
    return (source, variables.isEmpty ? null : variables);
  }
}
