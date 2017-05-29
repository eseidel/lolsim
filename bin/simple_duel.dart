#!/usr/local/bin/dart
import 'dart:io';

import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:lol_duel/utils/common_args.dart';
import 'package:lol_duel/creator.dart';
import 'package:lol_duel/duel.dart';
import 'package:lol_duel/lolsim.dart';
import 'duel.dart';

final Logger _log = new Logger('duel');

dynamic main(List<String> args) async {
  ArgResults results = handleCommonArgs(args);
  if (results.rest.length != 2) {
    _log.severe("simple_duel.dart takes two champion names");
    exit(1);
  }
  Creator creator = await Creator.loadLatest();

  Mob champForArg(String arg) {
    Mob champ = creator.champs.championByName(arg);
    if (champ == null) exit(1);
    return champ;
  }

  Duel duel = new Duel(
    reds: [champForArg(results.rest[0])],
    blues: [champForArg(results.rest[1])],
  );
  runDuel(duel);
}
