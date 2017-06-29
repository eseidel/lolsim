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

  BattleFury(Mob target) : super(name: 'Battle Fury', target: target);

  @override
  String get lastUpdate => VERSION_7_2_1;

  void addFury(int newFury) {
    fury = min(100, fury + newFury);
  }

  // FIXME: Missing fury from onKill.
  // FIXME: Fury should fall-off if not dealt or recieved dmg for 8s.
  // Is that the same as "out of combat"?

  @override
  void onAutoAttackHit(Hit hit) {
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

class TryndamereQ extends SpellWithCooldown {
  int rank;
  TryndamereQ(Mob champ, this.rank) : super(champ, 'Bloodlust');

  @override
  String get lastUpdate => VERSION_7_10_1;

  @override
  bool get isActiveToggle => false;
  @override
  bool get canBeCast => fury > 0 && !isOnCooldown;
  @override
  double get cooldownDuration => 12.0;

  int get fury {
    BattleFury buff = champ.buffs.firstWhere((buff) => buff is BattleFury);
    return buff.fury;
  }

  int get flatAdBonus => 5 * rank;
  double get percentAdBonus =>
      (0.10 + 0.05 * rank) * (1.0 - champ.healthPercent);

  @override
  void cast() {
    // FIXME: Missing active.
    // ACTIVE: Tryndamere consumes all of his Fury and heals himself, increased for every point of Fury consumed.
    // MINIMUM HEAL: 30 / 40 / 50 / 60 / 70 (+ 30% AP)
    // HEAL PER FURY: 0.5 / 0.95 / 1.4 / 1.85 / 2.3 (+ 1.2% AP)
  }

  @override
  Map<String, num> get stats => {
        FlatPhysicalDamageMod: flatAdBonus + percentAdBonus,
      };
}
