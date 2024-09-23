import 'dart:io';

import 'package:gen_locale/src/models/string_data.dart';
import 'package:gen_locale/src/text_map_builder.dart';
import 'package:test/test.dart';

import 'find_strings_test.dart';

main() {
  group('Testing [TextMapBuilder]',  (){

    test('Test Adding StringValues', () async {
      final TextMapBuilder textMapBuilder = TextMapBuilder();

      // arrange -- act
      PathToStringsMap map = await getPathToStringsMap(textMapBuilder);
      expect(map, expectedStrings);
    });
  });

}

Future<PathToStringsMap> getPathToStringsMap(TextMapBuilder textMapBuilder) async {
  final foundStrings = await findStrings(exampleFileContents);
  for (var foundStringLiteral in foundStrings) {
    textMapBuilder.addAString(foundStringLiteral);
  }
  return textMapBuilder.pathToStrings;
}

final PathToStringsMap expectedStrings = {
  '${Directory.current.absolute.path}/test/mytest.dart': [
    StringData(source: "'a'", value: "a", withContext: false, variables: null),
    StringData(source: "'b'", value: 'b', withContext: false, variables: null),
    StringData(source: "'eoeoeo aaa!'", value: "eoeoeo aaa!", withContext: false, variables: null),
    StringData(source: "'''eoeoeo!'''", value: 'eoeoeo!', withContext: false, variables: null),
    StringData(source: '"ddd"', value: 'ddd', withContext: false, variables: null),
    StringData(source: '"\$textFive d"', value: '{} d', withContext: false, variables: ['textFive']),
    StringData(source: '"""ddd"""', value: 'ddd', withContext: false, variables: null),
    StringData(source: 'r"""ddd\$var"""', value: r'ddd$var', withContext: false, variables: null),
    StringData(source: "'Flutter Demo'", value: 'Flutter Demo', withContext: false, variables: null),
    StringData(source: "'Flutter Demo Home Page'", value: 'Flutter Demo Home Page', withContext: false, variables: null)
  ]
};
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


