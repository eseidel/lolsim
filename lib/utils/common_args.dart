import 'package:logging/logging.dart';
import 'package:args/args.dart';

ArgResults handleCommonArgs(List<String> args,
    {Level defaultLogLevel = Level.INFO}) {
  Logger.root.level = defaultLogLevel;
  Logger.root.onRecord.listen((LogRecord rec) {
    // ${rec.time}:
    print('${rec.level.name.toLowerCase()}: ${rec.message}');
  });

  ArgParser parser = new ArgParser(allowTrailingOptions: true)
    ..addFlag('verbose', abbr: 'v');

  ArgResults results = parser.parse(args);
  if (results['verbose']) Logger.root.level = Level.ALL;
  return results;
}
