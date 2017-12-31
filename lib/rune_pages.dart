import 'mob.dart';
import 'creator.dart';

class RunePage {
  String name;
  List<Rune> runes;

  RunePage({this.name, this.runes});

  RunePage.fromJson(Map<String, dynamic> json, RuneFactory library)
      : name = json['name'] {
    runes =
        json['slots'].map((rune) => library.runeById(rune['runeId'])).toList();
  }

  void logAnyMissingStats() {
    runes.forEach((rune) => rune.logIfMissingStats());
  }

  Map<String, double> collectStats() {
    Map<String, double> stats = {};
    runes.forEach((rune) {
      if (rune.statName == null) return;
      double current = stats[rune.statName];
      if (current == null)
        stats[rune.statName] = rune.statValue;
      else
        stats[rune.statName] = current + rune.statValue;
    });
    return stats;
  }

  String get summaryString {
    Map<String, double> stats = collectStats();
    Iterable<String> summaries = stats.keys.map((String statName) =>
        shortStringForStatValue(statName, stats[statName]));
    return summaries.join(', ');
  }

  @override
  String toString() => name;
}

class RunePageList {
  List<RunePage> pages;
  int summonerId;

  RunePageList.fromJson(Map<String, dynamic> json, RuneFactory library)
      : summonerId = json['summonerId'] {
    assert(json.keys.length == 1);
    Map<String, dynamic> summonerPageSet = json.values.first;

    pages = summonerPageSet['pages']
        .map(
          (pageJson) => new RunePage.fromJson(
                pageJson as Map<String, dynamic>,
                library,
              ),
        )
        .toList();
  }
}
