import 'package:lol_duel/buffs.dart';
import 'package:lol_duel/effects.dart';
import 'package:lol_duel/lolsim.dart';
import 'dart:math';

class Fiora extends ChampionEffects {
  final Mob fiora;

  Fiora(this.fiora);

  @override
  String get lastUpdate => VERSION_7_2_1;

  @override
  void onChampionCreate() {
    fiora.addBuff(new DuelistsDance(fiora));
  }

  static double vitalHealForLevel(int level) {
    assert(level > 0 && level < 19);
    return 25.0 + 5.0 * level;
  }

  @override
  void onActionHit(Hit hit) {
    // If target has Duelist dance, consume it.
    MarkedWithVital buff = hit.target.buffs
        .firstWhere((buff) => buff is MarkedWithVital, orElse: () => null);
    if (buff == null || !buff.isActive) return;
    // FIXME: This should check direction relative to target.
    hit.target.removeBuff(buff);

    double bonusAd = fiora.stats.bonusAttackDamage;
    hit.addOnHitDamage(new Damage(
      // 2% (+ 4.5% per 100 bonus AD) of target's maximum health as true dmg.
      trueDamage: hit.target.stats.hp * (0.02 + (0.045 * (0.01 * bonusAd))),
    ));
    fiora.healFor(vitalHealForLevel(fiora.level), 'Vital Hit');
    // Grands Ult Rank * 10 + 20 % bonus Movement speed.
    // FIXME: Add a movement speed buff.
  }
}

class DuelistsDance extends TickingBuff {
  Mob markedTarget;

  DuelistsDance(Mob fiora)
      : super(
          name: "Duelist's Dance",
          target: fiora,
          secondsBetweenTicks: 0.5, // No clue how often this checks.
        );

  @override
  String get lastUpdate => VERSION_7_2_1;

  // This buff could instead come and go when MarkedWithVital expires?
  @override
  bool get retainedAfterDeath => true;

  Mob pickOne(List<Mob> list) {
    if (list.isEmpty) return null;
    if (list.length == 1) return list.first;
    return list[new Random().nextInt(list.length - 1)];
  }

  @override
  void onTick() {
    if (markedTarget != null) {
      // Do we need to do more validation of the current target?
      if (markedTarget.buffs.any((buff) => buff is MarkedWithVital)) return;
      markedTarget = null;
    }

    List<Mob> opponents =
        World.current.visibleNearbyEnemyChampions(this.target).toList();
    markedTarget = pickOne(opponents);
    if (markedTarget != null)
      markedTarget.addBuff(new MarkedWithVital(markedTarget));
  }
}

class MarkedWithVital extends TimedBuff {
  MarkedWithVital(Mob target)
      : super(
          name: "Marked with Vital",
          target: target,
          duration: 15.5,
        );

  @override
  String get lastUpdate => VERSION_7_2_1;

  // Takes a .5 seconds to activate.
  bool get isActive => remaining < 15.0;
}
