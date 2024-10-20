import 'dart:isolate';

import 'package:gen_locale/src/found_strings_analyzer.dart';
import 'package:gen_locale/src/logger/print_helper.dart';
import 'package:gen_locale/src/models/exceptions/intialize_exception.dart';
import 'package:gen_locale/src/models/found_strings_analyzer_abs.dart';
import 'package:gen_locale/src/models/gen_locale_abstract.dart';
import 'package:gen_locale/src/models/string_data.dart';
import 'package:mason_logger/mason_logger.dart';

import 'package:string_literal_finder/string_literal_finder.dart' as slf;

import 'src/logger/exceptions.dart';
import 'src/models/exceptions/stack_exception.dart';
import 'src/models/exclude_path_checker_impl/exclude_path_that_contains.dart';
import 'src/models/exclude_path_checker_impl/include_only_dart_files.dart';

class GenLocaleFacade extends GenLocale {
  // declare all classes responsible for different main proccessing
  late final PrintHelper _printHelper;
  late final FoundedStringsAnalayzer _foundedStringsAnalyzer;
  late final Set<StringData> _setOfStringData;
  late final String _basePath;
  late final List<slf.ExcludePathChecker> _excludesList;
  late final slf.StringLiteralFinder _finder;
  late final bool _verbose;

  GenLocaleFacade() {
    _printHelper = PrintHelper();
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
    // get base path
    try {
      _basePath = _printHelper.getBaseUri();
      // intilaize excludes files prompted from user
      _initExcludes(_printHelper.getUserExcludes());
      //add progress
      _printHelper.addProgress('Analyzing Project');
      // intialize finder after getting base path and list of excludes files
      _initFinder();
    } catch (e, s) {
      throw (IntializeException(
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
          'Fetched Strings: ${dataSet.length} Files: ${foundedStringsAnalyzer.pathToStringData.keys.length}',
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

  @override
  Future<void> run() async {
    _intialize();
    await _analyzeProject();
    print('');
  }
}
