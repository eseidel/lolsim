import 'dart:convert';
import 'dart:io';
import 'lolsim.dart';
// This dependency is inverted.
export 'lolsim.dart';

const String DATA_DIR = 'dragon/6.22.1/data/en_US';

class ChampionFactory {
  var _json;

  ChampionFactory.fromChampionJson(String path) {
    String string = new File(path).readAsStringSync();
    _json = JSON.decode(string);
  }

  Mob championByName(String name) {
    var json = _json['data'][name];
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
