import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

import '../creator.dart';
import '../mob.dart';
import '../minions.dart';
import '../monsters.dart';
import '../rune_pages.dart';

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
      mobs.addAll(new List.generate(count, (int) => createMinion(type)));
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
    mob.jumpToLevel(yamlMob['level'] ?? 1);
    YamlList yamlItems = yamlMob['items'];
    if (yamlItems != null) {
      yamlItems.forEach(
          (String itemName) => mob.addItem(creator.items.itemByName(itemName)));
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
      'Red Brambleback': MonsterType.redBrambleback,
    }[yamlMob['name']];
    assert(type != null);
    Mob mob = createMonster(type);
    mob.jumpToLevel(yamlMob['level'] ?? 1);
    return mob;
  }

  List<Mob> loadTeam(Team color, YamlMap yamlTeam) {
    List<Mob> mobs = [];
    YamlList yamlChampions = yamlTeam['champions'];
    if (yamlChampions != null)
      mobs.addAll(yamlChampions.map<Mob>(loadChampion));
    YamlMap yamlMinions = yamlTeam['minions'];
    if (yamlMinions != null) {
      addMinions(mobs, yamlMinions['siege'], MinionType.siege);
      addMinions(mobs, yamlMinions['caster'], MinionType.caster);
      addMinions(mobs, yamlMinions['melee'], MinionType.melee);
      addMinions(mobs, yamlMinions['super'], MinionType.superMinion);
    }
    YamlList yamlMonsters = yamlTeam['monsters'];
    if (yamlMonsters != null) mobs.addAll(yamlMonsters.map<Mob>(loadMonster));

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
