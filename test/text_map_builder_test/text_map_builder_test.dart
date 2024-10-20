import 'dart:io';

import 'package:gen_locale/src/models/string_data.dart';
import 'package:gen_locale/src/models/text_map_builder.dart';
import 'package:gen_locale/src/text_map_builder.dart';
import 'package:string_literal_finder/string_literal_finder.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as p;

import '../find_strings_test.dart';

main() {
  group('Testing [TextMapBuilder]', () {
    /// Testing content of [fileOneExample] should match [expectedStrings]
    test('Test Adding Different StringValues From The Same File', () async {
      // arrange
      final TextMapBuilder textMapBuilder = TextMapBuilderStringLiteral();

      // act
      await getSetOfStringData(
          textMapBuilder,
          fileOneExample,
          p.join(Directory.current.absolute.path, 'test/mytest.dart'));
      // assert
      expect(textMapBuilder.setOfStringData, expectedStrings({
        p.join(Directory.current.absolute.path, 'test/mytest.dart'),

      }));
    });

    /// Testing content of [fileOneExample] should match [expectedStrings] where [fileOneExample] is added two times
    /// with the same name in different directories.
    test('Testing Multiple Files with the same name and same content',
        () async {
      // arrange
      final TextMapBuilder textMapBuilder = TextMapBuilderStringLiteral();

      // act
      await getSetOfStringData(
          textMapBuilder,
          fileOneExample,
          p.join(Directory.current.absolute.path, 'test/mytest.dart'));

        await getSetOfStringData(
          textMapBuilder,
          fileOneExample,
          p.join(
            Directory.current.absolute.path,
            'test/exampleTwo/mytest.dart',
          ),
        );
        print(textMapBuilder.setOfStringData);
      // assert
      expect(textMapBuilder.setOfStringData, expectedStrings({   p.join(Directory.current.absolute.path, 'test/exampleTwo/mytest.dart',), p.join(Directory.current.absolute.path, 'test/mytest.dart'),}));
    });

  });
}

Future<void> getSetOfStringData(
    TextMapBuilder textMapBuilder, String file, String filePath) async {
  final foundStrings = await findStrings(file, filePath);
  for (FoundStringLiteral foundStringLiteral in foundStrings) {
    textMapBuilder.addAFoundStringLiteral(foundStringLiteral);
  }

}

 SetOfStringData expectedStrings(Set<String> filesPath) => {
  StringData(
      source: "'a'",
      value: "a",
      withContext: false,
      variables: null,
      filesPath: filesPath,
      key: 'mytest-0'),
  StringData(
      source: "'b'",
      value: 'b',
      withContext: false,
      variables: null,
      filesPath: filesPath,
      key: 'mytest-1'),
  StringData(
      source: "'eoeoeo aaa!'",
      value: "eoeoeo aaa!",
      withContext: false,
      variables: null,
      filesPath: filesPath,
      key: 'mytest-2'),
  StringData(
      source: "'''eoeoeo!'''",
      value: 'eoeoeo!',
      withContext: false,
      variables: null,
      filesPath: filesPath,
      key: 'mytest-3'),
  StringData(
      source: '"ddd"',
      value: 'ddd',
      withContext: false,
      variables: null,
      filesPath: filesPath,
      key: 'mytest-4'),
  StringData(
      source: '"\$textFive d"',
      value: '{} d',
      withContext: false,
      variables: ['textFive'],
      filesPath: filesPath,
      key: 'mytest-5'),
  StringData(
      source: '"\\\$textFive d"',
      value: '\\\$textFive d',
      withContext: false,
      variables: null,
      filesPath:filesPath,
      key: 'mytest-6'),
  StringData(
      source: '"""ddd"""',
      value: 'ddd',
      withContext: false,
      variables: null,
      filesPath: filesPath,
      key: 'mytest-7'),
  StringData(
      source: 'r"""ddd\$var"""',
      value: r'ddd$var',
      withContext: false,
      variables: null,
      filesPath: filesPath,
      key: 'mytest-8'),
  StringData(
      source: "'Flutter Demo'",
      value: 'Flutter Demo',
      withContext: true,
      variables: null,
      filesPath: filesPath,
      key: 'mytest-9'),
  StringData(
      source: "'Flutter Demo Home Page'",
      value: 'Flutter Demo Home Page',
      withContext: true,
      variables: null,
      filesPath: filesPath,
      key: 'mytest-10')
};
const String fileOneExample = """
// should be skipped
import 'package:flutter/material.dart';
import 'package:string_literal_finder_annotations/string_literal_finder_annotations.dart';

// 'an example that should be skipped'
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  void myFunc(@NonNls String nonTranslatable) => nonTranslatable
  // should be skipped
  final nonTranslated = myFunc('skipped');
  // should be skipped
  final text='';
  // should be caught. (1)
  final textTwo= 'a';
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
    final textNine= "\\\$textFive d";
    // should be caught.
  final textSeven = \"\"\"ddd\"\"\";
    // should be caught as string with no variables
  final textEight = r\"\"\"ddd\$var\"\"\";

  // This widget is the root of your application.
  @override
  Widget build(BuildContext ctx) {
    return MaterialApp(
      // should be caught. with context
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
