import 'dart:io';


class FileManager {
  Future<void> writeFile(String path, String contents) =>
      File(path).writeAsString(contents);

  String getFileContent(String path) => File(path).readAsStringSync();


}
