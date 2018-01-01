import 'mob.dart';
import 'creator.dart';
import 'dragon/dragon.dart';

class RunePage {
  String name;
  List<Rune> runes;

  RunePage({this.name, this.runes});

  RunePage.fromJson(Map<String, dynamic> json, RuneFactory library)
      : name = json['name'] {
    runes =
        json['slots'].map((rune) => library.runeById(rune['runeId'])).toList();
  }

  void logAnyMissingEffects() {
    runes.forEach((rune) => rune.logIfMissingEffects());
  }

  String get summaryString => 'rune page';

  Rune get keystone {
    assert(runes[0].description.slot == RuneSlot.keystone);
    return runes[0];
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
