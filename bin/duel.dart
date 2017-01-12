#!/usr/local/bin/dart
import 'dart:io';

import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:lol_duel/common_args.dart';
import 'package:lol_duel/dragon.dart';
import 'package:lol_duel/duel.dart';

main(List<String> args) async {
  ArgResults results = handleCommonArgs(args);
  final Logger _log = new Logger('duel');

  if (results.rest.length != 1) {
    _log.severe("duel.dart takes a single path argument.");
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

  duel.allMobs.forEach((mob) => mob.shouldRecordDamage = true);
  world.addMobs(duel.allMobs);
  world.tickUntil((world) {
    bool survivingBlues = world.blues.any((Mob mob) => mob.alive);
    bool survivingReds = world.reds.any((Mob mob) => mob.alive);
    return !survivingBlues || !survivingReds;
  });
  if (world.living.isEmpty) {
    _log.info("${world.blues} and ${world.reds} died at the same time!");
  } else if (world.livingReds.isNotEmpty) {
    _log.info("Red team survived:");
    world.livingReds.forEach((mob) => _log.info("$mob ${mob.hpStatusString}"));
  } else {
    _log.info("Blue team survived:");
    world.livingBlues.forEach((mob) => _log.info("$mob ${mob.hpStatusString}"));
  }
}
