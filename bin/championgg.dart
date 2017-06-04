#!/usr/local/bin/dart
import 'dart:convert';
import 'dart:io';

import 'package:lol_duel/utils/common_args.dart';
import 'package:lol_duel/utils/cli_table.dart';
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

String _toPercentString(double value) {
  return "${(100 * value).toStringAsFixed(1)}%";
}

String _roleShortName(String roleName) {
  return {
    'TOP': 'Top',
    'MIDDLE': 'Mid',
    'JUNGLE': 'Jung',
    'DUO_CARRY': 'ADC',
    'DUO_SUPPORT': 'Support',
  }[roleName];
}

dynamic main(List<String> args) async {
  handleCommonArgs(args);
  File jsonFile = new File('examples/championgg.json');
  List<Map> json = JSON.decode(jsonFile.readAsStringSync());
  DragonData dragon = await DragonData.loadLatest();
  Map<String, ChampionStats> statsByKey = {};

  json.forEach((Map roleJson) {
    RoleEntry role = new RoleEntry.fromJson(roleJson);
    ChampionStats stats = statsByKey.putIfAbsent(
      role.key,
      () => new ChampionStats(dragon.champs.championByKey(role.key)),
    );
    stats.roles.add(role);
  });
  TableLayout layout = new TableLayout([15, 10, 10, 10]);
  layout.printRow(['Champion', 'Role', '% as Role', 'First Skill']);
  layout.printDivider();

  List<ChampionStats> champStats = statsByKey.values.toList();
  champStats.sort((a, b) => a.champ.name.compareTo(b.champ.name));

  champStats.forEach((stats) {
    RoleEntry mostPlayed = stats.mostPlayed;
    String mostPlayedString = _toPercentString(mostPlayed.percentRolePlayed);
    layout.printRow([
      stats.champ.name,
      _roleShortName(mostPlayed.role),
      mostPlayedString,
      mostPlayed.mostCommonSkillOrder.first,
    ]);
  });
}
