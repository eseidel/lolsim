import 'package:logging/logging.dart';
import 'package:lol_duel/common_args.dart';
import 'package:lol_duel/dragon.dart';
import 'package:lol_duel/lolsim.dart';
import 'package:trotter/trotter.dart';

int champCompare(Mob red, Mob blue) {
  new World(reds: [red], blues: [blue]).tickUntil(World.oneSideDies);
  return blue.currentHp.floor() - red.currentHp.floor();
}

class ChampResults implements Comparable<ChampResults> {
  int victories = 0;
  bool hasEffects = false;

  void recordVictory() {
    victories += 1;
  }

  int compareTo(ChampResults b) {
    return victories.compareTo(b.victories);
  }
}

main(List<String> args) async {
  handleCommonArgs(args);
  Logger.root.level = Level.WARNING;
  DragonData data = await DragonData.loadLatest();
  List<String> champIds = data.champs.loadChampIds();
  Map<String, ChampResults> resultsById = {};
  champIds.forEach((id) => resultsById[id] = new ChampResults());
  Combinations combos = new Combinations(2, champIds);
  // Combinations doesn't implement iterable, so I can't use it in strong mode. :(
  for (int i = 0; i < combos.length; i += 1) {
    List<String> names = combos[i] as List<String>;
    // Loading champ new every time to avoid any buffs hanging over, etc.
    Mob red = data.champs.championById(names[0]);
    Mob blue = data.champs.championById(names[1]);
    int result = champCompare(red, blue);
    if (result > 0)
      resultsById[blue.id].recordVictory();
    else if (result < 0) resultsById[red.id].recordVictory();
  }
  champIds.sort((a, b) => resultsById[a].compareTo(resultsById[b]));
  champIds.forEach((id) {
    ChampResults results = resultsById[id];
    String line = "$id ${results.victories}";
    if (results.hasEffects) line += " (has passive)";
    print(line);
  });
}
