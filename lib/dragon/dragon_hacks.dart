import 'stat_constants.dart';

Map<String, num> hackInMissingStats(String name, Map<String, num> stats) {
  Map<String, num> addMissingStat(
      Map<String, num> stats, Map<String, num> toAdd) {
    Map<String, num> newStats = new Map.from(stats);
    toAdd.forEach((key, value) {
      assert(!stats.containsKey(key), 'Hack for $name, $key not needed!');
      newStats[key] = value;
    });
    return newStats;
  }

  if (name == 'Aether Wisp') {
    return addMissingStat(stats, {PercentMovementSpeedMod: 0.05});
  }
  return stats;
}
