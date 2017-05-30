#!/usr/local/bin/dart
import 'dart:convert';
import 'dart:io';

import 'package:lol_duel/creator.dart';
import 'package:lol_duel/lolsim.dart';
import 'package:lol_duel/mastery_pages.dart';
import 'package:lol_duel/rune_pages.dart';
import 'package:lol_duel/utils/cli_table.dart';
import 'package:lol_duel/utils/common_args.dart';

void addSkillPoints(Mob champ) {
  if (champ.name == 'Volibear')
    champ.addSkillPointTo(SpellKey.w);
  else
    champ.addSkillPointTo(SpellKey.w);
}

class _Calculate {
  String champName;
  bool hasEffects;
  bool alive;
  double hp;
  double hpPercent;
  double clearTime;

  _Calculate(Creator creator, this.champName, RunePage runePage,
      MasteryPage masteryPage) {
    Mob makeChamp() {
      return creator.champs.championByName(champName)..updateStats();
    }

    Item item(String name) => creator.items.itemByName(name);

    Mob champ = makeChamp();
    champ.runePage = runePage;
    champ.masteryPage = masteryPage;
    champ.addItem(item("Hunter's Machete"));
    addSkillPoints(champ);

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
    hp = champ.currentHp;
    hpPercent = champ.healthPercent;
    alive = champ.alive;

    clearTime = world.time;
  }
}

dynamic main(List<String> args) async {
  handleCommonArgs(args);

  Creator creator = await Creator.loadLatest();

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
    return new _Calculate(creator, champName, runePage, masteryPage);
  }).toList();
  results.sort((a, b) {
    if (a.alive != b.alive) return a.alive ? 1 : -1;
    if (a.hpPercent != b.hpPercent) return a.hpPercent.compareTo(b.hpPercent);
    if (a.clearTime != b.clearTime) return a.clearTime.compareTo(b.clearTime);
    return 0;
  });

  TableLayout layout = new TableLayout([1, 13, 11, 6]);
  layout.printRow(['P', 'Name', 'HP', 'Time']);
  layout.printDivider();

  String hpString(var r) {
    if (!r.alive) return '-';
    return "${r.hp.round()} (${(100 * r.hpPercent).toStringAsFixed(1)}%)";
  }

  for (var r in results) {
    layout.printRow([
      r.hasEffects ? '*' : ' ',
      r.champName,
      hpString(r),
      "${r.clearTime.round()}s",
    ]);
  }

  // Try each champ
  // compute clear time
  // with each item.
}
