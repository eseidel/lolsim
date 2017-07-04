#!/usr/local/bin/dart
import 'package:lol_duel/championgg.dart';
import 'package:lol_duel/championgg_utils.dart';
import 'package:lol_duel/creator.dart';
import 'package:lol_duel/lolsim.dart';
import 'package:lol_duel/monsters.dart';
import 'package:lol_duel/planning.dart';
import 'package:lol_duel/role.dart';
import 'package:lol_duel/summoners.dart';
import 'package:lol_duel/utils/cli_table.dart';
import 'package:lol_duel/utils/common_args.dart';

typedef CreateChamp = Mob Function();

class _Calculate {
  final CampType campType;
  final SpellKey startingSkill;
  bool alive;
  double hp;
  double hpPercent;
  double mana;
  double manaPercent;
  double clearTime;

  _Calculate(CreateChamp createChamp, this.campType, this.startingSkill) {
    Mob champ = createChamp();
    World world = new World(
      blues: [champ],
      reds: createCamp(campType),
      critProvider: new PredictableCrits(),
    );
    champ.addSkillPointTo(startingSkill);
    world.tickUntil(World.oneSideDies);

    hp = champ.currentHp;
    hpPercent = champ.healthPercent;
    alive = champ.alive;

    clearTime = world.time;
    mana = champ.currentMp;
    manaPercent = champ.manaPercent;
  }
}

dynamic main(List<String> args) async {
  handleCommonArgs(args);

  Creator creator = await Creator.loadLatest();
  ChampionGG championGG = await ChampionGG.loadExampleData(creator.dragon);
  String championName = 'Amumu';

  CreateChamp createChamp = () {
    Mob champ = creator.champs.championByName(championName);
    champ.planner = plannerFor(champ, Role.jungle);
    ChampionStats champStats = championGG.statsForChampionName(championName);
    RoleEntry jungleStats = champStats.entryForRole(Role.jungle);
    champ.summoners = new SummonerBook();
    champ.summoners.d = createSummoner(SummonerType.smite, champ);
    champ.masteryPage = masteriesFromHash(
        creator.dragon.masteries, jungleStats.mostCommonMasteriesHash);
    champ.runePage =
        runesFromHash(creator.dragon.runes, jungleStats.mostCommonRunesHash);
    jungleStats.mostCommonStartingItemIds.forEach((itemId) {
      champ.addItem(creator.items.itemById(itemId));
    });
    return champ;
  };

  // List<_Calculate> results = [
  //   new _Calculate(createChamp, CampType.blue, SpellKey.e)
  // ];
  List<_Calculate> results = [];
  List<SpellKey> spellKeys = [SpellKey.w, SpellKey.e];
  CampType.values.forEach((CampType camp) {
    spellKeys.forEach((SpellKey key) {
      results.add(new _Calculate(createChamp, camp, key));
    });
  });

  results.sort((a, b) {
    if (a.alive != b.alive) return a.alive ? 1 : -1;
    if (a.hpPercent != b.hpPercent) return a.hpPercent.compareTo(b.hpPercent);
    if (a.clearTime != b.clearTime) return a.clearTime.compareTo(b.clearTime);
    return 0;
  });

  TableLayout layout = new TableLayout([2, 8, 11, 11, 6]);
  layout.printRow(['', 'Camp', 'HP', 'MP', 'Time']);
  layout.printDivider();

  String percentString(bool alive, double value, double percent) {
    if (!alive) return '-';
    return "${value.round()} (${(100 * percent).toStringAsFixed(1)}%)";
  }

  for (var r in results) {
    layout.printRow([
      r.startingSkill.toString(),
      campTypeToString(r.campType),
      percentString(r.alive, r.hp, r.hpPercent),
      percentString(r.alive, r.mana, r.manaPercent),
      "${r.clearTime.round()}s",
    ]);
  }
}
