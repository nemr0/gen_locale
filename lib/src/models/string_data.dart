///
/// value: replaced variables, cleaned with no quotation
/// source: original string
/// variables: all variables within
/// withContext: should use context for reactivity or not.
class StringData {
  final List<String>? variables;
  final String source;
  final String value;
  final bool withContext;
  final Set<String> filesPath;
  final String key;

  const StringData({
    required this.filesPath,
    this.variables,
    required this.source,
    required this.value,
    required this.withContext,
    required this.key,
  });

  @override
  toString() =>
      '\nStringData(\nsource: $source,\nvalue: $value,\nwithContext: $withContext,\nvariables: $variables,\nfilePath: $filesPath,\nkey: $key),\n';

  @override
  bool operator ==(Object other) {
    if (other is! StringData) return false;
    return value == other.value &&
        source == other.source &&
        withContext == other.withContext &&
        variables?.join() == other.variables?.join() &&
        filesPath.join() == other.filesPath.join() &&
        key == other.key;
  }

  @override
  int get hashCode => Object.hash(value, source, withContext, variables?.join(), filesPath.join(), key);

  factory StringData.fromJson(Map<String, dynamic> map) => StringData(
        source: map['source'],
        value: map['value'],
        withContext: map['withContext'],
        variables: map['variables'],
        filesPath: map['filesPath'],
        key: map['key'],
      );

  Map<String, dynamic> toMap() => {
        'source': source,
        'value': value,
        'withContext': withContext,
        'variables': variables,
        'filesPath': filesPath,
        'key': key
      };
}
