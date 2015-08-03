import 'package:lolsim/lolsim.dart';
import 'package:logging/logging.dart';
import 'package:args/args.dart';
import 'dart:io';


void main(List<String> args) {
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((LogRecord rec) {
    // ${rec.time}:
    print('${rec.level.name.toLowerCase()}: ${rec.message}');
  });

  ArgParser parser = new ArgParser();
  ArgResults results = parser.parse(args);

  // ItemFactory items = new ItemFactory.fromItemJson('data/item.json');
  ChampionFactory champs = new ChampionFactory.fromChampionJson('data/champion.json');
  World world = new World();

  if (results.rest.length != 2) {
    log.severe("duel.dart supports exactly 2 champs.");
    exit(1);
  }

  world.mobs = results.rest.map(champs.championByName).toList();
  world.mobs[0].lastTarget = world.mobs[1];
  world.mobs[1].lastTarget = world.mobs[0];
  world.tickUntil((world) {
    return world.living.length < 2;
  });
  if (world.living.length == 0) {
    log.info("${world.mobs[0].name} and ${world.mobs[1].name} died at the same time!");
  } else {
    MOB survivor = world.living[0];
    log.info("At ${world.time.toStringAsFixed(2)}s ${survivor.name} lived with ${survivor.currentHp.toStringAsFixed(3)} hp");
  }
}
