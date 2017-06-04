import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:lol_duel/dragon/dragon.dart';

class ChampionStats {
  final MobDescription champ;
  List<RoleEntry> roles = [];
  ChampionStats(this.champ);

  RoleEntry get mostPlayed {
    double maxValue = 0.0;
    RoleEntry found;
    roles.forEach((RoleEntry role) {
      if (role.percentRolePlayed > maxValue) {
        maxValue = role.percentRolePlayed;
        found = role;
      }
    });
    return found;
  }
}

class RoleEntry {
  final double percentRolePlayed;
  final String key;
  final String role;
  final List<String> mostCommonSkillOrder;

  RoleEntry.fromJson(Map json)
      : key = json['championId'].toString(),
        percentRolePlayed = json['percentRolePlayed'],
        role = json['role'],
        mostCommonSkillOrder = _parseSkillOrderHash(
            json['hashes']['skillorderhash']['highestCount']['hash']);

  static List<String> _parseSkillOrderHash(String hash) {
    return hash.split('-').sublist(1);
  }
}

class ChampionGG {
  List jsonEntries;
  List championStats;

  ChampionGG(this.jsonEntries, DragonData dragon) {
    Map<String, ChampionStats> statsByKey = {};
    jsonEntries.forEach((Map roleJson) {
      RoleEntry role = new RoleEntry.fromJson(roleJson);
      ChampionStats stats = statsByKey.putIfAbsent(
        role.key,
        () => new ChampionStats(dragon.champs.championByKey(role.key)),
      );
      stats.roles.add(role);
    });
    championStats = statsByKey.values.toList();
    // Sorted for no particularly good reason.
    championStats.sort((a, b) => a.champ.name.compareTo(b.champ.name));
  }

  static Future<ChampionGG> loadExampleData(DragonData dragon) async {
    File jsonFile = new File('examples/championgg.json');
    List<Map> json = JSON.decode(await jsonFile.readAsString());
    return new ChampionGG(json, dragon);
  }
}
