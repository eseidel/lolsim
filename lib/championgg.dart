import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';

import 'dragon/dragon.dart';
import 'role.dart';

final Logger _log = new Logger('championgg');

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
  final String mostCommonMasteriesHash;
  final String mostCommonRunesHash;
  final List<String> mostCommonStartingItemIds;

  RoleEntry.fromJson(Map json)
      : key = json['championId'].toString(),
        percentRolePlayed = json['percentRolePlayed'],
        role = new Role.fromChampionGG(json['role']),
        mostCommonSkillOrder = _splitHash(
            json['hashes']['skillorderhash']['highestCount']['hash']),
        mostCommonMasteriesHash =
            json['hashes']['masterieshash']['highestCount']['hash'],
        mostCommonRunesHash =
            json['hashes']['runehash']['highestCount']['hash'],
        mostCommonStartingItemIds = _splitHash(
            json['hashes']['firstitemshash']['highestCount']['hash']);

  static List<String> _splitHash(String hash) {
    return hash.split('-').sublist(1);
  }
}

class ChampionGG {
  List<Map> jsonEntries;
  List<ChampionStats> championStats;

  ChampionGG(this.jsonEntries, DragonData dragon) {
    Map<String, ChampionStats> statsByKey = {};
    jsonEntries.forEach((Map roleJson) {
      RoleEntry role;
      try {
        role = new RoleEntry.fromJson(roleJson);
      } catch (e) {
        MobDescription champ =
            dragon.champs.championByKey(roleJson['championId'].toString());
        _log.warning(
            "Error loading champion.gg data for ${champ.name} ${roleJson['role']}");
        return;
      }
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

  Iterable<RoleEntry> statsMatchingRole(Role role) sync* {
    for (var stats in championStats) {
      var entry = stats.entryForRole(Role.jungle);
      if (entry != null) yield entry;
    }
  }

  Iterable<RoleEntry> statsForWithPrimaryRole(Role role) sync* {
    for (var stats in championStats) {
      var entry = stats.mostPlayed;
      if (entry.role == role) yield entry;
    }
  }

  // FIXME: Another way would be to teach the precache script to
  // download this and then have a load-latest method.
  static Future<ChampionGG> loadExampleData(DragonData dragon) async {
    File jsonFile = new File('examples/championgg.json');
    List<Map> json = JSON.decode(await jsonFile.readAsString());
    return new ChampionGG(json, dragon);
  }
}
