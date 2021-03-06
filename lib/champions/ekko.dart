import 'package:lol_duel/buffs.dart';
import 'package:lol_duel/effects.dart';
import 'package:lol_duel/mob.dart';

class Ekko extends ChampionEffects {
  final Mob ekko;

  Ekko(this.ekko);

  @override
  String get lastUpdate => VERSION_7_2_1;

  double get onHitDamage {
    int level = ekko.level;
    if (level < 7) return (level + 2) * 10.0;
    return 80 + (level - 6) * 5.0;
  }

  @override
  void onAutoAttackHit(Hit hit) {
    if (hit.target.isStructure) return;
    if (hit.target.buffs.any((buff) => buff is ZDriveResonanceDown)) return;

    ZDriveResonance buff = hit.target.buffs
        .firstWhere((buff) => buff is ZDriveResonance, orElse: () => null);
    if (buff == null) {
      hit.target.addBuff(new ZDriveResonance(hit.target));
    } else {
      // EkkoMains Discord says you get 4s from the last hit, they do refresh.
      buff.refreshAndAddStack();

      if (buff.stacks == 3) {
        hit.target.removeBuff(buff);
        hit.target.addBuff(new ZDriveResonanceDown(hit.target));
        hit.addOnHitDamage(new Damage(
          label: buff.name,
          magicDamage: onHitDamage,
        ));
        // FIXME: Movespeed buff not implemented.
      }
    }
  }
}

class ZDriveResonanceDown extends TimedBuff {
  ZDriveResonanceDown(Mob target)
      : super(
          target: target,
          duration: 5.0,
          name: 'Z-Drive Resonance',
        );

  @override
  String get lastUpdate => VERSION_7_2_1;
}

class ZDriveResonance extends StackedBuff {
  ZDriveResonance(Mob target)
      : super(
          target: target,
          maxStacks: 3,
          duration: 4.0,
          timeBetweenFalloffs: .0,
          name: 'Z-Drive Resonance',
        );

  @override
  String get lastUpdate => VERSION_7_2_1;
}
