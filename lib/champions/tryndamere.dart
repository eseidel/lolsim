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

  @override
  void onChampionCreate() {
    battleFury = new BattleFury(tryndamere);
    tryndamere.addBuff(battleFury);
  }
}

class BattleFury extends PermanentBuff {
  int fury = 0; // FIXME: Should move to Mob?

  BattleFury(Mob target) : super(name: "Battle Fury", target: target);

  @override
  String get lastUpdate => VERSION_7_2_1;

  void addFury(int newFury) {
    fury = min(100, fury + newFury);
  }

  // FIXME: Missing fury from onKill.
  // FIXME: Fury should fall-off if not dealt or recieved dmg for 8s.
  // Is that the same as "out of combat"?

  @override
  void onHit(Hit hit) {
    if (hit.target.isStructure) return;
    if (hit.isCrit)
      addFury(10);
    else
      addFury(5);
  }

  @override
  Map<String, num> get stats => {
        FlatCritChanceMod: 0.0035 * fury,
      };
}

class TryndamereQ extends SpellEffects {
  Mob champ;
  int rank;
  TryndamereQ(this.champ, this.rank);

  @override
  String get lastUpdate => VERSION_7_10_1;

  int get flatAdBonus => 5 * rank;
  double get percentAdBonus =>
      (0.10 + 0.05 * rank) * (1.0 - champ.healthPercent);

  // FIXME: Missing active.

  @override
  Map<String, num> get stats => {
        FlatPhysicalDamageMod: flatAdBonus + percentAdBonus,
      };
}
