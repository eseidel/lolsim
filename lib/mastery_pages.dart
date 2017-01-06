import 'lolsim.dart';
import 'dragon.dart';

class MasteryPage {
  String name;
  List<Mastery> masteries;

  MasteryPage({this.name, this.masteries});

  MasteryPage.fromJson(Map<String, dynamic> json, MasteryLibrary library)
      : name = json['name'] {
    masteries = json['masteries'].map((mastery) {
      MasteryDescription description = library.masteryById(mastery['id']);
      return new Mastery(description, mastery['rank']);
    }).toList();
  }

  void logMissingEffects() {
    masteries.forEach((mastery) => mastery.logMissingEffects());
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

  String toString() {
    return "$name ($countsString)";
  }
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
