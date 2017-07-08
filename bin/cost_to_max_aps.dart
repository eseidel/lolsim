#!/usr/local/bin/dart
import 'package:lol_duel/creator.dart';
import 'package:lol_duel/dragon/dragon.dart';
import 'package:lol_duel/dragon/stat_constants.dart';
import 'package:lol_duel/lolsim.dart';
import 'package:lol_duel/utils/cli_table.dart';
import 'package:lol_duel/utils/common_args.dart';

class _Calculated {
  final String champName;
  int range;
  double apsAt18;
  double pasToMaxAps;

  _Calculated(Creator creator, this.champName) {
    Mob champ = creator.champs.championByName(champName);
    champ.level = 18;
    champ.updateStats();
    apsAt18 = champ.stats.attackSpeed;
    range = champ.stats.range;

    double deltaToMaxAps = 2.5 - apsAt18;
    double baseAttackSpeed = champ.description.baseStats.baseAttackSpeed;
    double apsPerPercent = baseAttackSpeed;
    pasToMaxAps = deltaToMaxAps / apsPerPercent;
  }
}

dynamic main(List<String> args) async {
  handleCommonArgs(args);
  Creator creator = await Creator.loadLatest();

  ItemDescription pasItem = creator.items.itemByName('Dagger');
  double pasInGold =
      pasItem.gold['total'] / pasItem.stats[PercentAttackSpeedMod];

  TableLayout layout = new TableLayout([13, 5, 15, 15, 15]);
  layout.printRow(['Name', 'Range', 'APS @ 18', 'PAS to Max', 'Gold to Max']);
  layout.printDivider();

  List<String> champNames = creator.dragon.champs.loadChampNames();
  List<_Calculated> results =
      champNames.map((name) => new _Calculated(creator, name)).toList();
  results.sort((a, b) => a.pasToMaxAps.compareTo(b.pasToMaxAps));

  for (var result in results) {
    layout.printRow([
      result.champName,
      result.range.toString(),
      result.apsAt18.toStringAsFixed(2),
      result.pasToMaxAps.toStringAsFixed(2),
      (result.pasToMaxAps * pasInGold).toStringAsFixed(2),
    ]);
  }
}
