import 'package:analyzer/dart/ast/ast.dart';
import 'package:gen_locale/src/models/string_data.dart';
import 'package:gen_locale/src/models/text_map_builder.dart';
import 'package:string_literal_finder/string_literal_finder.dart';

class FoundedStringsAnalyzer {
  SetOfStringData get setOfStringData => _setOfStringData;

  PathToStringData get pathToStringData => _pathToString;

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

  String _getKeyFor(String filePath, String source) {
    // {file_name}_{index}
    String key =
        '${filePath.split('/').last.split('.').first}_${_pathToString[filePath]?.length ?? 0}';
    // if key exists this wont be empty:
    final keyExistsList =
        _setOfStringData.where((element) => element.key == key);
    if (keyExistsList.isNotEmpty) {
      if (keyExistsList.first.source == source) {
        return key;
      }
      // recursive to paths
      key = _getKeyFor(key, source);
    }
    return key;
  }

  void addAFoundStringLiteral(FoundStringLiteral foundString) {
    Set<String> filesPath = {foundString.filePath};
    String source = foundString.stringLiteral.toSource();
    if (valueFromSource(source).isEmpty) return;
    final withSamePathAndSource = setOfStringData.where((element) =>
        element.filesPath.contains(foundString.filePath) &&
        element.source == source);

    final withSameSource = setOfStringData.where((e) => e.source == source);
    if (withSamePathAndSource.isNotEmpty) return;
    if (withSameSource.isNotEmpty) {
      for (StringData data in withSameSource) {
        filesPath.addAll(data.filesPath);
      }
    }
    final matched = matchVariables(source);

    StringData stringData = StringData(
        source: source,
        value: valueFromSource(matched.$1),
        variables: matched.$2,
        withContext: containsContext(foundString.stringLiteral.parent),
        filesPath: filesPath,
        key: _getKeyFor(foundString.filePath, source));
    addAStringData(stringData);
  }

  String valueFromSource(String source) {
    // if starts as a raw string
    if (source.startsWith("r'") || source.startsWith('r"')) {
      return source
          .replaceFirst("r'", '')
          .replaceFirst('r"', '')
          .replaceAll("'", '')
          .replaceAll('"', '');
    }
    return source.replaceAll('\'', '').replaceAll('"', '');
  }

  bool containsContext(AstNode? node) {
    AstNode? parent = node?.parent;
    while (parent != null) {
      if (parent is MethodDeclaration &&
          parent.parameters?.parameters != null &&
          parent.parameters!.parameters.isNotEmpty) {
        MethodDeclaration method = parent;
        // Check if any of the parameters is of type 'BuildContext'
        bool canAccessContext = method.parameters!.parameters.any((param) {
          TypeAnnotation? paramType;

          if (param is SimpleFormalParameter) {
            paramType = param.type;
          } else if (param is DefaultFormalParameter) {
            // For parameters with default values
            var innerParam = param.parameter;
            if (innerParam is SimpleFormalParameter) {
              paramType = innerParam.type;
            }
          }

          String? typeName = paramType?.toSource();

          // Remove any prefixes (e.g., 'ui.BuildContext')
          String? unprefixedTypeName = typeName?.split('.').last;

          return unprefixedTypeName == 'BuildContext';
        });

        return canAccessContext;
      }
      parent = parent.parent;
    }
    return false;
  }

  (String replacedSource, List<String>? variables) matchVariables(
      String source) {
    // skips no vars strings and raw strings
    if (source.contains('\$') == false ||
        source.startsWith('r"') ||
        source.startsWith("r'")) {
      return (source, null);
    }
    List<String> variables = [];
    // all matches for all variables
    final matches = RegExp(r"""(?<!\\)\$\{?([a-zA-Z_][a-zA-Z0-9_\.]*)\}?""")
        .allMatches(source);
    for (var match in matches) {
      String? matchString = match.group(0);
      if (matchString == null) continue;
      variables.add(match.group(1) ??
          matchString
              .replaceFirst("\${", "")
              .replaceFirst("}", "")
              .replaceFirst("\$", ""));
      source = source.replaceFirst(matchString, "{}");
    }
    return (source, variables.isEmpty ? null : variables);
  }

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

  Set<String> get keys => _setOfStringData.map((e) => e.key).toSet();

  Map<String, dynamic> get jsonMap => Map<String, dynamic>.fromEntries(
      _setOfStringData.map((e) => MapEntry(e.key, e.value)));

  void addAllStringData(Set<StringData> foundString) {
    for (StringData data in foundString) {
      addAStringData(data);
    }
  }
}
