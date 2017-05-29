import 'dart:async';

import 'package:logging/logging.dart';

import 'dragon/dragon.dart';
import 'lolsim.dart';

final Logger _log = new Logger('creator');

class ItemFactory {
  ItemLibrary library;

  ItemFactory(this.library);

  List<Item> allItems() {
    return library.all().map((description) => new Item(description)).toList();
  }

  Item itemByName(String name) {
    try {
      return allItems().firstWhere((item) => item.name == name);
    } catch (e) {
      _log.severe("No item maching $name");
      return null;
    }
  }
}

class RuneFactory {
  RuneLibrary library;

  RuneFactory(this.library);

  Rune runeById(int id) {
    return new Rune(library.runeById(id));
  }
}

class ChampionFactory {
  ChampionLibrary library;

  ChampionFactory(this.library);

  Iterable<Mob> allChamps() {
    return library
        .allChamps()
        .map((description) => new Mob(description, MobType.champion));
  }

  Mob championById(String id) {
    MobDescription description = library.championById(id);
    if (description == null) return null;
    return new Mob(description, MobType.champion);
  }

  Mob championByName(String name) {
    MobDescription description = library.championByName(name);
    if (description == null) return null;
    return new Mob(description, MobType.champion);
  }
}

class Creator {
  DragonData dragon;
  ChampionFactory champs;
  ItemFactory items;
  RuneFactory runes;

  Creator(this.dragon)
      : champs = new ChampionFactory(dragon.champs),
        items = new ItemFactory(dragon.items),
        runes = new RuneFactory(dragon.runes);

  static Future<Creator> loadLatest() async {
    return new Creator(await DragonData.loadLatest());
  }
}
