#!/usr/local/bin/dart
import 'package:lol_duel/common_args.dart';
import 'package:lol_duel/creator.dart';
import 'package:lol_duel/lolsim.dart';

main(List<String> args) async {
  handleCommonArgs(args);

  Creator creator = await Creator.loadLatest();
  List<Item> items = creator.items.allItems().where((item) =>
      item.isAvailableOn(Maps.CURRENT_SUMMONERS_RIFT) &&
      item.generallyAvailable);

  Set<String> statTypes = new Set();
  items.forEach((item) {
    statTypes.addAll(item.stats.keys);
  });
  print(statTypes.join('\n'));
}
