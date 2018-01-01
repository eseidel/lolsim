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

typedef CreateChamp = Mob Function(String champName);

class _Calculate {
  final String champName;
  final Plan plan;

  double clearTime;
  bool alive;
  double hp;
  double hpPercent;
  double mana;
  double manaPercent;
  double experiance;
  double gold;
  int level;

  _Calculate(
      Creator creator, ChampionGG championGG, this.champName, this.plan) {
    Mob champ = createChamp(creator, championGG, this.champName);
    if (champ == null) return;
    clearTime = computeClearTime(champ);

    // FIXME: maybe should just hold onto the champ instead?
    hp = champ.currentHp;
    hpPercent = champ.healthPercent;
    alive = champ.alive;
    mana = champ.currentMp;
    manaPercent = champ.manaPercent;
    experiance = champ.totalExperiance;
    gold = champ.currentGold;
    level = champ.level;
  }

  String get skillOrderString =>
      plan.skillOrder.sublist(0, level).map((key) => key.char).join('');

  String get routeString => plan.route.map((type) {
        String campString = campTypeToString(type);
        return campString[0].toUpperCase() + campString[1];
      }).join();
  Mob createChamp(Creator creator, ChampionGG championGG, String championName) {
    Mob champ = creator.champs.championByName(championName);
    ChampionStats champStats = championGG.statsForChampionName(championName);
    RoleEntry jungleStats = champStats.entryForRole(Role.jungle);
    if (jungleStats == null) return null;

    champ.summoners = new SummonerBook();
    champ.summoners.d = createSummoner(SummonerType.smite, champ);
    champ.runePage =
        runesFromHash(creator.dragon.runes, jungleStats.mostCommonRunesHash);

    jungleStats.mostCommonStartingItemIds.forEach((itemId) {
      champ.addItem(creator.items.itemById(itemId));
    });

    champ.addSkillPointTo(plan.skillOrder.first);

    champ.planner = plannerFor(champ, Role.jungle);
    champ.addBuff(new SkillPlanner(champ, plan.skillOrder));

    return champ;
  }

  double computeClearTime(Mob champ) {
    World world = new World(
      blues: [champ],
      critProvider: new PredictableCrits(),
    );

    CampType lastCamp;
    List<CampType> remainingRoute = new List.from(plan.route);
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
    return world.time;
  }
}

class Plan {
  final List<CampType> route;
  final List<SpellKey> skillOrder;
  Plan(this.route, this.skillOrder);
}

dynamic main(List<String> args) async {
  handleCommonArgs(args);

  Creator creator = await Creator.loadLatest();
  ChampionGG championGG = await ChampionGG.loadExampleData(creator.dragon);

  // Try different routes
  // Which may involve different skill orders
  List<SpellKey> wFirst = [SpellKey.w, SpellKey.e, SpellKey.q];
  List<SpellKey> eFirst = [SpellKey.w, SpellKey.e, SpellKey.q];

  List<Plan> plans = [
    new Plan([CampType.raptors, CampType.red], eFirst),
    new Plan([CampType.red, CampType.raptors], wFirst),
    new Plan([CampType.blue, CampType.gromp], wFirst),
    new Plan([CampType.blue, CampType.gromp, CampType.wolves], wFirst),
    new Plan([CampType.blue, CampType.gromp, CampType.wolves, CampType.raptors],
        wFirst),
  ];
  // Report time, hp, mana, smites, xp, gold, etc.
  String champName = 'Amumu';

  List<_Calculate> results = plans
      .map((plan) {
        return new _Calculate(
          creator,
          championGG,
          champName,
          plan,
        );
      })
      .where((r) => r.clearTime != null)
      .toList();

  results.sort((a, b) {
    if (a.alive != b.alive) return b.alive ? 1 : -1;
    if (a.clearTime != b.clearTime) return a.clearTime.compareTo(b.clearTime);
    if (a.hpPercent != b.hpPercent) return a.hpPercent.compareTo(b.hpPercent);
    return 0;
  });

  TableLayout layout = new TableLayout([4, 10, 10, 10, 10, 10, 10]);
  // FIXME: Should display smite and pot charges.
  layout.printRow(['', 'Route', 'Time', 'XP', 'Gold', 'HP', 'Mana']);
  layout.printDivider();

  String percentString(bool alive, double value, double percent) {
    if (!alive) return '-';
    return "${value.round()} (${(100 * percent).round()}%)";
  }

  for (var r in results) {
    layout.printRow([
      r.skillOrderString,
      r.routeString,
      "${r.clearTime.round()}s",
      '${r.experiance.floor()}',
      '${r.gold.floor()}',
      percentString(r.alive, r.hp, r.hpPercent),
      percentString(r.alive, r.mana, r.manaPercent),
    ]);
  }
}
