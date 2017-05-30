import 'package:logging/logging.dart';
import 'package:args/args.dart';

ArgResults handleCommonArgs(List<String> args,
    {Level defaultLogLevel = Level.WARNING}) {
  Logger.root.level = defaultLogLevel;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name.toLowerCase()}: ${rec.message}');
  });

  ArgParser parser = new ArgParser(allowTrailingOptions: true)
    ..addFlag('verbose', abbr: 'v');

  ArgResults argResults = parser.parse(args);
  if (argResults['verbose']) Logger.root.level = Level.ALL;
  return argResults;
}
