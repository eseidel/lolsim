import 'package:lol_duel/buffs.dart';
import 'package:lol_duel/champions.dart';
import 'package:lol_duel/lolsim.dart';

class JarvanIV extends ChampionEffects {
  Mob jarvan;
  JarvanIV(this.jarvan);

  double get passiveCooldown {
    if (jarvan.level < 7) return 10.0;
    if (jarvan.level < 13) return 8.0;
    return 6.0;
  }

  // FIXME: This is implemented as a self-buff in game.
  @override
  void onHit(Hit hit) {
    if (hit.target.type != MobType.champion) return;
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
        ) {}
}
