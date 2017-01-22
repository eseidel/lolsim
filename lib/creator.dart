import 'dart:async';

import 'package:logging/logging.dart';

import 'dragon.dart';
import 'lolsim.dart';

export 'dragon.dart';

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

class Creator {
  DragonData2 dragon;
  ChampionFactory champs;
  ItemFactory items;
  RuneFactory runes;

  Creator(this.dragon)
      : champs = dragon.champs,
        items = new ItemFactory(dragon.items),
        runes = new RuneFactory(dragon.runes);

  static Future<Creator> loadLatest() async {
    return new Creator(await DragonData2.loadLatest());
  }
}
