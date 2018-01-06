import 'buffs.dart';
import 'mob.dart';
import 'effects.dart';
import 'dart:math';
import 'dragon/spell_parser.dart';

// FIXME, this might be simpler as a recharge timer.
class SmiteCharges extends PermanentBuff {
  SmiteCharges(Mob target) : super('Smite Charges', target);

  // FIXME: Technically should start at 0 with first charge at 100.0
  // but we "spwan" monsters at 0.0 for now.
  int charges = 1;
  int maxCharges = 2;
  double timeUntilNextCharge = 90.0;
  double timeBetweenCharges = 90.0;

  @override
  String get lastUpdate => VERSION_7_11_1;

  void spendCharge() {
    // If we were previously at max, restart the timer.
    if (charges == maxCharges) timeUntilNextCharge = timeBetweenCharges;
    charges -= 1;
  }

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
  SmiteCharges chargesBuff;

  Smite(Mob champ) : super(champ, 'Smite') {
    chargesBuff = new SmiteCharges(champ);
    champ.addBuff(chargesBuff);
  }

  int get charges => chargesBuff.charges;

  @override
  String toStringAdditions() {
    return ' (${damageForLevel(champ.level)} dmg, $charges ${simpleEnglishPlural("charge", charges)})';
  }

  @override
  String get lastUpdate => VERSION_7_11_1;

  @override
  double get cooldownDuration => 15.0;

  static double damageForLevel(int level) {
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

  static double healAmount(Mob champ) => 70 + 0.1 * champ.maxHp;

  @override
  bool canBeCastOn(Mob target) {
    if (target.team == champ.team) return false;
    if (isOnCooldown) return false;
    if (charges < 1) return false;
    return target.isLargeMonster && !target.isMinion;
  }

  @override
  bool castOn(Mob target) {
    if (!canBeCastOn(target)) return false;
    chargesBuff.spendCharge();
    target.applyHit(champ.createHitForTarget(
      target: target,
      label: name,
      trueDamage: damageForLevel(champ.level),
      targeting: Targeting.singleTargetSpell, // Is this right?
    ));
    if (target.isLargeMonster) champ.healFor(healAmount(champ), name);
    return true;
  }
}

enum SummonerType {
  smite,
}

SpellDescription smiteDescription =
    new SpellDescription.summonerSpell(name: 'Smite', data: {
  'range': [500]
});

Spell createSummoner(SummonerType type, Mob champ) {
  switch (type) {
    case SummonerType.smite:
      return new Spell(champ, smiteDescription)..addSkillPoint();
  }
  return null;
}
