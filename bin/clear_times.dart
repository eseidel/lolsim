#!/usr/local/bin/dart
import 'package:lol_duel/championgg.dart';
import 'package:lol_duel/championgg_utils.dart';
import 'package:lol_duel/creator.dart';
import 'package:lol_duel/lolsim.dart';
import 'package:lol_duel/monsters.dart';
import 'package:lol_duel/planning.dart';
import 'package:lol_duel/role.dart';
import 'package:lol_duel/utils/cli_table.dart';
import 'package:lol_duel/utils/common_args.dart';
import 'package:lol_duel/summoners.dart';

typedef CreateChamp = Mob Function(String champName);

class _Calculate {
  String champName;
  bool alive;
  double hp;
  double hpPercent;
  double clearTime;
  bool hasPassive;
  bool hasSkillEffects;
  SpellKey startingSkill;

  _Calculate(Creator creator, ChampionGG championGG, this.champName) {
    Mob champ = createChamp(creator, championGG, this.champName);
    if (champ == null) return;
    computeClearTime(champ);

    hasSkillEffects = champ.spells.spellForKey(startingSkill).effects != null;
    hasPassive = champ.championEffects != null;
  }

  Mob createChamp(Creator creator, ChampionGG championGG, String championName) {
    Mob champ = creator.champs.championByName(championName);
    champ.planner = plannerFor(champ, Role.jungle);
    ChampionStats champStats = championGG.statsForChampionName(championName);
    RoleEntry jungleStats = champStats.entryForRole(Role.jungle);
    if (jungleStats == null) return null;

    champ.summoners = new SummonerBook();
    champ.summoners.d = createSummoner(SummonerType.smite, champ);
    champ.masteryPage = masteriesFromHash(
        creator.dragon.masteries, jungleStats.mostCommonMasteriesHash);
    champ.runePage =
        runesFromHash(creator.dragon.runes, jungleStats.mostCommonRunesHash);
    jungleStats.mostCommonStartingItemIds.forEach((itemId) {
      champ.addItem(creator.items.itemById(itemId));
    });
    startingSkill =
        new SpellKey.fromChar(jungleStats.mostCommonSkillOrder.first);
    champ.addSkillPointTo(startingSkill);
    return champ;
  }

  void computeClearTime(Mob champ) {
    // Should do more than just blue sentinel.
    // Need to handle travel time
    // Need to handle levels.
    World world = new World(
      reds: [champ],
      blues: createCamp(CampType.blue),
      critProvider: new PredictableCrits(),
    );
    world.tickUntil(World.oneSideDies);
    hp = champ.currentHp;
    hpPercent = champ.healthPercent;
    alive = champ.alive;

    clearTime = world.time;
  }
}

dynamic main(List<String> args) async {
  handleCommonArgs(args);

  Creator creator = await Creator.loadLatest();
  ChampionGG championGG = await ChampionGG.loadExampleData(creator.dragon);

  List<String> champNames = creator.dragon.champs.loadChampNames();
  List<_Calculate> results = champNames
      .map((champName) {
        return new _Calculate(
          creator,
          championGG,
          champName,
        );
      })
      .where((r) => r.startingSkill != null)
      .toList();
  results.sort((a, b) {
    if (a.alive != b.alive) return a.alive ? 1 : -1;
    if (a.hpPercent != b.hpPercent) return a.hpPercent.compareTo(b.hpPercent);
    if (a.clearTime != b.clearTime) return a.clearTime.compareTo(b.clearTime);
    return 0;
  });

  TableLayout layout = new TableLayout([2, 13, 11, 6]);
  layout.printRow(['', 'Name', 'HP', 'Time']);
  layout.printDivider();

  String hpString(var r) {
    if (!r.alive) return '-';
    return "${r.hp.round()} (${(100 * r.hpPercent).toStringAsFixed(1)}%)";
  }

  for (var r in results) {
    String effectsStatus = (r.hasPassive ? 'P' : ' ') +
        (r.hasSkillEffects ? r.startingSkill.char : ' ');
    layout.printRow([
      effectsStatus,
      r.champName,
      hpString(r),
      "${r.clearTime.round()}s",
    ]);
  }

  // Try each champ
  // compute clear time
  // with each item.
}
