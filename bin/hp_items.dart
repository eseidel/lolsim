#!/usr/local/bin/dart
import 'package:lol_duel/common_args.dart';
import 'package:lol_duel/creator.dart';
import 'package:lol_duel/lolsim.dart';

class _Computed {
  ItemDescription item;
  final int cost;
  final int hpMod;
  final int gPerHp;
  _Computed(this.item)
      : hpMod = item.stats['FlatHPPoolMod'],
        cost = item.gold['total'],
        gPerHp = (item.gold['total'] / item.stats['FlatHPPoolMod']) {}
}

main(List<String> args) async {
  handleCommonArgs(args);

  Creator creator = await Creator.loadLatest();
  Mob champ = creator.champs.championByName('Irelia');
  champ.level = 18;
  Stats stats = champ.computeStats();
  print(stats.debugString());
  print("Php: ${stats.physicalEffectiveHealth.round()}");
  print("Mhp: ${stats.magicalEffectiveHealth.round()}");

  champ.addItem(creator.items.itemByName('Sunfire Cape'));
  champ.addItem(creator.items.itemByName('Thornmail'));
  champ.addItem(creator.items.itemByName('Knight\'s Vow'));
  champ.addItem(creator.items.itemByName('Randuin\'s Omen'));
  champ.addItem(creator.items.itemByName('Dead Man\'s Plate'));

  Stats withItems = champ.computeStats();
  withItems.armor += 40; // HACK: For Knight's vow.
  print(withItems.debugString());
  print("Php: ${withItems.physicalEffectiveHealth.round()}");
  print("Mhp: ${withItems.magicalEffectiveHealth.round()}");

  List<Item> items = creator.items
      .allItems()
      .where((item) =>
          item.isAvailableOn(Maps.CURRENT_SUMMONERS_RIFT) &&
          item.generallyAvailable)
      .toList();
  List<_Computed> hpResults = items
      .where((item) {
        num hpMod = item.stats['FlatHPPoolMod'];
        return hpMod != null && hpMod > 0;
      })
      .map((item) => new _Computed(item.description))
      .toList();
  hpResults.sort((a, b) => a.gPerHp.compareTo(b.gPerHp));
  // hpResults.forEach((result) {
  //   print(
  //       "${result.item.name} ${result.hpMod} ${result.gPerHp.toStringAsFixed(2)}");
  // });
}
