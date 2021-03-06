import 'package:lol_duel/buffs.dart';
import 'package:lol_duel/effects.dart';
import 'package:lol_duel/mob.dart';

class JarvanIV extends ChampionEffects {
  final Mob jarvan;

  JarvanIV(this.jarvan);

  @override
  String get lastUpdate => VERSION_7_2_1;

  double get passiveCooldown {
    if (jarvan.level < 7) return 10.0;
    if (jarvan.level < 13) return 8.0;
    return 6.0;
  }

  // FIXME: This is implemented as a self-buff in game.
  @override
  void onAutoAttackHit(Hit hit) {
    if (!hit.target.isChampion) return;
    if (hit.target.buffs.any((buff) => buff is MartialCadence)) return;
    hit.target.addBuff(new MartialCadence(hit.target, passiveCooldown));
    hit.addOnHitDamage(new Damage(
      label: 'Martial Cadence',
      physicalDamage: 0.10 * hit.target.currentHp,
    ));
  }
}

class MartialCadence extends TimedBuff {
  MartialCadence(Mob target, double duration)
      : super(
          target: target,
          duration: duration,
          name: 'Martial Cadence',
        );

  @override
  String get lastUpdate => VERSION_7_2_1;
}
