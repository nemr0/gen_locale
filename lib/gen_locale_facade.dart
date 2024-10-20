import 'dart:isolate';

import 'package:analyzer/file_system/file_system.dart';
import 'package:gen_locale/src/found_strings_analyzer.dart';
import 'package:gen_locale/src/logger/print_helper.dart';
import 'package:gen_locale/src/models/exceptions/generation_exception.dart';
import 'package:gen_locale/src/models/exceptions/intialization_exception.dart';

import 'package:gen_locale/src/models/found_strings_analyzer_abs.dart';
import 'package:gen_locale/src/models/gen_locale_abstract.dart';
import 'package:gen_locale/src/models/string_data.dart';
import 'package:mason_logger/mason_logger.dart';

import 'package:string_literal_finder/string_literal_finder.dart' as slf;
import 'package:path/path.dart' as p;

import 'src/file_manager.dart';
import 'src/generate_enum_from_keys.dart';
import 'src/generate_json_map.dart';
import 'src/logger/exceptions.dart';
import 'src/models/exceptions/stack_exception.dart';
import 'src/models/exclude_path_checker_impl/exclude_path_that_contains.dart';
import 'src/models/exclude_path_checker_impl/include_only_dart_files.dart';
import 'src/string_processor.dart';

class GenLocaleFacade extends GenLocale {
  // declare all classes responsible for different main proccessing
  late final PrintHelper _printHelper;
  late final FoundedStringsAnalayzer _foundedStringsAnalyzer;

  late final String _basePath;
  late final List<slf.ExcludePathChecker> _excludesList;
  late final slf.StringLiteralFinder _finder;
  late final bool _verbose;

  GenLocaleFacade() {
    // intialize all classes
    _printHelper = _printHelper;
    _foundedStringsAnalyzer = FoundedStringsAnalyzerImpl();
    _verbose = _printHelper.verbose;
  }

  void _initFinder() => _finder =
      slf.StringLiteralFinder(basePath: _basePath, excludePaths: _excludesList);

  void _initExcludes(List<String> excludeStrings) {
    _excludesList = [
      slf.ExcludePathChecker.excludePathCheckerEndsWith('_test.dart'),
      IncludeOnlyDartFiles(),
      ...slf.ExcludePathChecker.excludePathDefaults,
      ...excludeStrings.map<ExcludePathThatContains>(
          (e) => ExcludePathThatContains(contains: e)),
    ];
  }

  void _intialize() {
    try {
      // get base path
      _basePath = _printHelper.getBaseUri();
      // get excludes files prompted from user
      _initExcludes(_printHelper.getUserExcludes());
      //add progress
      _printHelper.addProgress('Analyzing Project');
      // intialize finder after getting base path and list of excludes files
      _initFinder();
    } catch (e, s) {
      throw (IntializationException(
          message: Exceptions.couldNotIntializeFinder, stack: '$e\n$s'));
    }
  }

  Future<void> _analyzeProject() async {
    try {
      List<Map<String, dynamic>> data = await Isolate.run(() async {
        List<slf.FoundStringLiteral> a = await _finder.start();
        for (var found in a) {
          _foundedStringsAnalyzer.addAFoundStringLiteral(found);
        }
        return _foundedStringsAnalyzer.setOfStringData
            .map((e) => e.toMap())
            .toList();
      });
      Set<StringData> dataSet = data.map((e) => StringData.fromJson(e)).toSet();
      _foundedStringsAnalyzer.addAllStringData(dataSet);

      if (_verbose) {
        _printHelper.print(_foundedStringsAnalyzer.setOfStringData.toString());
        print('--------------------------------------------');
      }
      _printHelper.completeProgress();

      _printHelper.print(
          'Fetched Strings: ${dataSet.length} Files: ${_foundedStringsAnalyzer.pathToStringData.keys.length}',
          style: styleBold,
          color: cyan,
          addToMessages: true);
    } catch (e, s) {
      if (_verbose) {
        _printHelper.print(e.toString());
        _printHelper.print(s.toString());
      }
      throw (StackException(
          message: Exceptions.couldNotStartDartServer, stack: '$e\n$s'));
    }
  }

  void _generateJsonFile([bool notFirstRun = false]) {
    try {
      String jsonPath = _printHelper.prompt(
        'Where do you want to save your JSON file?',
        p.join(_basePath, 'RESOURCES.json'),
      );
      jsonPath = StringProcessor.pointersToPathWithMimeType(jsonPath,
          mimeType: 'json');
      _printHelper.addProgress('Generating JSON File');

      JsonMap.generateJsonFileFromMap(
          jsonPath, _foundedStringsAnalyzer.jsonMap);
      if (notFirstRun == false) _printHelper.completeProgress();
    } on FileSystemException catch (e, s) {
      if (_verbose) {
        _printHelper.print(e.toString());
        _printHelper.print(s.toString());
      }
      return _generateJsonFile(true);
    } catch (e, s) {
      if (_verbose) {
        _printHelper.print(e.toString());
        _printHelper.print(s.toString());
      }
      throw (GenerationException(
          message: Exceptions.couldNotGenerateJsonFile, stack: '$e\n$s'));
    }
  }

  void _generateEnumAndExtension([bool notFirstRun = false]) {
    String filePath = _printHelper.prompt(
      'Where do you want to save your Generated Enums?',
      '$basePath/lib/generated/keys.dart',
    );
    filePath =
        StringProcessor.pointersToPathWithMimeType(filePath, mimeType: 'dart');
    if (!notFirstRun) _printHelper.addProgress('Generating ENUM KEYS File');
    final generateEnumFromKeys =
        GenerateEnumFromKeys(keys: _foundedStringsAnalyzer.keys);
    String generatedEnumAndExtension = generateEnumFromKeys.generateEnum();
    try {
      FileManager.writeFile(filePath, generatedEnumAndExtension);
    } catch (e, s) {
      if (_verbose) {
        _printHelper.print(e.toString());
        _printHelper.print(s.toString());
      }
      return _generateEnumAndExtension(true);
    }
    _printHelper.completeProgress();
  }

  @override
  Future<void> run() async {
    _intialize();
    await _analyzeProject();
    _generateJsonFile();
    _generateEnumAndExtension();
  }
}
