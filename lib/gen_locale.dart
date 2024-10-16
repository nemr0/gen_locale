import 'dart:io';
import 'dart:isolate';

import 'package:gen_locale/src/file_manager.dart';
import 'package:gen_locale/src/generate_enum_from_keys.dart';
import 'package:gen_locale/src/generate_json_map.dart';
import 'package:gen_locale/src/logger/exceptions.dart';
import 'package:gen_locale/src/models/exclude_path_checker_impl/exclude_path_that_contains.dart';
import 'package:gen_locale/src/models/exclude_path_checker_impl/include_only_dart_files.dart';
import 'package:gen_locale/src/models/gen_locale_abstract.dart';
import 'package:gen_locale/src/models/string_data.dart';
import 'package:gen_locale/src/models/text_map_builder.dart';
import 'package:gen_locale/src/stack_exception.dart';
import 'package:gen_locale/src/text_map_builder.dart';
import 'package:gen_locale/src/logger/print_helper.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:string_literal_finder/string_literal_finder.dart' as slf;
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

class GenLocaleStringLiteralFinder extends GenLocaleAbs {
  final bool verbose = PrintHelper().verbose;

  /// A Map of File Path as a key with value of List of [StringData]
  /// Used For Replacing texts file by file.

  SetOfStringData get setOfStringData => foundedStringsAnalyzer.setOfStringData;
  int lengthOfFoundStrings = 0;
  late GenerateEnumFromKeys generateEnumFromKeys;

  initFinder() => finder =
      slf.StringLiteralFinder(basePath: basePath, excludePaths: excludes);

  late final slf.StringLiteralFinder finder;

  initExcludes(List<String> excludeStrings) {
    excludes = [
      slf.ExcludePathChecker.excludePathCheckerEndsWith('_test.dart'),
      IncludeOnlyDartFiles(),
      ...slf.ExcludePathChecker.excludePathDefaults,
      ...excludeStrings.map<ExcludePathThatContains>(
          (e) => ExcludePathThatContains(contains: e)),
    ];
  }

  GenLocaleStringLiteralFinder() {
    PrintHelper().version();

    // _getReplaceCodeBase();
  }
  String _pointersToPathWithMimeType(String path, {String? mimeType}) {
    if (path.startsWith('./') || path == '.') {
      path = path.replaceFirst('.', Directory.current.path);
    } else if (path.startsWith('../') || path == '..') {
      path = path.replaceFirst('..', Directory.current.parent.path);
    }
    if (mimeType != null && path.split('/').last.split('.').last != mimeType) {
      path = '$path.$mimeType';
    }
    return path;
  }

  late final bool replaceCodeBase;

  // _getReplaceCodeBase() {
  //   replaceCodeBase =
  //       PrintHelper().chooseOne<bool>('Do you want to replace all strings in your code base?', [true, false], false);
  // }

  String _getBaseUri() {
    String base = PrintHelper().prompt(
        'Enter Project Path... (default to current)', Directory.current.path,
        skipFlush: true);

    base = _pointersToPathWithMimeType(
      base,
    );
    if (!FileManager.directoryExists(base)) {
      PrintHelper().print('Couldn\'t find Directory', color: red);
      return _getBaseUri();
    }
    String pubspecPath = p.join(base, 'pubspec.yaml');
    if (!FileManager.fileExists(pubspecPath)) {
      PrintHelper()
          .print('Not a Flutter project: pubspec.yaml not found..', color: red);
      return _getBaseUri();
    }
    final pubspec = loadYaml(File(pubspecPath).readAsStringSync());
    final dependencies = pubspec['dependencies'] as Map?;
    PrintHelper().packageName = pubspec['name'];
    if (dependencies == null || !dependencies.containsKey('flutter')) {
      PrintHelper().print(
          'Not a Flutter project: flutter dependency not found.',
          color: red);
      return _getBaseUri();
    }
    PrintHelper().print('Chosen Path: $base',
        color: cyan, style: styleBold, flushAndRewrite: true);
    return base;
  }

  List<String> _getUserExcludes() => PrintHelper().promptAny(
      'excludes: to exclude files with specific path. for example: "presentation,business" excludes all paths that contain presentation or business');

  Future<void> _analyzeProject() async {
    try {
      basePath = _getBaseUri();
      initExcludes(_getUserExcludes());
      PrintHelper().addProgress('Analyzing Project');
      initFinder();
      foundedStringsAnalyzer = FoundedStringsAnalyzer();
      List<Map<String, dynamic>> data = await Isolate.run(() async {
        List<slf.FoundStringLiteral> a = await finder.start();
        for (var found in a) {
          foundedStringsAnalyzer.addAFoundStringLiteral(found);
        }
        return setOfStringData.map((e) => e.toMap()).toList();
      });
      Set<StringData> dataSet = data.map((e) => StringData.fromJson(e)).toSet();
      foundedStringsAnalyzer.addAllStringData(dataSet);
      lengthOfFoundStrings = dataSet.length;
      if (verbose) {
        PrintHelper().print(setOfStringData.toString());
        print('--------------------------------------------');
      }
      PrintHelper().completeProgress();

      PrintHelper().print(
          'Fetched Strings: $lengthOfFoundStrings Files: ${foundedStringsAnalyzer.pathToStringData.keys.length}',
          style: styleBold,
          color: cyan,
          addToMessages: true);
    } catch (e, s) {
      if (verbose) {
        PrintHelper().print(e.toString());
        PrintHelper().print(s.toString());
      }
      throw (StackException(
          message: Exceptions.couldNotStartDartServer, stack: '$e\n$s'));
    }
  }

  _generateJsonFile([bool notFirstRun = false]) {
    try {
      String jsonPath = PrintHelper().prompt(
        'Where do you want to save your JSON file?',
        p.join(basePath, 'RESOURCES.json'),
      );
      jsonPath = _pointersToPathWithMimeType(jsonPath, mimeType: 'json');
      PrintHelper().addProgress('Generating JSON File');

      JsonMap.generateJsonFileFromMap(jsonPath, foundedStringsAnalyzer.jsonMap);
      if (notFirstRun == false) PrintHelper().completeProgress();
    } on FileSystemException catch (e, s) {
      if (verbose) {
        PrintHelper().print(e.toString());
        PrintHelper().print(s.toString());
      }
      return _generateJsonFile(true);
    } catch (e, s) {
      if (verbose) {
        PrintHelper().print(e.toString());
        PrintHelper().print(s.toString());
      }
      throw (StackException(
          message: Exceptions.couldNotStartDartServer, stack: '$e\n$s'));
    }
  }

  _generateEnumAndExtension([bool notFirstRun = false]) {
    String filePath = PrintHelper().prompt(
      'Where do you want to save your Generated Enums?',
      '$basePath/lib/generated/keys.dart',
    );
    filePath = _pointersToPathWithMimeType(filePath, mimeType: 'dart');
    if (!notFirstRun) PrintHelper().addProgress('Generating ENUM KEYS File');
    generateEnumFromKeys =
        GenerateEnumFromKeys(keys: foundedStringsAnalyzer.keys);
    String generatedEnumAndExtension = generateEnumFromKeys.generateEnum();
    try {
      FileManager.writeFile(filePath, generatedEnumAndExtension);
    } catch (e, s) {
      if (verbose) {
        PrintHelper().print(e.toString());
        PrintHelper().print(s.toString());
      }
      return _generateEnumAndExtension(true);
    }
    PrintHelper().completeProgress();
  }

  @override
  Future<void> run() async {
    await _analyzeProject();
    _generateJsonFile();
    _generateEnumAndExtension();
  }
}
