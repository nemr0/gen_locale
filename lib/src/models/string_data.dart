import 'package:equatable/equatable.dart';
///
/// value: replaced variables, cleaned with no quotation
/// source: original string
/// variables: all variables within
/// withContext: should use context for reactivity or not.
class StringData extends Equatable{
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

  @override
  List<Object?> get props => [variables,source,value,withContext];
}
