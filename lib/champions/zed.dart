import 'package:lol_duel/buffs.dart';
import 'package:lol_duel/champions.dart';
import 'package:lol_duel/dragon.dart';
import 'package:lol_duel/lolsim.dart';
import 'package:meta/meta.dart';

class Zed extends ChampionEffects {
  Mob zed;
  Zed(this.zed);

  double get percentTheirMaxHealth {
    if (zed.level < 7) return 0.06;
    if (zed.level < 17) return 0.08;
    return 0.10;
  }

  // FIXME: This is implemented as a self-buff in game.
  @override
  void onHit(Hit hit) {
    if (hit.target.type == MobType.structure) return;
    // Should shields count in this calculation?
    if (hit.target.healthPercent >= .5) return;
    if (hit.target.buffs.any((buff) => buff is ContemptForTheWeak)) return;
    hit.target.addBuff(new ContemptForTheWeak(hit.target));
    hit.addOnHitDamage(new Damage(
      label: 'Contempt For The Weak',
      magicDamage: percentTheirMaxHealth * hit.target.stats.hp,
    ));
  }
}

class ContemptForTheWeak extends TimedBuff {
  ContemptForTheWeak(@required Mob target)
      : super(
          target: target,
          duration: 10.0,
          name: 'Contempt For The Weak',
        ) {}
}
