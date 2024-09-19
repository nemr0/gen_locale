import 'package:string_literal_finder/string_literal_finder.dart' as slf;

class GenerateLocalizationFile {
  final String basePath;
  late final  slf.StringLiteralFinder finder;
  Map<String, List<String>> mapFileToListStrings = {};
  GenerateLocalizationFile(this.basePath);
  init(){
    finder = slf.StringLiteralFinder(basePath: basePath, excludePaths: []);
  }
  getFileName(String path)=>path.split('/').last.split('.').first;
  getStrings() async {
    List<slf.FoundStringLiteral> foundStringLiteral = await finder.start();
    for (slf.FoundStringLiteral s in foundStringLiteral) {
      if (mapFileToListStrings[s.filePath] == null) {
        if(s.stringValue!=null) mapFileToListStrings[s.filePath] = [s.stringValue!];
      } else {
        if(s.stringValue!=null)mapFileToListStrings[s.filePath]!.add(s.stringValue!);
      }
    }
  }

}
