// Effects are a phase/function tuple, where the signature of the function
// is defined by the enum.  The implementation of the function is typically
// a one-off.

import 'lolsim.dart';
import 'stat_constants.dart';

// FIXME: This is a unique effect.
// FIXME: Needs update for 7.9.1
class DoransShield extends ItemEffects {
  @override
  void damageRecievedModifier(Hit hit, DamageRecievedDelta delta) {
    // FIXME: This needs to check that the dmg source is single target.
    if (hit.source.isChampion) delta.flatCombined = -8.0;
  }
}

class HuntersMachete extends ItemEffects {
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

Map<String, ItemEffects> itemEffects = {
  'Doran\'s Shield': new DoransShield(),
  'Hunter\'s Machete': new HuntersMachete(),
};
