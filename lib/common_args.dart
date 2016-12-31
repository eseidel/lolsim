import 'package:logging/logging.dart';
import 'package:args/args.dart';

ArgResults handleCommonArgs(List<String> args) {
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((LogRecord rec) {
    // ${rec.time}:
    print('${rec.level.name.toLowerCase()}: ${rec.message}');
  });

  ArgParser parser = new ArgParser()..addFlag('verbose', abbr: 'v');

  ArgResults results = parser.parse(args);
  if (results['verbose']) Logger.root.level = Level.ALL;
  return results;
}
