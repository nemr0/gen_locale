class StringProcessor {
  String valueFromSource(String source) {
    // if starts as a raw string
    if (source.startsWith("r'") || source.startsWith('r"')) {
      return source
          .replaceFirst("r'", '')
          .replaceFirst('r"', '')
          .replaceAll("'", '')
          .replaceAll('"', '');
    }
    return source.replaceAll('\'', '').replaceAll('"', '');
  }

  (String replacedSource, List<String>? variables) matchVariables(
      String source) {
    // skips no vars strings and raw strings
    if (source.contains('\$') == false ||
        source.startsWith('r"') ||
        source.startsWith("r'")) {
      return (source, null);
    }
    List<String> variables = [];
    // all matches for all variables
    final matches = RegExp(r"""(?<!\\)\$\{?([a-zA-Z_][a-zA-Z0-9_\.]*)\}?""")
        .allMatches(source);
    for (var match in matches) {
      String? matchString = match.group(0);
      if (matchString == null) continue;
      variables.add(match.group(1) ??
          matchString
              .replaceFirst("\${", "")
              .replaceFirst("}", "")
              .replaceFirst("\$", ""));
      source = source.replaceFirst(matchString, "{}");
    }
    return (source, variables.isEmpty ? null : variables);
  }
}
