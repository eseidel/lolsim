import 'package:lol_duel/lolsim.dart';
import 'package:lol_duel/buffs.dart';
import 'package:lol_duel/champions.dart';

class ZaunTouchedBoltAugmenter extends TimedBuff {
  ZaunTouchedBoltAugmenter(Mob target)
      : super(
            name: "Zaun-Touched Bolt Augmenter", target: target, duration: 2.5);

  @override
  void damageDealtModifier(Hit hit, DamageDealtDelta delta) {
    delta.percentPhysical *= .85;
    delta.percentMagical *= .85;
  }
}

class Urgot extends ChampionEffects {
  Mob urgot;
  Urgot(this.urgot);

  @override
  void onHit(Hit hit) {
    if (hit.target.type == MobType.structure) return;
    ZaunTouchedBoltAugmenter buff = hit.target.buffs.firstWhere(
        (buff) => buff is ZaunTouchedBoltAugmenter,
        orElse: () => null);
    if (buff != null)
      buff.refresh();
    else {
      hit.target.addBuff(new ZaunTouchedBoltAugmenter(urgot));
    }
  }
}
