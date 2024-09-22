import 'dart:io';

import 'package:gen_locale/gen_locale.dart';
import 'package:gen_locale/src/text_map_builder.dart';
import 'package:string_literal_finder/string_literal_finder.dart';
import 'package:test/test.dart';

main() {
  // todo: separate into groups with multiple files.
  test('Test Getting Text', () async {
    // arrange -- act
    PathToStringsMap map = await testTextMapBuilder();
    expect(map.toString(), expected);
  });
}

Future<PathToStringsMap> testTextMapBuilder() async {
// arrange
  File file = File("${Directory.current.path}/test/example/example_text.dart");
  file.createSync(recursive: true);
  file.writeAsStringSync(exampleFileContents);
  final genLocale = GenLocale('${Directory.current.path}/test/example');
  // act
  await genLocale.getStrings();
  print(genLocale.pathToStringsMap.toString());
  // clean
  File('${Directory.current.path}/test/example/').deleteSync(recursive: true);
  return genLocale.pathToStringsMap;
}

const String expected =
    "{/Users/user/HindawiProjects/gen_locale/test/example/example_text.dart: [\nStringData(\nsource: 'a',\nvalue: a,\nwithContext: true,\nvariables: null)\n, \nStringData(\nsource: 'b',\nvalue: b,\nwithContext: true,\nvariables: null)\n, \nStringData(\nsource: 'eoeoeo aaa!',\nvalue: eoeoeo aaa!,\nwithContext: true,\nvariables: null)\n, \nStringData(\nsource: '''eoeoeo!''',\nvalue: eoeoeo!,\nwithContext: true,\nvariables: null)\n, \nStringData(\nsource: \"ddd\",\nvalue: ddd,\nwithContext: true,\nvariables: null)\n, \nStringData(\nsource: \"{} d\",\nvalue: {} d,\nwithContext: true,\nvariables: [textFive])\n, \nStringData(\nsource: \"\"\"ddd\"\"\",\nvalue: ddd,\nwithContext: true,\nvariables: null)\n, \nStringData(\nsource: r\"\"\"ddd\$var\"\"\",\nvalue: ddd\$var,\nwithContext: true,\nvariables: null)\n, \nStringData(\nsource: 'Flutter Demo',\nvalue: Flutter Demo,\nwithContext: true,\nvariables: null)\n, \nStringData(\nsource: 'Flutter Demo Home Page',\nvalue: Flutter Demo Home Page,\nwithContext: true,\nvariables: null)\n]}";
const String exampleFileContents = """
// should be skipped
import 'package:flutter/material.dart';
// 'an example that should be skipped'
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // should be skipped
  final text='';
  // should be caught. (1)
  final textTwo='a';
    // should be caught.(2)
  final textThree='b';
    // should be caught.
  final textFour='eoeoeo aaa!';
    // should be caught.
  static const textFive='''eoeoeo!''';
    // should be caught.
  final textSix = "ddd";
    // should be caught with variables
    final textNine= "\$textFive d";
    // should be caught.
  final textSeven = \"\"\"ddd\"\"\";
    // should be caught as string with no variables
  final textEight = r\"\"\"ddd\$var\"\"\";

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // should be caught.
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        // 'comment'
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
        // should be caught.
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
""";

class IncludeOnlyDartTestFiles extends ExcludePathChecker {
  @override
  bool shouldExclude(String path) {
    return path.endsWith('_test.dart') == false;
  }
}
