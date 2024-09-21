class StringData {
  final List<String>? variables;
  final String source;
  final String value;
  final bool withContext;

  const StringData({
    this.variables,
    required this.source,
    required this.value,
    required this.withContext,
  });

  @override
  toString() =>
      '\nStringData(\nsource: $source,\nvalue: $value,\nwithContext: $withContext,\nvariables: $variables)\n';
}
