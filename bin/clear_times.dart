#!/usr/local/bin/dart
import 'package:lol_duel/common_args.dart';
import 'package:lol_duel/creator.dart';
import 'package:lol_duel/lolsim.dart';
import 'package:lol_duel/cli_table.dart';

class _Calculate {
  String champName;
  bool hasEffects;
  double hpPercent;
  double clearTime;

  _Calculate(Creator creator, this.champName) {
    Mob makeChamp() {
      return creator.champs.championByName(champName)..updateStats();
    }

    Item item(String name) => creator.items.itemByName(name);

    Mob champ = makeChamp();
    champ.addItem(item("Hunter's Machete"));

    hasEffects = champ.championEffects != null;
    computeClearTime(creator, champ);
  }

  void computeClearTime(Creator creator, Mob champ) {
    // Should do more than just blue sentinel.
    // Need to handle travel time
    // Need to handle levels.
    Mob monster = Mob.createMonster(MonsterType.blueSentinal);
    World world = new World(
      reds: [champ],
      blues: [monster],
      critProvider: new PredictableCrits([champ.id, monster.id]),
    );
    world.tickUntil(World.oneSideDies);
    hpPercent = champ.healthPercent;

    clearTime = world.time;
  }
}

dynamic main(List<String> args) async {
  handleCommonArgs(args);

  Creator creator = await Creator.loadLatest();

  List<String> champNames = creator.dragon.champs.loadChampNames();
  List<_Calculate> results = champNames.map((champName) {
    return new _Calculate(creator, champName);
  }).toList();
  results.sort((a, b) => a.clearTime.compareTo(b.clearTime));

  TableLayout layout = new TableLayout([1, 13, 6, 6]);
  layout.printRow(['P', 'Name', 'HP%', 'Time']);
  layout.printDivider();

  String _toPercentString(double value) {
    return "${(100 * value).toStringAsFixed(1)}%";
  }

  for (var r in results) {
    layout.printRow([
      r.hasEffects ? '*' : ' ',
      r.champName,
      _toPercentString(r.hpPercent),
      "${r.clearTime.toStringAsFixed(0)}s",
    ]);
  }

  // Try each champ
  // compute clear time
  // with each item.
}
