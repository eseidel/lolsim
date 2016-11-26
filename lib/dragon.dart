import 'dart:convert';
import 'dart:io';
import 'package:lol_duel/lolsim.dart';
// This dependency is inverted.
export 'package:lol_duel/lolsim.dart';

const String DATA_DIR = 'packages/dragon_data/6.22.1/data/en_US';

class ChampionFactory {
  Map<String, Map<String, dynamic>> _json;

  ChampionFactory.fromChampionJson(String path) {
    String string = new File(path).readAsStringSync();
    _json = JSON.decode(string) as Map<String, Map<String, dynamic>>;
  }

  List<String> loadChampNames() {
    return _json['data']
        .values
        .map((Map<String, dynamic> champ) => champ['name']) as List<String>;
  }

  Iterable<Mob> allChamps() {
    return _json['data']
        .values
        .map((champ) => new Mob.fromJSON(champ as Map<String, dynamic>));
  }

  Mob championByName(String name) {
    Map<String, dynamic> json = _json['data'][name] as Map<String, dynamic>;
    if (json == null) {
      log.severe("No champion matching $name.");
      return null;
    }
    return new Mob.fromJSON(json);
  }
}

class ItemFactory {
  var _json;

  ItemFactory.fromItemJson(String path) {
    String string = new File(path).readAsStringSync();
    _json = JSON.decode(string);
  }

  Item itemByName(String name) {
    return new Item.fromJSON(_json['data'][name]);
  }
}

class DragonData {
  final ChampionFactory champs;
  final ItemFactory items;

  DragonData.latest()
      : champs =
            new ChampionFactory.fromChampionJson(DATA_DIR + '/champion.json'),
        items = new ItemFactory.fromItemJson(DATA_DIR + '/item.json');
}
