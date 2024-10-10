
import 'package:string_literal_finder/string_literal_finder.dart' as slf;

class IncludeOnlyDartFiles extends slf.ExcludePathChecker {
  @override
  bool shouldExclude(String path) {
    return path.endsWith('.dart') == false;
  }
}