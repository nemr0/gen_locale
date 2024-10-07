import 'dart:io';

import 'package:gen_locale/src/file_manager.dart';
import 'package:gen_locale/src/logger/exceptions.dart';
import 'package:gen_locale/src/stack_exception.dart';
import 'package:gen_locale/src/text_map_builder.dart';
import 'package:gen_locale/src/logger/print_helper.dart';
import 'package:string_literal_finder/string_literal_finder.dart' as slf;

class GenLocale {
  final String basePath;
  late final slf.StringLiteralFinder finder;
  final bool verbose = PrintHelper().verbose;
  late final TextMapBuilder textMapBuilder;
  late final List<slf.ExcludePathChecker> excludes;

  PathToStringsMap get pathToStringsMap => textMapBuilder.pathToStrings;
  int lengthOfFoundStrings = 0;

  initFinder() => finder = slf.StringLiteralFinder(basePath: basePath, excludePaths: excludes);

  initExcludes(List<String>? excludeStrings) {
    excludes = [
      slf.ExcludePathChecker.excludePathCheckerEndsWith('_test.dart'),
      IncludeOnlyDartFiles(),
      ...slf.ExcludePathChecker.excludePathDefaults,
    ];
    if (excludeStrings != null) {
      excludes.addAll(excludeStrings.map<ExcludePathThatContains>((e) => ExcludePathThatContains(contains: e)));
    }
  }

  GenLocale({required this.basePath, List<String>? excludeStrings}) {
    initExcludes(excludeStrings);
    initFinder();
    textMapBuilder = TextMapBuilder();
  }

  static String promptBaseUri() {
    String base = PrintHelper().prompt('Enter Project Path... (default to current)', Directory.current.path);
    if (base.startsWith('./')) {
      base = base.replaceFirst('.', Directory.current.path);
      print(base);
    }
    if (FileManager.directoryExists(base)) {
      print('exists');
      return base;
    } else {
      print('not exist');

      return Directory.current.path;
    }
  }

  static List<String> promptExcludeStrings() => PrintHelper().promptAny(
      'excludes: to exclude files with specific path. for example: "presentation,business" excludes all paths that contain presentation or business');

  Future<void> analyzeProject() async {
    try {
      List<slf.FoundStringLiteral> foundStringLiteral = await finder.start();
      for (slf.FoundStringLiteral foundString in foundStringLiteral) {
        textMapBuilder.addAString(foundString);
      }
      lengthOfFoundStrings = foundStringLiteral.length;
    } catch (e, s) {
      if (verbose) {
        print(e);
        print(s);
      }
      throw (StackException(message: Exceptions.couldNotStartDartServer, stack: '$e\n$s'));
    }
  }

  Future<void> run() async {
    try {
      PrintHelper().addProgress('Analyzing Project');
      await analyzeProject();
      PrintHelper().completeProgress();

      PrintHelper().print('Fetched Strings: $lengthOfFoundStrings Files: ${textMapBuilder.pathToStrings.length}');
    } on StackException catch (e) {
      PrintHelper().failed(e.message);
      if (verbose) {
        print(e.stack);
      }
    }
  }
}

class IncludeOnlyDartFiles extends slf.ExcludePathChecker {
  @override
  bool shouldExclude(String path) {
    return path.endsWith('.dart') == false;
  }
}

class ExcludePathThatContains extends slf.ExcludePathChecker {
  final String contains;

  ExcludePathThatContains({required this.contains});

  @override
  bool shouldExclude(String path) {
    return path.contains(contains);
  }
}
