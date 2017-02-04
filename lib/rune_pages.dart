import 'lolsim.dart';
import 'creator.dart';

// typedef double _Combiner(double a, double b);
// double _Add(double a, double b) => a + b;
// double _Multiply(double a, double b) => a * b;

// final Map<String, _Combiner> _combiners = {
//   FlatArmorMod: _Add,
//   PercentSpellVampMod: _Multiply,
//   FlatPhysicalDamageMod: _Add,
//   FlatArmorModPerLevel: _Add,
//   FlatSpellBlockModPerLevel: _Add,
//   PercentCooldownMod: _Add,
// };

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
    String summary = "$name\n";
    collectStats().forEach(
        (key, value) => summary += '$key : ${value.toStringAsFixed(3)}\n');
    return summary;
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
