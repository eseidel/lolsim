import 'dart:async';

import 'dragon/dragon.dart';
import 'mob.dart';

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
  final RuneFactory runes;

  Creator(this.dragon)
      : champs =
            new ChampionFactory(dragon.champs, new SpellFactory(dragon.spells)),
        runes = new RuneFactory(dragon.runes);

  ItemLibrary get items => dragon.items;

  static Future<Creator> loadLatest() async {
    return new Creator(await DragonData.loadLatest());
  }
}
