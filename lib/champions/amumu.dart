import 'package:lol_duel/buffs.dart';
import 'package:lol_duel/effects.dart';
import 'package:lol_duel/mob.dart';
import 'package:lol_duel/world.dart';

class Amumu extends ChampionEffects {
  final Mob amumu;

  Amumu(this.amumu);

  @override
  String get lastUpdate => VERSION_7_11_1;

  @override
  void onAutoAttackHit(Hit hit) => CursedTouch.applyToOrRefresh(hit.target);
}

class CursedTouch extends TimedBuff {
  CursedTouch(Mob target)
      : super(name: 'Cursed Touch', target: target, duration: 3.0);

  @override
  String get lastUpdate => VERSION_7_11_1;

  static void applyToOrRefresh(Mob enemy) {
    // Does CursedTouch apply to structures?
    CursedTouch debuff = enemy.buffs
        .firstWhere((buff) => buff is CursedTouch, orElse: () => null);
    if (debuff == null) {
      enemy.addBuff(new CursedTouch(enemy));
    } else {
      debuff.refresh();
    }
  }

  @override
  void onBeforeDamageRecieved(Hit hit) {
    // FIXME: This probably should not be onHit?
    // Could be a damage recieved modifier, but would like it to be labeled.
    hit.addOnHitDamage(
        new Damage(label: 'Cursed Touch', trueDamage: 0.1 * hit.magicDamage));
  }
}

typedef OnExpire = void Function();

// FIXME: This should use some sort of DOT superclass.
class Dispair extends TickingBuff {
  double baseDamage;
  double hpRatio;
  int ticksLeft;
  OnExpire onExpire;

  Dispair(Mob amumu, int rank, this.onExpire)
      : super(name: 'Dispair', target: amumu) {
    baseDamage = 2.5 + 2.5 * rank;
    hpRatio =
        0.00375 + 0.00125 * rank + 0.005 * (target.stats.abilityPower / 100);
    ticksLeft = 2;
  }

  @override
  String get lastUpdate => VERSION_7_11_1;

  @override
  void onTick() {
    World.current.enemiesWithin(target, 300).forEach((Mob enemy) {
      double damage = baseDamage + hpRatio * enemy.stats.hp;
      // FIXME: Does this apply curse before the first hit?
      CursedTouch.applyToOrRefresh(enemy);
      enemy.applyHit(target.createHitForTarget(
        label: 'Dispair',
        magicDamage: damage,
        target: enemy,
        targeting: Targeting.aoe,
      ));
    });
    ticksLeft -= 1;
    if (ticksLeft <= 0) {
      expire();
      onExpire();
    }
  }
}

class AmumuW extends SelfTargetedSpell {
  int rank;
  bool toggledOn = false;
  AmumuW(Mob champ, this.rank) : super(champ, 'Dispair');

  @override
  String get lastUpdate => VERSION_7_11_1;

  @override
  bool get isActiveToggle => toggledOn;
  @override
  bool get canBeCastOnSelf => !isOnCooldown;
  @override
  double get cooldownDuration => 1.0;

  void spendManaAndApplyBuff() {
    if (!champ.spendManaIfPossible(8)) {
      toggledOn = false;
      return;
    }
    champ.addBuff(new Dispair(champ, rank, () {
      if (toggledOn) spendManaAndApplyBuff();
    }));
  }

  @override
  void castOnSelf() {
    // FIXME: There is a timeout on toggles.
    toggledOn = !toggledOn;
    if (toggledOn) spendManaAndApplyBuff();
  }
}

class AmumuE extends SelfTargetedSpell {
  int rank;
  AmumuE(Mob amumu, this.rank) : super(amumu, 'Tantrum');

  @override
  String get lastUpdate => VERSION_7_11_1;
  @override
  bool get canBeCastOnSelf => !isOnCooldown;
  @override
  bool get isActiveToggle => false;
  @override
  double get cooldownDuration => 11.0 - rank;

  @override
  void damageRecievedModifier(Hit hit, DamageRecievedDelta delta) {
    delta.flatPhysical = -2.0 * rank;
  }

  @override
  void onBeingHit(Hit hit) {
    if (cooldown != null) cooldown.remaining -= 0.5;
  }

  @override
  void castOnSelf() {
    if (isOnCooldown) return;
    if (!champ.spendManaIfPossible(35)) return;
    startCooldown(champ);
    World.current.enemiesWithin(champ, 300).forEach((Mob target) {
      double damage = 50.0 + rank * 25.0 + 0.5 * champ.stats.abilityPower;
      target.applyHit(champ.createHitForTarget(
        label: name,
        magicDamage: damage,
        target: target,
        targeting: Targeting.aoe,
      ));
    });
  }
}
