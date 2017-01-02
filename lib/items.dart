// Effects are a phase/function tuple, where the signature of the function
// is defined by the enum.  The implementation of the function is typically
// a one-off.

import 'package:lol_duel/lolsim.dart';

class DoransShield extends ItemEffects {
  damageRecievedModifier(Hit hit, DamageRecievedDelta delta) {
    delta.flatCombined = -8.0;
  }
}

Map<String, ItemEffects> itemEffects = {
  'Doran\'s Shield': new DoransShield(),
};
