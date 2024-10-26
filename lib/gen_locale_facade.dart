import 'package:analyzer/file_system/file_system.dart';
import 'package:gen_locale/src/found_strings_analyzer.dart';
import 'package:gen_locale/src/logger/print_helper.dart';
import 'package:gen_locale/src/models/exceptions/generation_exception.dart';
import 'package:gen_locale/src/models/exceptions/intialization_exception.dart';

import 'package:gen_locale/src/models/found_strings_analyzer_abs.dart';
import 'package:gen_locale/src/models/gen_locale_abstract.dart';
import 'package:gen_locale/src/models/string_data.dart';
import 'package:gen_locale/src/string_getter.dart';
import 'package:mason_logger/mason_logger.dart';

import 'package:path/path.dart' as p;

import 'src/file_manager.dart';
import 'src/generate_enum_from_keys.dart';
import 'src/generate_json_map.dart';
import 'src/logger/exceptions.dart';
import 'src/models/exceptions/stack_exception.dart';

import 'src/string_processor.dart';

class GenLocaleFacade extends GenLocale {
  // declare all classes responsible for different main proccessing
  late final PrintHelper _printHelper;
  late final FoundedStringsAnalayzer _foundedStringsAnalyzer;
  late final StringsGetter _stringsGetter;

  late final String _basePath;
  late final String _rawBasePath;

  late final bool _verbose;

  GenLocaleFacade() {
    // intialize all classes
    _printHelper = PrintHelper();
    _foundedStringsAnalyzer = FoundedStringsAnalyzerImpl();
    _stringsGetter = StringsGetter(_printHelper);
    _verbose = _printHelper.verbose;
  }

  void _intialize() {
    try {
      // get base path
      _rawBasePath = _printHelper.getBaseUri();

      _basePath = p.normalize(p.absolute(_rawBasePath));

      //add progress
      _printHelper.addProgress('Analyzing Project');
    } catch (e, s) {
      throw (IntializationException(
          message: Exceptions.couldNotIntializeFinder, stack: '$e\n$s'));
    }
  }

  Future<void> _analyzeProject() async {
    try {
      // Capture any necessary data outside of the isolate to avoid capturing the outer context
      final String basePath = _basePath;

      // Use the Isolate to run string analyzer conccurently
      final analyzedStrings = await _stringsGetter.run(basePath);

      // Convert the returned data to the desired type and add it to the main analyzer
      Set<StringData> dataSet =
          analyzedStrings.map((e) => StringData.fromJson(e)).toSet();
      // add data to the active founded analyzer that will be used accross all processes
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
        p.join(_rawBasePath, 'RESOURCES.json'),
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
      '$_rawBasePath/lib/generated/keys.dart',
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
