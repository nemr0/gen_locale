import 'package:string_literal_finder/string_literal_finder.dart' as slf;

class ExcludePathThatContains extends slf.ExcludePathChecker {
  final String contains;

  ExcludePathThatContains({required this.contains});

  @override
  bool shouldExclude(String path) {
    return path.contains(contains);
  }
}