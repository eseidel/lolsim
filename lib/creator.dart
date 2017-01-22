import 'dragon.dart';
import 'dart:async';
export 'dragon.dart';

class Creator {
  DragonData2 dragon;
  ChampionFactory champs;
  ItemFactory items;

  Creator(this.dragon)
      : champs = dragon.champs,
        items = dragon.items;

  static Future<Creator> loadLatest() async {
    return new Creator(await DragonData2.loadLatest());
  }
}
