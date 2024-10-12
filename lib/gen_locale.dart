import 'dart:io';
import 'dart:isolate';

import 'package:gen_locale/src/file_manager.dart';
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

  SetOfStringData get setOfStringData => textMapBuilder.setOfStringData;
  int lengthOfFoundStrings = 0;

  initFinder() => finder =
      slf.StringLiteralFinder(basePath: basePath, excludePaths: excludes);

  initExcludes(List<String> excludeStrings) {
    excludes = [
      slf.ExcludePathChecker.excludePathCheckerEndsWith('_test.dart'),
      IncludeOnlyDartFiles(),
      ...slf.ExcludePathChecker.excludePathDefaults,
      ...excludeStrings.map<ExcludePathThatContains>(
          (e) => ExcludePathThatContains(contains: e)),
    ];
  }

  GenLocaleStringLiteralFinder();

  init() async {
    PrintHelper().version();
    _getReplaceCodeBase();
    basePath = _getBaseUri();
    initExcludes(_getUserExcludes());
    PrintHelper().addProgress('Analyzing Project');
    await Future.delayed(Duration.zero);
    initFinder();
    textMapBuilder = TextMapBuilderStringLiteral();
  }

  late final bool replaceCodeBase;

  _getReplaceCodeBase() {
    replaceCodeBase = PrintHelper().chooseOne<bool>(
        'Do you want to replace all strings in your code base?',
        [true, false],
        false);
  }

  String _getBaseUri() {
    String base = PrintHelper().prompt(
        'Enter Project Path... (default to current)', Directory.current.path,
        skipFlush: true);
    if (base.startsWith('./') || base == '.') {
      base = base.replaceFirst('.', Directory.current.path);
    }
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
      List<Map<String, dynamic>> data = await Isolate.run(() async {
        List<slf.FoundStringLiteral> a = await finder.start();
        for (var found in a) {
          textMapBuilder.addAFoundStringLiteral(found);
        }
        return textMapBuilder.setOfStringData.map((e) => e.toMap()).toList();
      });
      Set<StringData> dataSet = data.map((e) => StringData.fromJson(e)).toSet();
      textMapBuilder.addAllStringData(dataSet);
      lengthOfFoundStrings = dataSet.length;
      if (verbose) {
        print(textMapBuilder.setOfStringData);
        print('--------------------------------------------');
      }
    } catch (e, s) {
      if (verbose) {
        print(e);
        print(s);
      }
      throw (StackException(
          message: Exceptions.couldNotStartDartServer, stack: '$e\n$s'));
    }
  }

  @override
  Future<void> run() async {
    await _analyzeProject();

    PrintHelper().completeProgress();

    PrintHelper().print(
        'Fetched Strings: $lengthOfFoundStrings Files: ${textMapBuilder.pathToStringData.keys.length}',
        style: styleBold,
        color: cyan,
        addToMessages: true);
  }
}
