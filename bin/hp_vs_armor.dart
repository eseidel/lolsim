#!/usr/local/bin/dart
import 'package:lol_duel/common_args.dart';
import 'package:lol_duel/creator.dart';
import 'package:lol_duel/dragon.dart';
import 'package:lol_duel/stat_relations.dart';

Iterable<double> _fromTo(double start, double stop, double increment) sync* {
  double i = start;
  while (i < stop) {
    yield i;
    i += increment;
  }
}

dynamic main(List<String> args) async {
  handleCommonArgs(args);
  // This could use DataDragon instead of creator.
  Creator creator = await Creator.loadLatest();

  await relateArmorToHp(creator.items);

  String champName = args.first ?? 'Caitlyn';
  MobDescription champ = creator.dragon.champs.championByName(champName);
  double baseAttackSpeed = champ.baseStats.baseAttackSpeed;
  ConvertApsToAd apsToAd = await relateAttacksPerSecondToAttackDamage(
      creator.items, baseAttackSpeed);

  print('$champName ${baseAttackSpeed.toStringAsFixed(3)}');
  print("");

  _fromTo(0.1, 1.5, .1).forEach((double percent) {
    print(
        '${(100 * percent).round()}% = ${(percent * baseAttackSpeed).toStringAsFixed(2)}');
  });
  print("");
  [baseAttackSpeed]
    ..addAll(_fromTo(0.6, 2.5, 0.1))
    ..forEach((double aps) {
      double optimalAd = apsToAd(aps);
      print(
          'aps: ${aps.toStringAsFixed(1)}, ad: ${optimalAd.toStringAsFixed(1)}');
    });
}
