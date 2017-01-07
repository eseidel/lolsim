import 'dart:convert';
import 'dart:async';
import 'package:lol_duel/lolsim.dart';
// This dependency is inverted.
export 'package:lol_duel/lolsim.dart';
import 'package:resource/resource.dart';

const String DATA_DIR = 'package:dragon_data/6.24.1/data/en_US';

class ItemFactory {
  Map<String, Map<String, dynamic>> _json;

  ItemFactory(Map<String, Map<String, dynamic>> json) : _json = json;

  static List<Item> _allItemsCache = null;

  List<Item> allItems() {
    if (_allItemsCache == null) {
      _allItemsCache = new List.unmodifiable(
        _json['data'].keys.map(
              (String itemId) => new Item.fromJSON(
                    id: itemId,
                    json: _json['data'][itemId] as Map<String, dynamic>,
                  ),
            ),
      );
    }
    return _allItemsCache;
  }

  Item itemByName(String name) {
    try {
      return allItems().firstWhere((item) => item.name == name);
    } catch (e) {
      log.severe("No item maching $name");
      return null;
    }
  }
}

// This could share code with ItemFactory?
class RuneFactory {
  Map<String, Map<String, dynamic>> _json;

  RuneFactory(Map<String, Map<String, dynamic>> json) : _json = json;

  List<Item> allRunes() {
    return _json['data']
        .keys
        .map(
          (String runeId) => new Item.fromJSON(
                id: runeId,
                json: _json['data'][runeId] as Map<String, dynamic>,
              ),
        )
        .toList();
  }

  Rune runeById(int id) {
    return new Rune.fromJSON(
      id: id,
      json: _json['data'][id.toString()],
    );
  }
}

class MasteryLibrary {
  Map<String, Map<String, dynamic>> _json;

  MasteryLibrary(Map<String, Map<String, dynamic>> json) : _json = json;

  static List<MasteryDescription> _allMasteriesCache = null;

  List<MasteryDescription> allMasteries() {
    if (_allMasteriesCache == null) {
      _allMasteriesCache = new List.unmodifiable(
        _json['data'].values.map(
              (mastery) => new MasteryDescription.fromJSON(
                  mastery as Map<String, dynamic>),
            ),
      );
    }
    return _allMasteriesCache;
  }

  MasteryDescription masteryByName(String name) {
    try {
      return allMasteries().firstWhere((mastery) => mastery.name == name);
    } catch (e) {
      log.severe("No mastery maching $name");
      return null;
    }
  }

  MasteryDescription masteryById(int id) {
    return new MasteryDescription.fromJSON(_json['data'][id.toString()]);
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
    return _json['data'].values.map(
          (champ) => new Mob.fromJSON(
                champ as Map<String, dynamic>,
                MobType.champion,
              ),
        );
  }

  Mob championByName(String name) {
    Map<String, dynamic> json = _json['data'][name] as Map<String, dynamic>;
    if (json == null) {
      log.severe("No champion matching $name.");
      return null;
    }
    return new Mob.fromJSON(json, MobType.champion);
  }
}

typedef Future<String> StringReader(String path);

Future<String> _ioReader(String path) {
  return new Resource(path).readAsString();
}

Future<DragonData> loadDragonData(String dataDir, StringReader reader) async {
  String championString = await reader(dataDir + '/champion.json');
  String itemString = await reader(dataDir + '/item.json');
  String masteryString = await reader(dataDir + '/mastery.json');
  String runeString = await reader(dataDir + '/rune.json');

  return new DragonData(
    new ChampionFactory(JSON.decode(championString)),
    new ItemFactory(JSON.decode(itemString)),
    new MasteryLibrary(JSON.decode(masteryString)),
    new RuneFactory(JSON.decode(runeString)),
  );
}

class DragonData {
  final ChampionFactory champs;
  final ItemFactory items;
  final MasteryLibrary masteries;
  final RuneFactory runes;

  DragonData(this.champs, this.items, this.masteries, this.runes);

  static Future<DragonData> loadLatest({StringReader reader = _ioReader}) {
    return loadDragonData(DATA_DIR, reader);
  }
}
