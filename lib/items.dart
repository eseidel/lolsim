import 'package:meta/meta.dart';

import 'buffs.dart';
import 'dragon/stat_constants.dart';
import 'effects.dart';
import 'mob.dart';
import 'world.dart';

import 'dart:math';

// FIXME: This is a unique effect.
// FIXME: Needs update for 7.9.1
class DoransShield extends BuffEffects {
  @override
  String get lastUpdate => VERSION_7_2_1;

  @override
  void damageRecievedModifier(Hit hit, DamageRecievedDelta delta) {
    // FIXME: This needs to check that the dmg source is single target.
    if (hit.source.isChampion) delta.flatCombined = -8.0;
  }
}

void _addJungleItemBonusExperiance(Mob owner, Mob victim) {
  double bonusExperiance = 0.0;
  if (victim.isLargeMonster) bonusExperiance += 50.0;
  int levelDelta = max(0, victim.level - owner.level);
  bonusExperiance += 30.0 * levelDelta;
  if (bonusExperiance > 0.0) owner.addExperiance(bonusExperiance);
}

class HuntersMachete extends BuffEffects {
  final Mob owner;
  HuntersMachete(this.owner);

  @override
  String get lastUpdate => VERSION_7_10_1;

  // FIXME: No way to identify this as a unique effect.

  // FIXME: This should only apply to monsters!
  @override
  Map<String, num> get stats => {
        PercentLifeStealMod: 0.1,
      };

  @override
  void onKill(Mob victim) {
    // FIXME: This should use some sort of unique-effect system?
    if (owner.firstItemNamed(ItemNames.HuntersTalisman) != null) return;
    _addJungleItemBonusExperiance(owner, victim);
  }

  @override
  void onAutoAttackHit(Hit hit) {
    if (!hit.target.isMonster) return;
    hit.addOnHitDamage(new Damage(label: 'Nail', physicalDamage: 25.0));
  }
}

class HealthDrain extends TickingBuff {
  Mob source;
  int ticksLeft;

  HealthDrain({@required this.source, @required Mob target})
      : super(name: 'Health Drain', target: target) {
    refresh();
  }

  @override
  String get lastUpdate => VERSION_7_11_1;

  void refresh() {
    assert(secondsBetweenTicks == 0.5);
    ticksLeft = 10;
  }

  @override
  void onTick() {
    double damagePerFive = 25.0;
    double damagePerTick = damagePerFive / (5.0 / secondsBetweenTicks);
    target.applyHit(source.createHitForTarget(
      label: name,
      magicDamage: damagePerTick,
      target: target,
      targeting: Targeting.dot,
    ));
    source.healFor(damagePerTick, name);
    ticksLeft -= 1;
    if (ticksLeft <= 0) expire();
  }
}

class HuntersTalisman extends BuffEffects {
  final Mob owner;
  HuntersTalisman(this.owner);

  @override
  String get lastUpdate => VERSION_7_11_1;

  // FIXME: No way to identify this as a unique effect.

  // FIXME: This is a proximity-sensitive buff and should only
  // apply when in the jungle.
  @override
  Map<String, num> get stats => {
        PercentBaseMPRegenMod: 1.50,
      };

  static void applyToOrRefresh({@required Mob source, @required Mob target}) {
    HealthDrain debuff = target.buffs
        .firstWhere((buff) => buff is HealthDrain, orElse: () => null);
    if (debuff == null) {
      target.addBuff(new HealthDrain(target: target, source: source));
    } else {
      debuff.refresh();
    }
  }

  void applyHealthDrain(Hit hit) {
    if (!hit.target.isMonster) return;
    applyToOrRefresh(source: hit.source, target: hit.target);
  }

  @override
  void onAutoAttackHit(Hit hit) {
    applyHealthDrain(hit);
  }

  @override
  void onSpellHit(Hit hit) {
    applyHealthDrain(hit);
  }

  @override
  void onKill(Mob victim) {
    // This one wins when having both HuntersTalisman and HuntersMachete.
    _addJungleItemBonusExperiance(owner, victim);
  }
}

