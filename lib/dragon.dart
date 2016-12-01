import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:lol_duel/lolsim.dart';
// This dependency is inverted.
export 'package:lol_duel/lolsim.dart';

const String DATA_DIR = 'packages/dragon_data/6.22.1/data/en_US';

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
  String jsonString = await reader(dataDir + '/champion.json');
  Map<String, Map<String, dynamic>> json = JSON.decode(jsonString);
  return new DragonData(new ChampionFactory(json));
}

class DragonData {
  final ChampionFactory champs;

  DragonData(this.champs);

  static Future<DragonData> loadLatest({StringReader reader = _ioReader}) {
    return loadDragonData(DATA_DIR, reader);
  }
}
