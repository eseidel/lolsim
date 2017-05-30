import 'dart:io';
import 'dart:convert';

import 'package:yaml/yaml.dart';

import '../creator.dart';
import '../mastery_pages.dart';
import '../rune_pages.dart';
import '../lolsim.dart';

class Duel {
  List<Mob> reds;
  List<Mob> blues;

  Duel({this.reds, this.blues});

  List<Mob> get allMobs => []..addAll(reds)..addAll(blues);
}

class DuelLoader {
  final Creator creator;

  DuelLoader(this.creator);

  void addMinions(List<Mob> mobs, int count, MinionType type) {
    if (count != null)
      mobs.addAll(new List.generate(count, (int) => Mob.createMinion(type)));
  }

  MasteryPage loadMasteryPage(YamlMap yamlMasteries) {
    String masteriesJson = new File(yamlMasteries['path']).readAsStringSync();
    MasteryPageList pageList = new MasteryPageList.fromJson(
      JSON.decode(masteriesJson),
      creator.dragon.masteries,
    );
    return pageList.pages[yamlMasteries['page_index']];
  }

  RunePage loadRunePage(YamlMap yamlRunes) {
    String runesJson = new File(yamlRunes['path']).readAsStringSync();
    RunePageList pageList = new RunePageList.fromJson(
      JSON.decode(runesJson),
      creator.runes,
    );
    return pageList.pages[yamlRunes['page_index']];
  }

  Mob loadChampion(YamlMap yamlMob) {
    Mob mob = creator.champs.championByName(yamlMob['name']);
    mob.level = yamlMob['level'] ?? 1;
    YamlList yamlItems = yamlMob['items'];
    if (yamlItems != null) {
      yamlItems.forEach(
          (String itemName) => mob.addItem(creator.items.itemByName(itemName)));
    }
    YamlMap yamlMasteries = yamlMob['masteries'];
    if (yamlMasteries != null) {
      mob.masteryPage = loadMasteryPage(yamlMasteries);
    }
    YamlMap yamlRunes = yamlMob['runes'];
    if (yamlRunes != null) {
      mob.runePage = loadRunePage(yamlRunes);
    }
    return mob;
  }

  Mob loadMonster(YamlMap yamlMob) {
    MonsterType type = {
      'Blue Sentinel': MonsterType.blueSentinal,
    }[yamlMob['name']];
    assert(type != null);
    Mob mob = Mob.createMonster(type);
    mob.level = yamlMob['level'] ?? 1;
    return mob;
  }

  List<Mob> loadTeam(Team color, YamlMap yamlTeam) {
    List<Mob> mobs = [];
    YamlList yamlChampions = yamlTeam['champions'];
    if (yamlChampions != null) mobs.addAll(yamlChampions.map(loadChampion));
    YamlMap yamlMinions = yamlTeam['minions'];
    if (yamlMinions != null) {
      addMinions(mobs, yamlMinions['siege'], MinionType.siege);
      addMinions(mobs, yamlMinions['caster'], MinionType.caster);
      addMinions(mobs, yamlMinions['melee'], MinionType.melee);
      addMinions(mobs, yamlMinions['super'], MinionType.superMinion);
    }
    YamlList yamlMonsters = yamlTeam['monsters'];
    if (yamlMonsters != null) mobs.addAll(yamlMonsters.map(loadMonster));

    mobs.forEach((mob) {
      mob.team = color;
    });
    return mobs;
  }

  Duel duelFromYaml(YamlMap yamlDuel) {
    Duel duel = new Duel();
    yamlDuel.forEach((String key, YamlMap team) {
      switch (key) {
        case 'red':
          duel.reds = loadTeam(Team.red, team);
          break;
        case 'blue':
          duel.blues = loadTeam(Team.blue, team);
          break;
        default:
          assert(false);
      }
    });
    return duel;
  }

  Duel duelFromYamlPath(String path) {
    return duelFromYaml(loadYaml(new File(path).readAsStringSync()));
  }
}