class RefillablePotionBuff extends TimedBuff {
  // FIXME: Respect Secret Stash (10% longer).
  static double initialDuration = 12.0;

  RefillablePotionBuff(Mob target)
      : super(
          name: 'Refillable Potion',
          duration: initialDuration,
          target: target,
        );

  void addStack() {
    remaining += initialDuration;
  }

  @override
  String get lastUpdate => VERSION_7_11_1;

  @override
  Map<String, num> get stats => {
        // Restores 125hp over 12 seconds, FlatHPRegenMod is in units of 5 seconds.
        FlatHPRegenMod: 125.0 / 12.0 * 5.0,
      };
}

class RefillablePotion extends EffectWithCooldown {
  final int maxCharges = 2;
  int charges = 2;

  RefillablePotion() : super('Refillable Potion') {
    refill();
  }

  void refill() {
    charges = maxCharges;
  }

  @override
  String get lastUpdate => VERSION_7_11_1;

  RefillablePotionBuff findActiveBuff(Mob champ) => champ.buffs
      .firstWhere((buff) => buff is RefillablePotionBuff, orElse: () => null);

  bool isActive(Mob champ) => findActiveBuff(champ) != null;

  void applyToOrAddStack(Mob target) {
    RefillablePotionBuff buff = findActiveBuff(target);
    if (buff == null) {
      target.addBuff(new RefillablePotionBuff(target));
    } else {
      buff.addStack();
    }
  }

  @override
  double get cooldownDuration => 0.5; // Standard item activation cooldown.

  bool canBeCastOn(Mob champ) =>
      charges > 0 && champ.hpLost > 0 && !isOnCooldown;

  void castOn(Mob champ) {
    assert(canBeCastOn(champ));
    charges -= 1;
    applyToOrAddStack(champ);
  }
}

class Immolate extends TickingBuff {
  Immolate(Mob target)
      : super(target: target, name: 'Immolate', secondsBetweenTicks: 1.0);

  @override
  bool get retainedAfterDeath => true;

  @override
  String get lastUpdate => VERSION_7_11_1;

  @override
  void onTick() {
    World.current.enemiesWithin(target, 325).forEach((Mob enemy) {
      double damagePerSecond = 5.0 + target.level;
      if (enemy.isMonster) damagePerSecond *= 2.0;
      enemy.applyHit(target.createHitForTarget(
        label: name,
        magicDamage: damagePerSecond,
        target: enemy,
        targeting: Targeting.aoe,
      ));
    });
  }
}

class BamisCinder extends BuffEffects {
  final Mob owner;
  BamisCinder(this.owner);

  @override
  String get lastUpdate => VERSION_7_11_1;

  @override
  void onCreate() {
    owner.addBuff(new Immolate(owner));
  }
  // Stats are given by ItemDescription I believe?
}

class ItemNames {
  static final String DoransShield = 'Doran\'s Shield';
  static final String DoransBlade = 'Doran\'s Blade';
  static final String HuntersMachete = 'Hunter\'s Machete';
  static final String HuntersTalisman = 'Hunter\'s Talisman';
  static final String RefillablePotion = 'Refillable Potion';
  static final String BamisCinder = 'Bami\'s Cinder';
}

typedef BuffEffects ItemEffectsConstructor(Mob owner);

Map<String, ItemEffectsConstructor> _itemEffectsConstructors = {
  ItemNames.DoransShield: (_) => new DoransShield(),
  ItemNames.HuntersMachete: (Mob owner) => new HuntersMachete(owner),
  ItemNames.HuntersTalisman: (Mob owner) => new HuntersTalisman(owner),
  ItemNames.RefillablePotion: (_) => new RefillablePotion(),
  ItemNames.BamisCinder: (Mob owner) => new BamisCinder(owner),
};

BuffEffects constructEffectsForItem(String itemName, Mob owner) {
  ItemEffectsConstructor constructor = _itemEffectsConstructors[itemName];
  if (constructor == null) return null;
  BuffEffects effects = constructor(owner);
  if (effects != null) effects.onCreate();
  return effects;
}
