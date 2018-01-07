#!/usr/local/bin/dart
import 'package:lol_duel/championgg.dart';
import 'package:lol_duel/creator.dart';
import 'package:lol_duel/lolsim.dart';
import 'package:lol_duel/monsters.dart';
import 'package:lol_duel/planning.dart';
import 'package:lol_duel/role.dart';
import 'package:lol_duel/summoners.dart';
import 'package:lol_duel/utils/cli_table.dart';
import 'package:lol_duel/utils/common_args.dart';
import 'package:lol_duel/champions/all.dart';
import 'package:args/args.dart';
import 'dart:collection';

typedef CreateChamp = Mob Function(String champName);

class _Calculate {
  String champName;
  bool alive;
  String killer;
  double hp;
  double hpPercent;
  double clearTime;
  List<SpellKey> skillOrder;
  List<CampType> route;
  bool hasPassive;
  bool hasSkillEffects;
  String keystone;
  String itemsString;

  _Calculate(
      Creator creator, ChampionGG championGG, this.champName, this.route) {
    Mob champ = createChamp(creator, championGG, this.champName);
    if (champ == null) return;
    computeClearTime(champ);
    hasPassive = haveImplementedChampionPassive(champ.id);
    hasSkillEffects = champ.spells.spellForKey(startingSkill).effects != null;
  }

  SpellKey get startingSkill => skillOrder.first;

  Mob createChamp(Creator creator, ChampionGG championGG, String championName) {
    Mob champ = creator.champs.championByName(championName);
    ChampionStats champStats = championGG.statsForChampionName(championName);
    RoleEntry jungleStats = champStats.entryForRole(Role.jungle);
    if (jungleStats == null) return null;

    champ.summoners = new SummonerBook();
    champ.summoners.d = createSummoner(SummonerType.smite, champ);

    champ.runePage = creator.runes
        .pageFromChampionGGHash(champ, jungleStats.mostCommonRunesHash);
    keystone = champ.runePage.keystone.shortName;
    if (champ.runePage.keystone.effects == null) keystone += '*';

    jungleStats.mostCommonStartingItemIds.forEach((itemId) {
      champ.addItem(creator.items.itemById(itemId));
    });
    itemsString = _stringForItems(champ.items);

    skillOrder = jungleStats.mostCommonSkillOrder
        .map((String char) => new SpellKey.fromChar(char))
        .toList();
    champ.addSkillPointTo(skillOrder[0]);

    champ.planner = plannerFor(champ, Role.jungle);
    champ.addBuff(new SkillPlanner(champ, skillOrder));

    return champ;
  }

  void computeClearTime(Mob champ) {
    World world = new World(
      blues: [champ],
      critProvider: new PredictableCrits(),
    );

    CampType lastCamp;
    List<CampType> remainingRoute = new List.from(route);
    while (champ.alive && remainingRoute.isNotEmpty) {
      CampType currentCamp = remainingRoute.removeAt(0);
      if (lastCamp != null) {
        world.tickFor(walkingTime(lastCamp, currentCamp));
      }
      List<Mob> camp = createCamp(currentCamp);
      camp.forEach(
          (Mob mob) => mob.team = Team.red); // FIXME: Should not be needed.
      world.addMobs(camp);
      world.tickUntil(World.oneSideDies);
      lastCamp = currentCamp;
    }

    hp = champ.currentHp;
    hpPercent = champ.healthPercent;
    alive = champ.alive;
    if (!alive) killer = campTypeToString(lastCamp);

    clearTime = world.time;
  }

  String _stringForItems(List<Item> items) {
    String _name(Item item) {
      String name = item.shortName;
      // This logic won't work right with plurals below.
      if (item.effects == null && item.stats.isEmpty) name += '*';
      return name;
    }

    Map<String, int> itemCounts = new LinkedHashMap<String, int>();
    items.forEach((item) {
      String name = _name(item);
      itemCounts.putIfAbsent(name, () => 0);
      itemCounts[name] += 1;
    });
    return itemCounts.keys.map((key) {
      int count = itemCounts[key];
      if (count > 1) return "$count " + simpleEnglishPlural(key, count);
      return key;
    }).join(', ');
  }
}

dynamic main(List<String> args) async {
  ArgResults argResults = handleCommonArgs(args);

  Creator creator = await Creator.loadLatest();
  ChampionGG championGG = await ChampionGG.loadExampleData(creator.dragon);

  // List<CampType> route = [CampType.raptors, CampType.red, CampType.krugs];
  List<CampType> route = [CampType.blue, CampType.gromp, CampType.wolves];

  List<String> champNames = argResults.rest.isNotEmpty
      ? argResults.rest
      : creator.dragon.champs.loadChampNames();

  List<_Calculate> results = champNames
      .map((champName) {
        return new _Calculate(
          creator,
          championGG,
          champName,
          route,
        );
      })
      .where((r) => r.clearTime != null)
      .toList();
  results.sort((a, b) {
    if (a.alive != b.alive) return a.alive ? 1 : -1;
    if (a.hpPercent != b.hpPercent) return a.hpPercent.compareTo(b.hpPercent);
    if (a.clearTime != b.clearTime) return a.clearTime.compareTo(b.clearTime);
    return 0;
  });

  TableLayout layout = new TableLayout([2, 13, 11, 6, 13, 11]);
  layout.printRow(['', 'Name', 'HP', 'Time', 'Keystone', 'Items']);
  layout.printDivider();

  String hpString(var r) {
    if (!r.alive) return r.killer;
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
      r.keystone,
      r.itemsString,
    ]);
  }
}
