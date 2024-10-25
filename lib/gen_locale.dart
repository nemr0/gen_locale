import 'dart:io';

import 'package:gen_locale/src/file_manager.dart';
import 'package:gen_locale/src/generate_enum_from_keys.dart';
import 'package:gen_locale/src/generate_json_map.dart';
import 'package:gen_locale/src/logger/exceptions.dart';
import 'package:gen_locale/src/models/gen_locale_abstract.dart';
import 'package:gen_locale/src/models/string_data.dart';
import 'package:gen_locale/src/models/text_map_builder.dart';
import 'package:gen_locale/src/stack_exception.dart';
import 'package:gen_locale/src/found_strings_analyzer.dart';
import 'package:gen_locale/src/logger/print_helper.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

class GenLocaleStringLiteralFinder extends GenLocaleAbs {
  final bool verbose = PrintHelper().verbose;

  /// A Map of File Path as a key with value of List of [StringData]
  /// Used For Replacing texts file by file.
  SetOfStringData get setOfStringData => foundedStringsAnalyzer.setOfStringData;
  int lengthOfFoundStrings = 0;
  late GenerateEnumFromKeys generateEnumFromKeys;




  GenLocaleStringLiteralFinder({required super.stringProcessor, required super.stringsGetter});

  // TODO: Needs to be added back with Replacing logic.
  // late final bool replaceCodeBase;

  // _getReplaceCodeBase() {
  //   replaceCodeBase =
  //       PrintHelper().chooseOne<bool>('Do you want to replace all strings in your code base?', [true, false], false);
  // }

  String _getBaseUri() {
    String base = PrintHelper().prompt(
        'Enter Project Path... (default to current)', Directory.current.path,
        skipFlush: true);

    base = stringProcessor.pointersToPathWithMimeType(
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


  Future<void> _analyzeProject() async {
    try {
      basePath = _getBaseUri();
      PrintHelper().addProgress('Analyzing Project');
      foundedStringsAnalyzer = FoundedStringsAnalyzer(stringProcessor: stringProcessor);
      await stringsGetter.run(basePath,foundedStringsAnalyzer);
      lengthOfFoundStrings = foundedStringsAnalyzer.setOfStringData.length;

      PrintHelper().completeProgress();

      PrintHelper().print(
          'Fetched Strings: $lengthOfFoundStrings Files: ${foundedStringsAnalyzer.pathToStringData.keys.length}',
          style: styleBold,
          color: cyan,
          addToMessages: true);
    } catch (e, s) {
      throw (StackException(message: Exceptions.couldNotStartDartServer, stack: '$e\n$s'));
    }
  }

  void _generateJsonFile([bool notFirstRun = false]) {
    try {
      String jsonPath = PrintHelper().prompt(
        'Where do you want to save your JSON file?',
        p.join(basePath, 'RESOURCES.json'),
      );
      jsonPath = stringProcessor.pointersToPathWithMimeType(jsonPath, mimeType: 'json');
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

      throw (StackException(
          message: Exceptions.couldNotStartDartServer, stack: '$e\n$s'));
    }
  }

  void _generateEnumAndExtension([bool notFirstRun = false]) {
    String filePath = PrintHelper().prompt(
      'Where do you want to save your Generated Enums?',
      '$basePath/lib/generated/keys.dart',
    );
    filePath = stringProcessor.pointersToPathWithMimeType(filePath, mimeType: 'dart');
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
    PrintHelper().version();
    await _analyzeProject();
    _generateJsonFile();
    _generateEnumAndExtension();
  }
}
