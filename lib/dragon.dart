import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:lol_duel/lolsim.dart';
// This dependency is inverted.
export 'package:lol_duel/lolsim.dart';

const String DATA_DIR = 'packages/dragon_data/6.24.1/data/en_US';

class ItemFactory {
  Map<String, Map<String, dynamic>> _json;

  ItemFactory(Map<String, Map<String, dynamic>> json) : _json = json;

  Iterable<Item> allItems() {
    return _json['data'].keys.map((String itemId) => new Item.fromJSON(
          id: itemId,
          json: _json['data'][itemId] as Map<String, dynamic>,
        ));
  }
}

class ChampionFactory {
  Map<String, Map<String, dynamic>> _json;

  ChampionFactory(Map<String, Map<String, dynamic>> json) : _json = json;

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

typedef Future<String> StringReader(String path);

Future<String> _ioReader(String path) {
  return new File(path).readAsString();
}

Future<DragonData> loadDragonData(String dataDir, StringReader reader) async {
  String championString = await reader(dataDir + '/champion.json');
  String itemString = await reader(dataDir + '/item.json');
  return new DragonData(
    new ChampionFactory(JSON.decode(championString)),
    new ItemFactory(JSON.decode(itemString)),
  );
}

class DragonData {
  final ChampionFactory champs;
  final ItemFactory items;

  DragonData(this.champs, this.items);

  static Future<DragonData> loadLatest({StringReader reader = _ioReader}) {
    return loadDragonData(DATA_DIR, reader);
  }
}
