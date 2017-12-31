import 'package:meta/meta.dart';

import 'dragon/dragon.dart';
import 'mob.dart';

class MasteryPage {
  String name;
  List<Mastery> masteries;

  MasteryPage({this.name, @required this.masteries});

  MasteryPage.fromJson(Map<String, dynamic> json, MasteryLibrary library)
      : name = json['name'] {
    masteries = json['masteries'].map((mastery) {
      return new Mastery(library.masteryById(mastery['id']), mastery['rank']);
    }).toList();
  }

  void initForChamp(Mob champ) {
    masteries.forEach((Mastery mastery) {
      mastery.initForChamp(champ);
    });
  }

  void logAnyMissingEffects() {
    masteries.forEach((mastery) => mastery.logIfMissingEffects());
  }

  int countForTree(MasteryTree tree) {
    return masteries.fold(
        0, (c, m) => (m.description.tree == tree) ? c + m.rank : c);
  }

  String get countsString {
    return "${countForTree(MasteryTree.ferocity)}/"
        "${countForTree(MasteryTree.cunning)}/"
        "${countForTree(MasteryTree.resolve)}";
  }

  @override
  String toString() => "\"$name\" ($countsString)";
}

class MasteryPageList {
  List<MasteryPage> pages;
  int summonerId;

  MasteryPageList.fromJson(Map<String, dynamic> json, MasteryLibrary library)
      : summonerId = json['summonerId'] {
    assert(json.keys.length == 1);
    Map<String, dynamic> summonerPageSet = json.values.first;

    pages = summonerPageSet['pages']
        .map(
          (pageJson) => new MasteryPage.fromJson(
                pageJson as Map<String, dynamic>,
                library,
              ),
        )
        .toList();
  }
}
