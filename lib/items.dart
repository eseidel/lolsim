import 'package:meta/meta.dart';

import 'buffs.dart';
import 'dragon/stat_constants.dart';
import 'effects.dart';
import 'lolsim.dart';

// FIXME: This is a unique effect.
// FIXME: Needs update for 7.9.1
class DoransShield extends ItemEffects {
  @override
  String get lastUpdate => VERSION_7_2_1;

  @override
  void damageRecievedModifier(Hit hit, DamageRecievedDelta delta) {
    // FIXME: This needs to check that the dmg source is single target.
    if (hit.source.isChampion) delta.flatCombined = -8.0;
  }
}

class HuntersMachete extends ItemEffects {
  @override
  String get lastUpdate => VERSION_7_10_1;

  // FIXME: No way to identify this as a unique effect.

  // FIXME: This should only apply to monsters!
  @override
  Map<String, num> get stats => {
        PercentLifeStealMod: 0.1,
      };

  @override
  void onHit(Hit hit) {
    if (hit.target.type != MobType.monster) return;
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
    target.applyHit(new Hit(
      label: name,
      magicDamage: damagePerTick,
      target: target,
      source: source,
    ));
    source.healFor(damagePerTick, name);
    ticksLeft -= 1;
    if (ticksLeft <= 0) expire();
  }
}

class HuntersTalisman extends ItemEffects {
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

  @override
  void onActionHit(Hit hit) {
    if (hit.target.type != MobType.monster) return;
    applyToOrRefresh(source: hit.source, target: hit.target);
  }
}

Map<String, ItemEffects> itemEffects = {
  'Doran\'s Shield': new DoransShield(),
  'Hunter\'s Machete': new HuntersMachete(),
  'Hunter\'s Talisman': new HuntersTalisman(),
};
