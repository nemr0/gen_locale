import 'dart:io';

import 'package:string_literal_finder/string_literal_finder.dart' as slf;

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/file_system/overlay_file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:path/path.dart' as p;

Future<List<slf.FoundStringLiteral>> findStrings(String file) async {
  final overlay = OverlayResourceProvider(PhysicalResourceProvider.INSTANCE);
  final filePath = p.join(Directory.current.absolute.path, 'test/mytest.dart');
  overlay.setOverlay(
    filePath,
    content: file,
    modificationStamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
  );
  // final parsed = parseString(content: source);
  final parsed = await resolveFile2(path: filePath, resourceProvider: overlay)
  as ResolvedUnitResult;
  if (!parsed.exists) {
    throw StateError('file not found?');
  }
  final foundStrings = <slf.FoundStringLiteral>[];
  final x = slf.StringLiteralVisitor<dynamic>(
    filePath: filePath,
    unit: parsed.unit,
    foundStringLiteral: (found) {
      foundStrings.add(found);
    },
  );
  parsed.unit.visitChildren(x);
  return foundStrings;
}