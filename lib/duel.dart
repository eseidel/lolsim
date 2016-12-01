import 'dart:io';
import 'dart:async';
import 'dragon.dart';
import 'package:yaml/yaml.dart';

class Duel {
  List<Mob> reds;
  List<Mob> blues;

  List<Mob> get allMobs => []..addAll(reds)..addAll(blues);
}

enum MinionType { melee, caster, siege, superMinion }

class DuelLoader {
  DuelLoader(DragonData data)
      : champFactory = data.champs;

  final ChampionFactory champFactory;

  void addMinions(List<Mob> mobs, int count, MinionType type) {
    // FIXME: Implement
  }

  List<Mob> loadTeam(Team color, YamlMap yamlTeam) {
    YamlList champions = yamlTeam['champions'];
    List<Mob> mobs = champions.map((YamlMap yamlMob) {
      Mob mob = champFactory.championByName(yamlMob['name']);
      mob.level = yamlMob['level'] ?? 1;
      return mob;
    }).toList();
    YamlMap yamlMinions = yamlTeam['minions'];
    if (yamlMinions != null) {
      addMinions(mobs, yamlMinions['siege'], MinionType.siege);
      addMinions(mobs, yamlMinions['caster'], MinionType.caster);
      addMinions(mobs, yamlMinions['melee'], MinionType.melee);
    }
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

  Future<Duel> duelFromYamlPath(String path) async {
    return duelFromYaml(loadYaml(await new File(path).readAsString()));
  }
}
