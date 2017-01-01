#!/usr/local/bin/dart
import 'package:lol_duel/dragon.dart';
import 'package:lol_duel/duel.dart';
import 'package:args/args.dart';
import 'package:lol_duel/common_args.dart';
import 'dart:io';

main(List<String> args) async {
  ArgResults results = handleCommonArgs(args);
  if (results.rest.length != 1) {
    log.severe("duel.dart takes a single path argument.");
    exit(1);
  }

  DragonData data = await DragonData.loadLatest();
  DuelLoader duelLoader = new DuelLoader(data);
  World world = new World();

  Duel duel = await duelLoader.duelFromYamlPath(results.rest.first);
  print("${duel.blues} vs. ${duel.reds}");
  world.addMobs(duel.allMobs);
  world.tickUntil((world) {
    return world.living.length < 2;
  });
  if (world.living.length == 0) {
    log.info(
        "${world.allMobs[0].name} and ${world.allMobs[1].name} died at the same time!");
  } else {
    Mob survivor = world.living[0];
    log.info(
        "At ${world.time.toStringAsFixed(2)}s ${survivor} lived with ${survivor.currentHp.toStringAsFixed(3)} hp");
  }
}
