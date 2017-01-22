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

class Creator {
  DragonData2 dragon;
  ChampionFactory champs;
  ItemFactory items;

  Creator(this.dragon)
      : champs = dragon.champs,
        items = new ItemFactory(dragon.items);

  static Future<Creator> loadLatest() async {
    return new Creator(await DragonData2.loadLatest());
  }
}
