import 'package:lol_duel/lolsim.dart';
import 'package:lol_duel/buffs.dart';
import 'package:lol_duel/dragon/stat_constants.dart';
import 'package:lol_duel/effects.dart';
import 'dart:math';

class Tryndamere extends ChampionEffects {
  final Mob tryndamere;
  BattleFury battleFury;
  Tryndamere(this.tryndamere);

  @override
  String get lastUpdate => VERSION_7_2_1;

  // FIXME: Move this onto the buff.
  @override
  void onHit(Hit hit) {
    if (hit.target.isStructure) return;
    if (hit.isCrit)
      battleFury.addFury(10);
    else
      battleFury.addFury(5);
  }

  @override
  void onChampionCreate() {
    battleFury = new BattleFury(tryndamere);
    tryndamere.addBuff(battleFury);
  }
}

class BattleFury extends PermanentBuff {
  int fury = 0; // Should move to Mob?

  BattleFury(Mob target) : super(name: "Battle Fury", target: target);

  @override
  String get lastUpdate => VERSION_7_2_1;

  void addFury(int newFury) {
    fury = min(100, fury + newFury);
  }

  @override
  Map<String, num> get stats => {
        FlatCritChanceMod: 0.0035 * fury,
      };
}
