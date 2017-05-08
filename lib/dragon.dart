import 'dart:async';
import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'stats.dart';
import 'dragon_loader.dart';
import 'dragon_hacks.dart';

final Logger _log = new Logger('dragon');

double attackDelayFromBaseAttackSpeed(double baseAttackSpeed) {
  return (0.625 / baseAttackSpeed) - 1.0;
}

class Maps {
  static String CURRENT_TWISTED_TREELINE = "10";
  static String CURRENT_SUMMONERS_RIFT = "11";
  static String CURRENT_HOWLING_ABYSS = "12";
}

class ItemDescription {
  final String name;
  final String id;
  final Map<String, bool> maps;
  final Map<String, num> stats;
  final Map<String, dynamic> gold;
  final List<String> tags;
  final String requiredChampion;
  final bool inStore;
  final bool hideFromAll; // true for jungle enchants?
  final bool hasEffects;
  final bool consumable;

  // FIXME: Should use items['basic'] for defaults.
  ItemDescription.fromJson({Map<String, dynamic> json, String id})
      : id = id,
        name = json['name'],
        maps = json['maps'],
        tags = json['tags'],
        gold = json['gold'],
        requiredChampion = json['requiredChampion'],
        inStore = json['in'],
        hideFromAll = json['hideFromAll'],
        stats = hackInMissingStats(json['name'], json['stats']),
        consumable = json['consumed'] == true,
        hasEffects = (json['effect'] != null);

  bool isAvailableOn(String mapId) => maps[mapId] == true;
  bool get purchasable => gold['purchasable'] == true;
  bool get generallyAvailable {
    return gold['base'] > 0 && inStore != false && requiredChampion == null;
  }

  bool get isTrinket => !tags.contains('Trinket');
}

class ItemLibrary {
  Map<String, Map<String, dynamic>> _json;

  ItemLibrary(Map<String, Map<String, dynamic>> json) : _json = json;

  static List<ItemDescription> _allItemsCache;

  List<ItemDescription> all() {
    if (_allItemsCache == null) {
      _allItemsCache = new List.unmodifiable(
        _json['data'].keys.map(
              (String itemId) => new ItemDescription.fromJson(
                    id: itemId,
                    json: _json['data'][itemId] as Map<String, dynamic>,
                  ),
            ),
      );
    }
    return _allItemsCache;
  }

  ItemDescription itemById(String id) {
    try {
      return all().firstWhere((item) => item.id == id);
    } catch (e) {
      _log.severe("No item with id $id");
      return null;
    }
  }

  ItemDescription itemByName(String name) {
    try {
      return all().firstWhere((item) => item.name == name);
    } catch (e) {
      _log.severe("No item maching $name");
      return null;
    }
  }
}

class RuneDescription {
  final String name;
  final int id;
  final String statName;
  final double statValue;

  RuneDescription.fromJSON({Map<String, dynamic> json, int id})
      : id = id,
        name = json['name'],
        statName =
            json['stats'].keys.length == 1 ? json['stats'].keys.first : null,
        statValue = json['stats'].values.length == 1
            ? json['stats'].values.first
            : null {
    assert(json['rune']['isrune'] == true);
  }
}

// This could share code with ItemLibrary?
class RuneLibrary {
  final Map<String, Map<String, dynamic>> _json;

  RuneLibrary(Map<String, Map<String, dynamic>> json) : _json = json;

  RuneDescription runeById(int id) {
    return new RuneDescription.fromJSON(
      id: id,
      json: _json['data'][id.toString()],
    );
  }
}

enum MasteryTree {
  ferocity,
  cunning,
  resolve,
}

class MasteryDescription {
  final int id;
  final String name;
  final List<String> descriptions;
  final int ranks;

  MasteryDescription.fromJSON(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        descriptions = json['description'],
        ranks = json['ranks'];

  MasteryTree get tree {
    // HACK: But seems to work and is quick.
    // Could also load the tree definitions from mastery.json.
    assert(id <= 6400);
    if (id >= 6300) return MasteryTree.cunning;
    if (id >= 6200) return MasteryTree.resolve;
    assert(id >= 6100);
    return MasteryTree.ferocity;
  }
}

class MasteryLibrary {
  Map<String, Map<String, dynamic>> _json;

  MasteryLibrary(Map<String, Map<String, dynamic>> json) : _json = json;

  static List<MasteryDescription> _allMasteriesCache;

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
      _log.severe("No mastery maching $name");
      return null;
    }
  }

  MasteryDescription masteryById(int id) {
    return new MasteryDescription.fromJSON(_json['data'][id.toString()]);
  }
}

class MobDescription {
  final String id;
  final String name;
  final String title;
  final BaseStats baseStats;
  final List<String> tags;

  MobDescription({
    this.name,
    @required this.baseStats,
    this.id,
    this.title,
  })
      : tags = [];

  MobDescription.fromJson(Map<String, dynamic> json)
      : baseStats = new BaseStats.fromJSON(json['stats']),
        id = json['id'],
        name = json['name'],
        title = json['title'],
        tags = json['tags'];
}

class ChampionLibrary {
  final Map<String, Map<String, dynamic>> _json;

  ChampionLibrary(Map<String, Map<String, dynamic>> json) : _json = json;

  List<String> loadChampIds() {
    return _json['data'].keys.toList();
  }

  List<String> loadChampNames() {
    return _json['data']
        .values
        .map((Map<String, dynamic> champ) => champ['name'] as String)
        .toList();
  }

  Iterable<MobDescription> allChamps() {
    return _json['data'].values.map(
          (champ) => new MobDescription.fromJson(
                champ as Map<String, dynamic>,
              ),
        );
  }

  MobDescription championById(String id) {
    Map<String, dynamic> json = _json['data'][id] as Map<String, dynamic>;
    if (json == null) {
      _log.severe("No champion matching id $id.");
      return null;
    }
    return new MobDescription.fromJson(json);
  }

  MobDescription championByName(String name) {
    for (Map<String, dynamic> champJson in _json['data'].values) {
      if (champJson['name'] == name)
        return new MobDescription.fromJson(champJson);
    }
    _log.severe("No champion matching name $name.");
    return null;
  }
}

class DragonData {
  final ChampionLibrary champs;
  final ItemLibrary items;
  final MasteryLibrary masteries;
  final RuneLibrary runes;

  DragonData(this.champs, this.items, this.masteries, this.runes);

  static Future<DragonData> loadLatest({DragonLoader loader}) async {
    loader ??= new LocalLoader();
    return new DragonData(
      new ChampionLibrary(JSON.decode(await loader.load('championFull.json'))),
      new ItemLibrary(JSON.decode(await loader.load('item.json'))),
      new MasteryLibrary(JSON.decode(await loader.load('mastery.json'))),
      new RuneLibrary(JSON.decode(await loader.load('rune.json'))),
    );
  }
}
