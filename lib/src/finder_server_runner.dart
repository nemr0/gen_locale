// import 'package:gen_locale/src/logger/print_helper.dart';
// import 'package:string_literal_finder/string_literal_finder.dart';
//
// class FinderServerRunner{
//   late final StringLiteralFinder finder;
//   FinderServerRunner(String basePath,List<ExcludePathChecker> excludes, this.finder){
//     finder = StringLiteralFinder(basePath: basePath, excludePaths: excludes);
//   }
//
//   List<String> _getUserExcludes() => PrintHelper().promptAny(
//       'excludes: to exclude files with specific path. for example: "presentation,business" excludes all paths that contain presentation or business');
//   Future<List<FoundStringLiteral>> run() async {
//     return await finder.start();
//   }
//   initExcludes(List<String> excludeStrings) {
//     excludes = [
//       ExcludePathChecker.excludePathCheckerEndsWith('_test.dart'),
//       IncludeOnlyDartFiles(),
//       ...ExcludePathChecker.excludePathDefaults,
//       ...excludeStrings.map<ExcludePathThatContains>((e) => ExcludePathThatContains(contains: e)),
//     ];
//   }
//
//
// }