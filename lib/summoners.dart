import 'buffs.dart';
import 'lolsim.dart';
import 'effects.dart';
import 'dart:math';

class SmiteCharges extends PermanentBuff {
  int charges = 0;
  int maxCharges = 1;
  double timeUntilNextCharge = 100.0; // First charge takes longer.
  double timeBetweenCharges = 90.0;

  @override
  String get lastUpdate => VERSION_7_11_1;

  @override
  void tick(double timeDelta) {
    timeUntilNextCharge -= timeDelta;
    while (timeUntilNextCharge <= 0) {
      charges = min(maxCharges, charges + 1);
      timeUntilNextCharge += timeBetweenCharges;
    }
  }
}

class Smite extends SingleTargetSpell {
  Smite(Mob champ) : super(champ, 'Smite');

  @override
  String get lastUpdate => VERSION_7_11_1;

  @override
  double get cooldownDuration => 15.0;

  double damageForLevel(int level) {
    return [
      390,
      410,
      430,
      450,
      480,
      510,
      540,
      570,
      600,
      640,
      680,
      720,
      760,
      800,
      850,
      900,
      950,
      1000
    ][level - 1]
        .toDouble();
  }

  @override
  bool canBeCastOn(Mob target) {
    if (target.team == champ.team) return false;
    if (isOnCooldown) return false;
    return target.isLargeMonster && !target.isMinion;
  }

  @override
  bool castOn(Mob target) {
    if (!canBeCastOn(target)) return false;
    target.applyHit(champ.createHitForTarget(
      target: target,
      label: name,
      trueDamage: damageForLevel(champ.level),
      targeting: Targeting.singleTargetSpell, // Is this right?
    ));
    if (target.isLargeMonster) champ.healFor(70 + 0.1 * champ.stats.hp, name);
    return true;
  }
}
