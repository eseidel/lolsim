#!/usr/local/bin/dart
import 'package:lol_duel/championgg.dart';
import 'package:lol_duel/championgg_utils.dart';
import 'package:lol_duel/creator.dart';
import 'package:lol_duel/dragon/dragon.dart';
import 'package:lol_duel/items.dart';
import 'package:lol_duel/lolsim.dart';
import 'package:lol_duel/monsters.dart';
import 'package:lol_duel/planning.dart';
import 'package:lol_duel/role.dart';
import 'package:lol_duel/summoners.dart';
import 'package:lol_duel/utils/cli_table.dart';
import 'package:lol_duel/utils/common_args.dart';

typedef CreateChamp = Mob Function();

class _Calculate {
  final MonsterType monsterType;

  bool alive;
  double hp;
  double hpPercent;
  double mana;
  double manaPercent;
  double clearTime;

  _Calculate(
      CreateChamp createChamp, this.monsterType, bool showDamageSummaries) {
    Mob champ = createChamp();
    Mob dragon = createMonster(monsterType);
    if (showDamageSummaries) {
      champ.shouldRecordDamage = true;
      dragon.shouldRecordDamage = true;
    }
    World world = new World(
      blues: [champ],
      reds: [dragon],
      critProvider: new PredictableCrits(),
    );
    world.tickUntil(World.oneSideDies);
    if (showDamageSummaries) {
      print(champ.damageLog.summaryString);
      print(dragon.damageLog.summaryString);
    }

    hp = champ.currentHp;
    hpPercent = champ.healthPercent;
    alive = champ.alive;

    clearTime = world.time;
    mana = champ.currentMp;
    manaPercent = champ.manaPercent;
  }
}

String dragonTypeToString(MonsterType type) =>
    type.toString().split('.')[1].replaceAll('Drake', '');

dynamic main(List<String> args) async {
  handleCommonArgs(args);

  Creator creator = await Creator.loadLatest();
  ChampionGG championGG = await ChampionGG.loadExampleData(creator.dragon);
  String championName = 'Amumu';
  int level = 4;
  bool showDamageSummaries = true;
  ItemDescription itemNamed(String name) => creator.items.itemByName(name);

  CreateChamp createChamp = () {
    Mob champ = creator.champs.championByName(championName);
    champ.level = level;
    champ.planner = plannerFor(champ, Role.jungle);

    ChampionStats champStats = championGG.statsForChampionName(championName);
    RoleEntry jungleStats = champStats.entryForRole(Role.jungle);

    champ.summoners = new SummonerBook();
    champ.summoners.d = createSummoner(SummonerType.smite, champ);
    (champ.summoners.d.effects as Smite).chargesBuff.charges = 2;

    champ.masteryPage = masteriesFromHash(
        creator.dragon.masteries, jungleStats.mostCommonMasteriesHash);
    champ.masteryPage.name = 'Champion.gg most common';

    champ.runePage =
        runesFromHash(creator.dragon.runes, jungleStats.mostCommonRunesHash);
    champ.runePage.name = 'Champion.gg most common';

    champ.addItem(itemNamed(ItemNames.HuntersMachete));
    champ.addItem(itemNamed(ItemNames.HuntersTalisman));
    champ.addItem(itemNamed(ItemNames.BamisCinder));
    champ.addItem(itemNamed(ItemNames.RefillablePotion));

    champ.addBuff(new CrestOfInsight(champ));
    // champ.addBuff(new CrestOfCinders(champ));

    jungleStats.mostCommonSkillOrder.sublist(0, level).forEach((skillChar) {
      champ.addSkillPointTo(new SpellKey.fromChar(skillChar));
    });
    return champ;
  };

  print(createChamp().statsSummary());

  List<MonsterType> dragons = [
    MonsterType.cloudDrake,
    MonsterType.infernalDrake,
    MonsterType.mountainDrake,
    MonsterType.oceanDrake,
  ];

  List<_Calculate> results = [];
  dragons.forEach((MonsterType dragon) {
    results.add(new _Calculate(createChamp, dragon, showDamageSummaries));
  });

  results.sort((a, b) {
    if (a.alive != b.alive) return a.alive ? 1 : -1;
    if (a.hpPercent != b.hpPercent) return a.hpPercent.compareTo(b.hpPercent);
    if (a.clearTime != b.clearTime) return a.clearTime.compareTo(b.clearTime);
    return 0;
  });

  TableLayout layout = new TableLayout([8, 11, 11, 6]);
  layout.printRow(['Dragon', 'HP', 'MP', 'Time']);
  layout.printDivider();

  String percentString(bool alive, double value, double percent) {
    if (!alive) return '-';
    return "${value.round()} (${(100 * percent).toStringAsFixed(1)}%)";
  }

  for (var r in results) {
    layout.printRow([
      dragonTypeToString(r.monsterType),
      percentString(r.alive, r.hp, r.hpPercent),
      percentString(r.alive, r.mana, r.manaPercent),
      "${r.clearTime.round()}s",
    ]);
  }
}
