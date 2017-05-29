import 'package:lol_duel/buffs.dart';
import 'package:lol_duel/effects.dart';
import 'package:lol_duel/lolsim.dart';

class Zed extends ChampionEffects {
  final Mob zed;

  Zed(this.zed);

  @override
  String get lastUpdate => VERSION_7_2_1;

  double get percentTheirMaxHealth {
    if (zed.level < 7) return 0.06;
    if (zed.level < 17) return 0.08;
    return 0.10;
  }

  // FIXME: This is implemented as a self-buff in game.
  @override
  void onHit(Hit hit) {
    if (hit.target.isStructure) return;
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
  ContemptForTheWeak(Mob target)
      : super(
          target: target,
          duration: 10.0,
          name: 'Contempt For The Weak',
        );

  @override
  String get lastUpdate => VERSION_7_2_1;
}
