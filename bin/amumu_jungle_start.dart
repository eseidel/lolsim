#!/usr/local/bin/dart
import 'package:lol_duel/championgg.dart';
import 'package:lol_duel/championgg_utils.dart';
import 'package:lol_duel/creator.dart';
import 'package:lol_duel/lolsim.dart';
import 'package:lol_duel/monsters.dart';
import 'package:lol_duel/utils/common_args.dart';
import 'package:lol_duel/utils/cli_table.dart';

typedef CreateChamp = Mob Function();

class _Calculate {
  final CampType campType;
  final SpellKey startingSkill;
  bool alive;
  double hp;
  double hpPercent;
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
  }
}

class CastSpell extends Action {
  Spell spell;
  CastSpell(this.spell) : super();

  @override
  void apply(World world) {
    spell.cast();
  }
}

bool castIfInRange(Mob mob, Spell spell, List<Action> actions) {
  if (!spell.canBeCast) return false;
  World world = World.current;
  bool inRange = world.enemiesWithin(mob, spell.range).isNotEmpty;
  bool shouldCast = inRange || spell.isActiveToggle;
  if (!shouldCast) return false;
  actions.add(new CastSpell(spell));
  return true;
}

List<Action> amumuJunglePlanner(Mob mob) {
  List<Action> actions = <Action>[];
  if (castIfInRange(mob, mob.spells.w, actions)) return actions;
  if (castIfInRange(mob, mob.spells.e, actions)) return actions;
  return defaultPlanner(mob);
}

dynamic main(List<String> args) async {
  handleCommonArgs(args);

  Creator creator = await Creator.loadLatest();
  ChampionGG championGG = await ChampionGG.loadExampleData(creator.dragon);
  String championName = 'Amumu';

  CreateChamp createChamp = () {
    Mob champ = creator.champs.championByName(championName);
    champ.planningFunction = amumuJunglePlanner;
    ChampionStats champStats = championGG.statsForChampionName(championName);
    RoleEntry jungleStats = champStats.entryForRole(Role.jungle);
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
  //   new _Calculate(createChamp, CampType.raptors, SpellKey.e)
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

  TableLayout layout = new TableLayout([2, 13, 11, 6]);
  layout.printRow(['', 'Camp', 'HP', 'Time']);
  layout.printDivider();

  String hpString(var r) {
    if (!r.alive) return '-';
    return "${r.hp.round()} (${(100 * r.hpPercent).toStringAsFixed(1)}%)";
  }

  for (var r in results) {
    layout.printRow([
      r.startingSkill.toString(),
      r.campType.toString(),
      hpString(r),
      "${r.clearTime.round()}s",
    ]);
  }
}
