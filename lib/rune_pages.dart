import 'lolsim.dart';
import 'dragon.dart';
import 'stat_constants.dart';

typedef double _Combiner(double a, double b);
double _Add(double a, double b) => a + b;
double _Multiply(double a, double b) => a * b;

class StatCollector {
  Map<String, double> combined = {};

  final Map<String, _Combiner> _combiners = {
    FlatArmorMod: _Add,
    PercentSpellVampMod: _Multiply,
    FlatPhysicalDamageMod: _Add,
    FlatArmorModPerLevel: _Add,
    FlatSpellBlockModPerLevel: _Add,
  };

  void add(Map<String, num> stats) {
    stats.forEach((key, value) {
      double current = combined[key];
      if (current == null) {
        combined[key] = value;
        return;
      }
      _Combiner combiner = _combiners[key];
      if (combiner == null)
        print("missing $key");
      else
        combined[key] = combiner(current, value);
    });
  }
}

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

  String get summaryString {
    String summary = "$name\n";
    StatCollector collector = new StatCollector();
    runes.forEach((rune) => collector.add(rune.stats));
    collector.combined.forEach(
        (key, value) => summary += '$key : ${value.toStringAsFixed(3)}\n');
    return summary;
  }

  String toString() {
    return "$name";
  }
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
