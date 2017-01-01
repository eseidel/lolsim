#!/usr/local/bin/dart
import 'package:lol_duel/common_args.dart';
import 'package:lol_duel/dragon.dart';

class _Computed {
  Item item;
  final int cost;
  final int hpMod;
  final int gPerHp;
  _Computed(Item item)
      : item = item,
        hpMod = item.stats['FlatHPPoolMod'],
        cost = item.gold['total'],
        gPerHp = (item.gold['total'] / item.stats['FlatHPPoolMod']) {}
}

main(List<String> args) async {
  handleCommonArgs(args);

  DragonData data = await DragonData.loadLatest();
  Mob champ = data.champs.championByName('Irelia');
  champ.level = 18;
  Stats stats = champ.computeStats();
  print(stats.debugString());
  print("Php: ${stats.physicalEffectiveHealth.round()}");
  print("Mhp: ${stats.magicalEffectiveHealth.round()}");

  List<Item> items = data.items.allItems().where((item) =>
      item.isAvailableOn(Maps.CURRENT_SUMMONERS_RIFT) &&
      item.generallyAvailable);

  Item itemNamed(String name) {
    try {
      return items.firstWhere((item) => item.name == name);
    } catch (e) {
      print("Failed to find $name");
      return null;
    }
  }

  champ.addItem(itemNamed('Sunfire Cape'));
  champ.addItem(itemNamed('Thornmail'));
  champ.addItem(itemNamed('Knight\'s Vow'));
  champ.addItem(itemNamed('Randuin\'s Omen'));
  champ.addItem(itemNamed('Dead Man\'s Plate'));

  Stats withItems = champ.computeStats();
  withItems.armor += 40; // HACK: For Knight's vow.
  print(withItems.debugString());
  print("Php: ${withItems.physicalEffectiveHealth.round()}");
  print("Mhp: ${withItems.magicalEffectiveHealth.round()}");

  List<_Computed> hpResults = items
      .where((item) {
        num hpMod = item.stats['FlatHPPoolMod'];
        return hpMod != null && hpMod > 0;
      })
      .map((item) => new _Computed(item))
      .toList();
  hpResults.sort((a, b) => a.gPerHp.compareTo(b.gPerHp));
  // hpResults.forEach((result) {
  //   print(
  //       "${result.item.name} ${result.hpMod} ${result.gPerHp.toStringAsFixed(2)}");
  // });
}
