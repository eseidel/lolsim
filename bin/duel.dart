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
  print("Blue Team");
  duel.blues.forEach((mob) => print(mob.statsSummary()));
  print("Red Team");
  duel.reds.forEach((mob) => print(mob.statsSummary()));

  world.addMobs(duel.allMobs);
  world.tickUntil((world) {
    bool survivingBlues = world.blues.any((Mob mob) => mob.alive);
    bool survivingReds = world.reds.any((Mob mob) => mob.alive);
    return !survivingBlues || !survivingReds;
  });
  if (world.living.isEmpty) {
    log.info("${world.blues} and ${world.reds} died at the same time!");
  } else if (world.livingReds.isNotEmpty) {
    log.info("Red team survived:");
    world.livingReds.forEach((mob) => log.info("$mob ${mob.hpStatusString}"));
  } else {
    log.info("Blue team survived:");
    world.livingBlues.forEach((mob) => log.info("$mob ${mob.hpStatusString}"));
  }
}
