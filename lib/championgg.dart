import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:lol_duel/dragon/dragon.dart';

class Role {
  final String id;
  const Role(this.id);

  factory Role.fromChampionGG(String id) {
    return {
      top.id: top,
      mid.id: mid,
      jungle.id: jungle,
      support.id: support,
      adc.id: adc,
    }[id];
  }

  static const Role top = const Role('TOP');
  static const Role mid = const Role('MIDDLE');
  static const Role jungle = const Role('JUNGLE');
  static const Role support = const Role('DUO_SUPPORT');
  static const Role adc = const Role('DUO_CARRY');

  String get shortName {
    return {
      top.id: 'Top',
      mid.id: 'Mid',
      jungle.id: 'Jung',
      adc.id: 'ADC',
      support.id: 'Support',
    }[id];
  }
}

class ChampionStats {
  final MobDescription champ;
  List<RoleEntry> roles = [];
  ChampionStats(this.champ);

  RoleEntry entryForRole(Role role) =>
      roles.firstWhere((r) => (r.role == role), orElse: () => null);

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
  final Role role;
  final List<String> mostCommonSkillOrder;

  RoleEntry.fromJson(Map json)
      : key = json['championId'].toString(),
        percentRolePlayed = json['percentRolePlayed'],
        role = new Role.fromChampionGG(json['role']),
        mostCommonSkillOrder = _parseSkillOrderHash(
            json['hashes']['skillorderhash']['highestCount']['hash']);

  static List<String> _parseSkillOrderHash(String hash) {
    return hash.split('-').sublist(1);
  }
}

class ChampionGG {
  List<Map> jsonEntries;
  List<ChampionStats> championStats;

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

  ChampionStats statsForChampionName(String championName) =>
      championStats.firstWhere((stats) => stats.champ.name == championName,
          orElse: () => null);

  // FIXME: Another way would be to teach the precache script to
  // download this and then have a load-latest method.
  static Future<ChampionGG> loadExampleData(DragonData dragon) async {
    File jsonFile = new File('examples/championgg.json');
    List<Map> json = JSON.decode(await jsonFile.readAsString());
    return new ChampionGG(json, dragon);
  }
}
