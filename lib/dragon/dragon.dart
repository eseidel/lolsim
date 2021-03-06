import 'dart:async';
import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import 'hacks.dart';
import 'loader.dart';
import 'stats.dart';
import 'spell_parser.dart';
// FIXME: Move rune_pages into dragon
import '../rune_pages.dart';

export 'spell_parser.dart';

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
  final String tooltip;
  final Map<String, bool> maps;
  final Map<String, num> stats;
  final Map<String, dynamic> gold;
  final List<String> tags;
  final String requiredChampion;
  final bool inStore;
  final bool hideFromAll; // true for jungle enchants?
  final bool hasEffects;
  final bool consumable;

  // For unit tests.
  ItemDescription.forTesting({
    @required this.stats,
  })
      : name = null,
        id = null,
        tooltip = null,
        maps = null,
        gold = null,
        tags = null,
        requiredChampion = null,
        inStore = true,
        hideFromAll = false,
        hasEffects = false,
        consumable = false;

  // FIXME: Should use items['basic'] for defaults.
  ItemDescription.fromJson({Map<String, dynamic> json, String id})
      : id = id,
        name = json['name'],
        tooltip = json['description'],
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
    return gold['base'] > 0 &&
        inStore != false &&
        requiredChampion == null &&
        // No clue what the quick charge items do.
        !name.contains('(Quick Charge)');
  }

  bool get isTrinket => tags.contains('Trinket');
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

enum RunePath {
  domination,
  inspiration,
  precision,
  sorcery,
  resolve,
}

enum RuneSlot {
  keystone,
  one,
  two,
  three,
}

class RuneDescription {
  final String name;
  final int id;
  final String longDesc;
  final RuneSlot slot;
  final RunePath path;

  RuneDescription.fromJSON(Map<String, dynamic> json, this.slot, this.path)
      : id = json['id'],
        name = json['name'],
        longDesc = json['longDesc'];

  static RunePath pathById(int pathId) {
    return {
      8000: RunePath.precision,
      8100: RunePath.domination,
      8200: RunePath.sorcery,
      8300: RunePath.inspiration,
      8400: RunePath.resolve,
    }[pathId];
  }
}

// This could share code with ItemLibrary?
class RuneLibrary {
  RuneLibrary(List<Map<String, Map<String, dynamic>>> pathJsons)
      : _runesById = _parseRunesJson(pathJsons);

  static Map<String, RuneDescription> _parseRunesJson(
      List<Map<String, Map<String, dynamic>>> pathJsons) {
    Map<String, RuneDescription> byId = new Map();
    void addRunes(
        Map<String, dynamic> slotsJson, RuneSlot slot, RunePath path) {
      slotsJson['runes'].forEach((Map<String, dynamic> runeJson) {
        byId[runeJson['id']] =
            new RuneDescription.fromJSON(runeJson, slot, path);
      });
    }

    pathJsons.forEach((Map<String, dynamic> pathJson) {
      RunePath path = RuneDescription.pathById(pathJson['id']);
      addRunes(pathJson['slots'][0], RuneSlot.keystone, path);
      addRunes(pathJson['slots'][1], RuneSlot.one, path);
      addRunes(pathJson['slots'][2], RuneSlot.two, path);
      addRunes(pathJson['slots'][3], RuneSlot.three, path);
    });
    return new Map.unmodifiable(byId);
  }

  RuneDescriptionPage pageFromChampionGGHash(String hash) {
    // path-id-id-id-id-path-id-id
    // e.g. 8000-8005-9111-9104-8014-8200-8234-8236
    List<String> strings = hash.split('-');
    assert(strings.length == 8);
    List<int> ints = strings.map(int.parse).toList();
    int secondaryPathId = ints.removeAt(5);
    assert(RuneDescription.pathById(secondaryPathId) != null);
    int primaryPathId = ints.removeAt(0);
    assert(RuneDescription.pathById(primaryPathId) != null);
    List<RuneDescription> runes = ints.map((int id) => runeById(id)).toList();
    return new RuneDescriptionPage(
      runes: runes,
      primary: RuneDescription.pathById(primaryPathId),
      secondary: RuneDescription.pathById(secondaryPathId),
    );
  }

  final Map<String, RuneDescription> _runesById;

  List<RuneDescription> allRunes() => _runesById.values;

  RuneDescription runeById(int id) => _runesById[id];
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
  final Map<String, Map<String, dynamic>> _json;

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
  final double gold;
  final double experiance;

  MobDescription.forTesting({
    this.name,
    @required this.baseStats,
    this.id,
    this.title,
    this.gold,
    this.experiance,
  })
      : tags = [];

  MobDescription.fromJson(Map<String, dynamic> json)
      : baseStats = new BaseStats.fromJSON(json['stats']),
        id = json['id'],
        name = json['name'],
        title = json['title'],
        tags = json['tags'],
        // These are not part of dragon-data:
        gold = json['gold'],
        experiance = json['experiance'];
}

class ChampionLibrary {
  final Map<String, Map<String, dynamic>> _json;

  ChampionLibrary(Map<String, Map<String, dynamic>> json) : _json = json;

  List<String> loadChampIds() {
    return _json['data'].keys.toList();
  }

  List<String> loadChampNames() {
    return (_json['data'].values as Iterable<Map<String, dynamic>>)
        .map<String>((Map<String, dynamic> champ) => champ['name'] as String)
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

  MobDescription championByKey(String key) {
    for (Map<String, dynamic> champJson in _json['data'].values) {
      if (champJson['key'] == key)
        return new MobDescription.fromJson(champJson);
    }
    _log.severe("No champion matching key $key.");
    return null;
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
  final RuneLibrary runes;
  final SpellLibrary spells;

  DragonData(this.champs, this.items, this.runes, this.spells);

  static Future<DragonData> loadLatest({DragonLoader loader}) async {
    loader ??= new LocalLoader();
    Map championFull = JSON.decode(await loader.load('championFull.json'));
    return new DragonData(
      new ChampionLibrary(championFull),
      new ItemLibrary(JSON.decode(await loader.load('item.json'))),
      new RuneLibrary(JSON.decode(await loader.load('runesReforged.json'))),
      new SpellLibrary.fromJson(championFull),
    );
  }
}
