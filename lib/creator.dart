import 'dart:async';

import 'package:logging/logging.dart';

import 'dragon/dragon.dart';
import 'lolsim.dart';

final Logger _log = new Logger('creator');

class ItemFactory {
  final ItemLibrary library;

  ItemFactory(this.library);

  List<Item> allItems() {
    return library.all().map((description) => new Item(description)).toList();
  }

  Item itemById(String id) {
    try {
      return allItems().firstWhere((item) => item.description.id == id);
    } catch (e) {
      _log.severe("No item maching id $id");
      return null;
    }
  }

  Item itemByName(String name) {
    try {
      return allItems().firstWhere((item) => item.name == name);
    } catch (e) {
      _log.severe("No item maching name $name");
      return null;
    }
  }
}

class RuneFactory {
  final RuneLibrary library;

  RuneFactory(this.library);

  Rune runeById(int id) => new Rune(library.runeById(id));
}

class SpellFactory {
  final SpellLibrary library;

  SpellFactory(this.library);

  SpellBook bookForChampion(Mob champ) {
    return new SpellBook(champ, library.bookForChampionName(champ.name));
  }
}

class ChampionFactory {
  final ChampionLibrary library;
  final SpellFactory spells;

  ChampionFactory(this.library, this.spells);

  Mob _makeChampion(MobDescription description) {
    Mob champ = new Mob(description, MobType.champion);
    champ.spells = spells.bookForChampion(champ);
    return champ;
  }

  Mob _makeChampionOrNull(MobDescription description) =>
      (description == null) ? null : _makeChampion(description);

  Iterable<Mob> allChamps() => library.allChamps().map(_makeChampion);
  Mob championById(String id) => _makeChampionOrNull(library.championById(id));
  Mob championByName(String name) =>
      _makeChampionOrNull(library.championByName(name));
}

class Creator {
  final DragonData dragon;
  final ChampionFactory champs;
  final ItemFactory items;
  final RuneFactory runes;

  Creator(this.dragon)
      : champs =
            new ChampionFactory(dragon.champs, new SpellFactory(dragon.spells)),
        items = new ItemFactory(dragon.items),
        runes = new RuneFactory(dragon.runes);

  static Future<Creator> loadLatest() async {
    return new Creator(await DragonData.loadLatest());
  }
}
