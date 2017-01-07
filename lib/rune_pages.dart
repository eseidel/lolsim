import 'lolsim.dart';
import 'dragon.dart';

class RunePage {
  String name;
  List<Rune> runes;

  RunePage({this.name, this.runes});

  RunePage.fromJson(Map<String, dynamic> json, RuneFactory library)
      : name = json['name'] {
    runes =
        json['slots'].map((rune) => library.runeById(rune['runeId'])).toList();
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
