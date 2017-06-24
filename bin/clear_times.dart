#!/usr/local/bin/dart
import 'dart:convert';
import 'dart:io';

import 'package:lol_duel/creator.dart';
import 'package:lol_duel/lolsim.dart';
import 'package:lol_duel/mastery_pages.dart';
import 'package:lol_duel/monsters.dart';
import 'package:lol_duel/rune_pages.dart';
import 'package:lol_duel/utils/cli_table.dart';
import 'package:lol_duel/utils/common_args.dart';
import 'package:lol_duel/championgg.dart';

class _Calculate {
  String champName;
  bool hasPassive;
  bool hasSkillEffects;
  SpellKey startingSkill;
  bool alive;
  double hp;
  double hpPercent;
  double clearTime;

  _Calculate(Creator creator, this.champName, RunePage runePage,
      MasteryPage masteryPage, ChampionGG championGG) {
    Mob makeChamp() {
      return creator.champs.championByName(champName)..updateStats();
    }

    Item item(String name) => creator.items.itemByName(name);

    Mob champ = makeChamp();
    champ.runePage = runePage;
    champ.masteryPage = masteryPage;
    champ.addItem(item("Hunter's Machete"));
    startingSkill = _mostCommonJungleSkillStart(champ, championGG);
    champ.addSkillPointTo(startingSkill);

    hasSkillEffects = champ.spells.spellForKey(startingSkill).effects != null;
    hasPassive = champ.championEffects != null;
    computeClearTime(creator, champ);
  }

  SpellKey _mostCommonJungleSkillStart(Mob champ, ChampionGG championGG) {
    ChampionStats stats = championGG.statsForChampionName(champ.name);
    if (stats == null) return SpellKey.q;
    RoleEntry entry = stats.entryForRole(Role.jungle);
    if (entry == null) entry = stats.mostPlayed;
    return new SpellKey.fromChar(entry.mostCommonSkillOrder.first);
  }

  void computeClearTime(Creator creator, Mob champ) {
    // Should do more than just blue sentinel.
    // Need to handle travel time
    // Need to handle levels.
    Mob monster = createMonster(MonsterType.blueSentinal);
    World world = new World(
      reds: [champ],
      blues: [monster],
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

  String runesString = new File('examples/rune_pages.json').readAsStringSync();
  RunePageList runePages = new RunePageList.fromJson(
    JSON.decode(runesString),
    creator.runes,
  );
  RunePage runePage = runePages.pages[2];

  String masteriesString =
      new File('examples/mastery_pages.json').readAsStringSync();
  MasteryPageList masteryPages = new MasteryPageList.fromJson(
    JSON.decode(masteriesString),
    creator.dragon.masteries,
  );
  MasteryPage masteryPage = masteryPages.pages[11];

  List<String> champNames = creator.dragon.champs.loadChampNames();
  List<_Calculate> results = champNames.map((champName) {
    return new _Calculate(
      creator,
      champName,
      runePage,
      masteryPage,
      championGG,
    );
  }).toList();
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
