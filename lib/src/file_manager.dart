import 'dart:io';


class FileManager {
  static Future<void> writeFile(String path, String contents) =>
      File(path).writeAsString(contents);

  static String getContents(String path) => File(path).readAsStringSync();
  static bool fileExists(String path) => File(path).existsSync();


}
