// Effects are a phase/function tuple, where the signature of the function
// is defined by the enum.  The implementation of the function is typically
// a one-off.

import 'package:lol_duel/lolsim.dart';

// FIXME: This is a unique effect.
class DoransShield extends ItemEffects {
  @override
  damageRecievedModifier(Hit hit, DamageRecievedDelta delta) {
    // FIXME: This needs to check that the dmg source is single target.
    if (hit.source == null)
      log.warning("Source missing from hit against Doran's shield");
    if (hit.source?.isChampion == true) delta.flatCombined = -8.0;
  }
}

Map<String, ItemEffects> itemEffects = {
  'Doran\'s Shield': new DoransShield(),
};
