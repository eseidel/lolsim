import 'package:lol_duel/dragon.dart';
import 'package:lol_duel/common_args.dart';
import 'package:trotter/trotter.dart';
import 'package:logging/logging.dart';

int champCompare(Mob red, Mob blue) {
  red.team = Team.red;
  blue.team = Team.blue;

  World world = new World();
  world.addMobs([red, blue]);
  world.tickUntil((world) {
    bool survivingBlues = world.blues.any((Mob mob) => mob.alive);
    bool survivingReds = world.reds.any((Mob mob) => mob.alive);
    return !survivingBlues || !survivingReds;
  });
  int result = blue.currentHp.floor() - red.currentHp.floor();
  return result;
}

main(List<String> args) async {
  handleCommonArgs(args);
  Logger.root.level = Level.WARNING;
  DragonData data = await DragonData.loadLatest();
  List<String> champIds = data.champs.loadChampIds();
  Map<String, int> victoryCounts = {};
  champIds.forEach((id) => victoryCounts[id] = 0);
  Combinations combos = new Combinations(2, champIds);
  // Combinations doesn't implement iterable, so I can't use it in strong mode. :(
  for (int i = 0; i < combos.length; i += 1) {
    List<String> names = combos[i] as List<String>;
    // Loading champ new every time to avoid any buffs hanging over, etc.
    Mob red = data.champs.championById(names[0]);
    Mob blue = data.champs.championById(names[1]);
    int result = champCompare(red, blue);
    if (result > 0)
      victoryCounts[blue.id] += 1;
    else if (result < 0) victoryCounts[red.id] += 1;
  }
  champIds.sort((a, b) => victoryCounts[a].compareTo(victoryCounts[b]));
  champIds.forEach((id) => print("$id ${victoryCounts[id]}"));
}
