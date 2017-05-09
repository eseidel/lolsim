// Effects are a phase/function tuple, where the signature of the function
// is defined by the enum.  The implementation of the function is typically
// a one-off.

import 'package:lol_duel/lolsim.dart';

// FIXME: This is a unique effect.
// FIXME: Needs update for 7.9.1
class DoransShield extends ItemEffects {
  @override
  void damageRecievedModifier(Hit hit, DamageRecievedDelta delta) {
    // FIXME: This needs to check that the dmg source is single target.
    if (hit.source.type == MobType.champion) delta.flatCombined = -8.0;
  }
}

Map<String, ItemEffects> itemEffects = {
  'Doran\'s Shield': new DoransShield(),
};
