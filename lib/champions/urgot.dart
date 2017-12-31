import 'package:lol_duel/mob.dart';
import 'package:lol_duel/buffs.dart';
import 'package:lol_duel/effects.dart';

class ZaunTouchedBoltAugmenter extends TimedBuff {
  ZaunTouchedBoltAugmenter(Mob target)
      : super(
            name: "Zaun-Touched Bolt Augmenter", target: target, duration: 2.5);

  @override
  String get lastUpdate => VERSION_7_2_1;

  @override
  void damageDealtModifier(Hit hit, DamageDealtDelta delta) {
    delta.percentPhysical *= .85;
    delta.percentMagical *= .85;
  }
}

class Urgot extends ChampionEffects {
  final Mob urgot;

  Urgot(this.urgot);

  @override
  String get lastUpdate => VERSION_7_2_1;

  @override
  void onAutoAttackHit(Hit hit) {
    if (hit.target.isStructure) return;
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
