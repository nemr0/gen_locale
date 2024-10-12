# gen_locale

## What is this for?

A command-line application providing 'genLocale' command to:

- gather strings with project.
- generate locale Json file for a single language.
- generate locale model. (enum with extension)
- replace all picked strings within code with the model.

## how can I use it?
- activation:  
  repo:  ```dart pub global activate --source git https://github.com/nemr0/gen_locale```  
  Pub.dev: **soon**
- run `genlocale` in your project's directory.
- (alt+shift+f) or (shift+option+f) on vscode or (option+command+l) or (ctrl+alt+l) on android studio to format json file.
- change json file name to your desired language.
- implement using model for ur fav Localization package.
- Enjoy!
## NOTES:
  - This package uses (String Literal Finder)[https://github.com/hpoul/string_literal_finder/tree/master/packages/string_literal_finder]
  so it apply for it's rules:
    - from string_literal_finder docs:
    The following dart file:
    ```dart
    import 'package:string_literal_finder_annotations/string_literal_finder_annotations.dart';
    import 'package:logging/logging.dart';
  
    final _logger = Logger('example');
  
    void exampleFunc(@NonNls String ignored, String warning) {}
  
    void main() {
      exampleFunc('Hello world', 'not translated');
      _logger.finer('Lorem ipsum');
  
      final testMap = nonNls({
        'key': 'value',
      });
    }
  
    @NonNls
    String ignoreFunction() {
      // all strings in this function will be ignored.
      return 'foo';
    }
    ```
  
    will result in those warnings:
  
    ```shell
    $ dart bin/string_literal_finder.dart --path=example
    2020-08-08 14:38:47.800339 INFO string_literal_finder - Found 1 literals:
    2020-08-08 14:38:47.801934 INFO string_literal_finder - lib/example.dart:17:30 'not translated'
    Found 1 literals in 1 files.
    $ 
    ```
  
    # Ignored literal strings
  
    * Any argument annotated with `@NonNls` or `@NonNlsArg()`
      * Anything which is parsed into the `nonNls` function.
      * Anything passed to `logging` library `Logger` class.
      * Any line with a line end comment `// NON-NLS`
