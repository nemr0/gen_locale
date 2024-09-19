import 'package:string_literal_finder/string_literal_finder.dart' as slf;

class GenerateLocalizationFile {
  final String basePath;
  late final  slf.StringLiteralFinder finder;
  Map<String, List<String>> mapFileToListStrings = {};
  final bool verbose=true;
  GenerateLocalizationFile(this.basePath){
    finder = slf.StringLiteralFinder(basePath: basePath, excludePaths: [IncludeOnlyDartFiles()]);
  }
  getFileName(String path)=>path.split('/').last.split('.').first;
  Future<void> getStrings() async {
   try {
      List<slf.FoundStringLiteral> foundStringLiteral = await finder.start();
      for (slf.FoundStringLiteral s in foundStringLiteral) {
        if (mapFileToListStrings[s.filePath] == null) {
          if (s.stringValue != null) mapFileToListStrings[s.filePath] = [s.stringValue!];

        } else {
          if (s.stringValue != null) mapFileToListStrings[s.filePath]!.add(s.stringValue!);
        }
        print(s.stringLiteral.toSource());
        print(s.stringValue);
      }
    }catch(e,s){
      if(verbose){
        print('$e\n$s');
      }
   }
  }

}
class IncludeOnlyDartFiles extends slf.ExcludePathChecker{
  @override
  bool shouldExclude(String path) {
   return path.endsWith('.dart')==false;
  }
}