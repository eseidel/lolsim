#!/usr/local/bin/dart
import 'package:lol_duel/common_args.dart';
import 'package:lol_duel/dragon.dart';

dynamic main(List<String> args) async {
  handleCommonArgs(args);

  DragonData dragon = await DragonData.loadLatest();
  List<ItemDescription> items = dragon.items.all().where((item) =>
      item.isAvailableOn(Maps.CURRENT_SUMMONERS_RIFT) &&
      item.generallyAvailable);

  Set<String> statTypes = new Set();
  items.forEach((item) {
    statTypes.addAll(item.stats.keys);
  });
  print(statTypes.join('\n'));
}
