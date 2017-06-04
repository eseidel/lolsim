#!/usr/local/bin/dart
import 'package:lol_duel/championgg.dart';
import 'package:lol_duel/dragon/dragon.dart';
import 'package:lol_duel/utils/cli_table.dart';
import 'package:lol_duel/utils/common_args.dart';

String _toPercentString(double value) {
  return "${(100 * value).toStringAsFixed(1)}%";
}

dynamic main(List<String> args) async {
  handleCommonArgs(args);
  DragonData dragon = await DragonData.loadLatest();
  ChampionGG championGG = await ChampionGG.loadExampleData(dragon);

  TableLayout layout = new TableLayout([15, 10, 10, 10]);
  layout.printRow(['Champion', 'Role', '% as Role', 'First Skill']);
  layout.printDivider();

  championGG.championStats.forEach((stats) {
    RoleEntry mostPlayed = stats.mostPlayed;
    String mostPlayedString = _toPercentString(mostPlayed.percentRolePlayed);
    layout.printRow([
      stats.champ.name,
      mostPlayed.role.shortName,
      mostPlayedString,
      mostPlayed.mostCommonSkillOrder.first,
    ]);
  });
}
