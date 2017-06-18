import 'package:lol_duel/buffs.dart';
import 'package:lol_duel/effects.dart';
import 'package:lol_duel/lolsim.dart';

class Amumu extends ChampionEffects {
  final Mob amumu;

  Amumu(this.amumu);

  @override
  String get lastUpdate => VERSION_7_11_1;

  @override
  void onHit(Hit hit) => CursedTouch.applyToOrRefresh(hit.target);
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
      enemy.applyHit(new Hit(label: 'Dispair', magicDamage: damage));
    });
    ticksLeft -= 1;
    if (ticksLeft <= 0) {
      expire();
      onExpire();
    }
  }
}

class AmumuW extends SpellEffects {
  Mob amumu;
  int rank;
  bool toggledOn = false;
  AmumuW(this.amumu, this.rank);

  @override
  String get lastUpdate => VERSION_7_11_1;

  void spendManaAndApplyBuff() {
    if (!amumu.spendManaIfPossible(8)) {
      toggledOn = false;
      return;
    }
    amumu.addBuff(new Dispair(amumu, rank, () {
      if (toggledOn) spendManaAndApplyBuff();
    }));
  }

  @override
  void cast() {
    // FIXME: There is a timeout on toggles.
    toggledOn = !toggledOn;
    if (toggledOn) spendManaAndApplyBuff();
  }
}

class AmumuECooldown extends Cooldown {
  AmumuE spell;
  AmumuECooldown(this.spell)
      : super(target: spell.amumu, duration: spell.cooldownDuration);

  @override
  String get lastUpdate => VERSION_7_11_1;

  @override
  void expire() {
    spell.cooldown = null;
    super.expire();
  }
}

class AmumuE extends SpellEffects {
  Mob amumu;
  int rank;
  Cooldown cooldown;
  AmumuE(this.amumu, this.rank);

  @override
  String get lastUpdate => VERSION_7_11_1;

  double get cooldownDuration => 11.0 - rank;
  bool get isOnCooldown => cooldown != null;
  void startCooldown() {
    assert(!isOnCooldown);
    cooldown = new AmumuECooldown(this);
  }

  @override
  void damageRecievedModifier(Hit hit, DamageRecievedDelta delta) {
    delta.flatPhysical = -2.0 * rank;
  }

  @override
  void onBeingHit(Hit hit) {
    if (cooldown != null) cooldown.remaining -= 0.5;
  }

  @override
  void cast() {
    if (isOnCooldown) return;
    if (!amumu.spendManaIfPossible(35)) return;
    startCooldown();
    World.current.enemiesWithin(amumu, 300).forEach((Mob target) {
      double damage = 50.0 + rank * 25.0 + 0.5 * amumu.stats.abilityPower;
      target.applyHit(new Hit(label: 'Tantrum', magicDamage: damage));
    });
  }
}
