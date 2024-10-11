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
import 'package:string_literal_finder/string_literal_finder.dart' as slf;

class GenLocaleStringLiteralFinder extends GenLocaleAbs {
  final bool verbose = PrintHelper().verbose;
  /// A Map of File Path as a key with value of List of [StringData]
  /// Used For Replacing texts file by file.

  SetOfStringData get setOfStringData => textMapBuilder.setOfStringData;
  int lengthOfFoundStrings = 0;

  initFinder() => finder = slf.StringLiteralFinder(basePath: basePath, excludePaths: excludes);

  initExcludes(List<String> excludeStrings) {
    excludes = [
      slf.ExcludePathChecker.excludePathCheckerEndsWith('_test.dart'),
      IncludeOnlyDartFiles(),
      ...slf.ExcludePathChecker.excludePathDefaults,
      ...excludeStrings.map<ExcludePathThatContains>((e) => ExcludePathThatContains(contains: e)),
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
    replaceCodeBase =
        PrintHelper().chooseOne<bool>('Do you want to replace all strings in your code base?', [true, false], false);
  }

  String _getBaseUri() {
    String base = PrintHelper().prompt('Enter Project Path... (default to current)', Directory.current.path);
    if (base.startsWith('./')) {
      base = base.replaceFirst('.', Directory.current.path);
    }
    if (FileManager.directoryExists(base)) {
      return base;
    } else {
      PrintHelper().print('Couldn\'t find Directory, Switching to ${Directory.current.path}');
      return Directory.current.path;
    }
  }

  List<slf.FoundStringLiteral> foundStringLiteral= [];

  List<String> _getUserExcludes() => PrintHelper().promptAny(
      'excludes: to exclude files with specific path. for example: "presentation,business" excludes all paths that contain presentation or business');



  Future<void> _analyzeProject() async {
    try {

      List<slf.FoundStringLiteral> a = await finder.start();


      lengthOfFoundStrings = foundStringLiteral.length;
    } catch (e, s) {
      if (verbose) {
        print(e);
        print(s);
      }
      throw (StackException(message: Exceptions.couldNotStartDartServer, stack: '$e\n$s'));
    }
  }

  @override
  Future<void> run() async {
    await _analyzeProject();

    PrintHelper().completeProgress();

    PrintHelper().print('Fetched Strings: $lengthOfFoundStrings Files: ${textMapBuilder.pathToStringData.keys.length}');
  }
}
