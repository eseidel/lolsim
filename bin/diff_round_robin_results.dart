import 'dart:async';
import 'dart:convert';

import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:resource/resource.dart';

import 'round_robin.dart';

Future<List<ChampResults>> load(String path) async {
  String jsonString = await new Resource(path).readAsString();
  List<Map<String, dynamic>> jsonList = await JSON.decode(jsonString);
  return jsonList.map((json) => new ChampResults.fromJson(json)).toList();
}

main(List<String> args) async {
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((LogRecord rec) {
    // ${rec.time}:
    print('${rec.level.name.toLowerCase()}: ${rec.message}');
  });

  ArgParser parser = new ArgParser(allowTrailingOptions: true)
    ..addFlag('verbose', abbr: 'v');

  ArgResults results = parser.parse(args);
  if (results['verbose']) Logger.root.level = Level.ALL;

  List<ChampResults> fromList = await load(results.rest[0]);
  List<ChampResults> toList = await load(results.rest[1]);
  // This will not handle diffs across adding/removing champions.
  for (int i = 0; i < fromList.length; i++) {
    ChampResults from = fromList[i];
    ChampResults to = toList[i];
    String diffString = from.diffString(to);
    // This is a hack to detect if there is a difference.
    if (diffString != from.champId)
      print(diffString);
  }
}
