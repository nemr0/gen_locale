import 'dart:io';

/// Write File, Get File Content, Check if file or Directory exist all using [dart:io]
class FileManager {
  /// File(path).writeAsString(contents)
  static void writeFile(String path, String contents) {
    File file =File(path);
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    file.writeAsStringSync(contents);
  }

  /// File(path).readAsStringSync();
  static String getContents(String path) => File(path).readAsStringSync();

  /// File(path).existsSync()
  static bool fileExists(String path) => File(path).existsSync();

  /// Directory(path).existsSync()
  static bool directoryExists(String path) => Directory(path).existsSync();
}
