import 'package:gen_locale/src/file_manager.dart';
import 'package:gen_locale/src/models/string_data.dart';
import 'package:gen_locale/src/models/text_map_builder.dart';
import 'package:string_literal_finder/string_literal_finder.dart';

class TextMapBuilderStringLiteral extends TextMapBuilder {
  @override
  SetOfStringData get setOfStringData => _setOfStringData;

  final SetOfStringData _setOfStringData = {};
  final PathToStringData _pathToString = {};



  _addToPathToStringsMap(StringData data) {
    for (String path in data.filesPath) {
      if (_pathToString[path] == null) {
        _pathToString[path] = [data];
      } else {
        _pathToString[path]!.add(data);
      }
    }
  }
  String _getKeyFor(String filePath){
    // {file_name}-{index}
    String key= '${filePath.split('/').last.split('.').first}-${_pathToString[filePath]?.length??0}';
    // if key exists
    if(_setOfStringData.where((element) => element.key==key).isNotEmpty){
      // recursive to paths
      key = _getKeyFor(key);
    }
    print(key);
      return key;

  }

  @override
  void addAString(var foundString) {
    if (foundString is! FoundStringLiteral?) {
      throw ('Error: FoundString is not FoundStringLiteral');
    }
    if (foundString == null) return ;
    String source = foundString.stringLiteral.toSource();
    if (valueFromSource(source).isEmpty) return ;
    final matched = matchVariables(source);
    StringData stringData = StringData(
        source: source,
        value: valueFromSource(matched.$1),
        variables: matched.$2,
        withContext: containsContext(foundString.filePath),
        filesPath: [foundString.filePath], key: _getKeyFor(foundString.filePath));
    addAStringData(stringData);
  }

  @override
  String valueFromSource(String source) {
    // if starts as a raw string
    if (source.startsWith("r'") || source.startsWith('r"')) {
      return source.replaceFirst("r'", '').replaceFirst('r"', '').replaceAll("'", '').replaceAll('"', '');
    }
    return source.replaceAll('\'', '').replaceAll('"', '');
  }

  @override
  bool containsContext(String path) {
    if (!FileManager.fileExists(path)) return false;
    return RegExp(r'''import\s*['"](package:flutter\/(widgets|cupertino|material)\.dart)['"]\s*;''')
        .hasMatch(FileManager.getContents(path));
  }

  @override
  (String replacedSource, List<String>? variables) matchVariables(String source) {
    // skips no vars strings and raw strings
    if (source.contains('\$') == false || source.startsWith('r"') || source.startsWith("r'")) {
      return (source, null);
    }
    List<String> variables = [];
    // all matches for all variables
    final matches = RegExp(r"""\$\{?([a-zA-Z_][a-zA-Z0-9_\.]*)\}?""").allMatches(source);
    for (var match in matches) {
      String? matchString = match.group(0);
      if (matchString == null) continue;
      variables.add(match.group(1) ?? matchString.replaceFirst("\${", "").replaceFirst("}", "").replaceFirst("\$", ""));
      source = source.replaceFirst(matchString, "{}");
    }
    return (source, variables.isEmpty ? null : variables);
  }

  @override
  void addAStringData(StringData foundString) {
    _setOfStringData.removeWhere((element) {
      if (element.source == foundString.source) {
        foundString.filesPath.addAll(element.filesPath);
        return true;
      } else {
        return false;
      }
    });
    _addToPathToStringsMap(foundString);
    _setOfStringData.add(foundString);

  }

  @override
  Set<String> get keys => _setOfStringData.map((e)=>e.key).toSet();

  @override
  PathToStringData get pathToStringData => _pathToString;

  @override
  void addAllStringData(Set<StringData> foundString) {
    for(StringData data in foundString){
      addAStringData(data);
    }
  }
}
