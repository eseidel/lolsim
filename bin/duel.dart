#!/usr/local/bin/dart
import 'dart:io';

import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:lol_duel/common_args.dart';
import 'package:lol_duel/creator.dart';
import 'package:lol_duel/duel.dart';
import 'package:lol_duel/lolsim.dart';

final Logger _log = new Logger('duel');

void runDuel(Duel duel) {
  print("${duel.blues} vs. ${duel.reds}");
  print("Blue Team");
  duel.blues.forEach((mob) => print(mob.statsSummary()));
  print("Red Team");
  duel.reds.forEach((mob) => print(mob.statsSummary()));

  List<String> champIds = [];
  duel.allMobs.forEach((mob) {
    mob.shouldRecordDamage = true;
    if (mob.type == MobType.champion) champIds.add(mob.id);
  });
  World world = new World(
    blues: duel.blues,
    reds: duel.reds,
    critProvider: new PredictableCrits(champIds),
  );
  world.tickUntil(World.oneSideDies);
  if (world.living.isEmpty) {
    _log.info("${world.blues} and ${world.reds} died at the same time!");
  } else if (world.livingReds.isNotEmpty) {
    _log.info("RED WINS");
  } else {
    _log.info("BLUE WINS");
  }
  print("Blue Team");
  world.blues.forEach((mob) =>
      _log.info("$mob ${mob.hpStatusString}\n${mob.damageLog.summaryString}"));
  print("Red Team");
  world.reds.forEach((mob) =>
      _log.info("$mob ${mob.hpStatusString}\n${mob.damageLog.summaryString}"));
}

dynamic main(List<String> args) async {
  ArgResults results = handleCommonArgs(args);
  if (results.rest.length != 1) {
    _log.severe("duel.dart takes a single path argument.");
    exit(1);
  }

  DuelLoader duelLoader = new DuelLoader(await Creator.loadLatest());
  runDuel(await duelLoader.duelFromYamlPath(results.rest.first));
}
