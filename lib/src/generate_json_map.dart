import 'dart:convert';

import 'package:gen_locale/src/file_manager.dart';

class JsonMap {

 static void generateJsonFileFromMap(String filePath,Map<String,dynamic> jsonMap){
   if(FileManager.fileExists(filePath)){
     Map<String,dynamic> savedContent =jsonDecode(FileManager.getContents(filePath)) ;
     savedContent.removeWhere((key,value)=> jsonMap.containsKey(key));
     jsonMap.addAll(savedContent);
   }
   String content = jsonEncode(jsonMap);

   FileManager.writeFile(filePath, content);
  }
}
