import 'dart:io';
import 'dart:async';
import 'package:lolsim/lolsim.dart';
import 'package:yaml/yaml.dart';

class Duel {
  List<Mob> reds;
  List<Mob> blues;

  List<Mob> get allMobs => []..addAll(reds)..addAll(blues);
}

class DuelLoader {
  DuelLoader(this.champFactory, this.itemFactory);

  ChampionFactory champFactory;
  ItemFactory itemFactory;

  List<Mob> loadTeam(Team color, YamlMap yamlTeam) {
    return yamlTeam['mobs'].map((YamlMap yamlMob) {
      assert(yamlMob['type'] == 'champion');
      Mob champ = champFactory.championByName(yamlMob['name']);
      champ.team = color;
      champ.level = yamlMob.containsKey('level') ? yamlMob['level'] : 1;
      return champ;
    }).toList();
  }

  Duel duelFromYaml(YamlMap yamlDuel) {
    Duel duel = new Duel();
    yamlDuel.forEach((String key, YamlMap team) {
      switch(key) {
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
