import 'dart:async';
import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:resource/resource.dart';
import 'stats.dart';

const String DATA_DIR = 'package:dragon_data/7.1.1/data/en_US';
final Logger _log = new Logger('dragon');

double attackDelayFromBaseAttackSpeed(double baseAttackSpeed) {
  return (0.625 / baseAttackSpeed) - 1.0;
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
        stats = json['stats'],
        hasEffects = (json['effect'] != null) {}
}

class ItemLibrary {
  Map<String, Map<String, dynamic>> _json;

  ItemLibrary(Map<String, Map<String, dynamic>> json) : _json = json;

  static List<ItemDescription> _allItemsCache = null;

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
  Map<String, Map<String, dynamic>> _json;

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

  MasteryTree get tree {
    // HACK: But seems to work and is quick.
    // Could also load the tree definitions from mastery.json.
    assert(id <= 6400);
    if (id >= 6300) return MasteryTree.cunning;
    if (id >= 6200) return MasteryTree.resolve;
    assert(id >= 6100);
    return MasteryTree.ferocity;
  }

  MasteryDescription.fromJSON(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        descriptions = json['description'],
        ranks = json['ranks'] {}
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

  MobDescription({
    this.name,
    @required this.baseStats,
    this.id,
    this.title,
  });

  MobDescription.fromJson(Map<String, dynamic> json)
      : baseStats = new BaseStats.fromJSON(json['stats']),
        id = json['id'],
        name = json['name'],
        title = json['title'] {}
}

class ChampionLibrary {
  Map<String, Map<String, dynamic>> _json;

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

typedef Future<String> StringReader(String path);

Future<String> _ioReader(String path) {
  return new Resource(path).readAsString();
}

Future<DragonData2> loadDragonData(String dataDir, StringReader reader) async {
  String championString = await reader(dataDir + '/champion.json');
  String itemString = await reader(dataDir + '/item.json');
  String masteryString = await reader(dataDir + '/mastery.json');
  String runeString = await reader(dataDir + '/rune.json');

  return new DragonData2(
    new ChampionLibrary(JSON.decode(championString)),
    new ItemLibrary(JSON.decode(itemString)),
    new MasteryLibrary(JSON.decode(masteryString)),
    new RuneLibrary(JSON.decode(runeString)),
  );
}

class DragonData2 {
  final ChampionLibrary champs;
  final ItemLibrary items;
  final MasteryLibrary masteries;
  final RuneLibrary runes;

  DragonData2(this.champs, this.items, this.masteries, this.runes);

  static Future<DragonData2> loadLatest({StringReader reader = _ioReader}) {
    return loadDragonData(DATA_DIR, reader);
  }
}
