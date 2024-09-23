//
// import 'dart:io';
//
// import 'package:glob/glob.dart';
// import 'package:glob/list_local_fs.dart';
// import 'package:yaml/yaml.dart';
//
// class ReplaceStringFromDartFile{
//   String _packageName='';
//   String action(String source,String fileContent,String key,String enumName){
//    return fileContent.replaceAll(source, '$enumName.$key.get()');
//   }
//   String  importPackageNameFor({required String filename}) =>'''import 'package:$_packageName/generated/$filename.dart';\n''';
//   void _getPackageName(String currentDirectory){
//     try{
//       List<FileSystemEntity> pubspecYamls = Glob('pubspec.yaml').listSync();
//       final File pubspecYaml = (pubspecYamls.where((e) => e is File && e.path.split('/').last == 'pubspec.yaml').first) as File;
//       _packageName = loadYaml(pubspecYaml.readAsStringSync())['name'] ?? '';
//     }catch(e){
//       _packageName='';
//     }
//   }
//   _generateFunction(){
//
//   }
// }