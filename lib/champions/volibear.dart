import 'package:lol_duel/lolsim.dart';
import 'package:lol_duel/buffs.dart';
import 'package:lol_duel/stat_constants.dart';
import 'package:lol_duel/champions.dart';

class Volibear extends ChampionEffects {
  Mob volibear;
  Volibear(this.volibear);

  @override
  void onDamageRecieved() {
    if (volibear.healthPercent > 0.3) return;
    if (volibear.buffs.any((buff) => buff is ChosenOfTheStorm)) return;
    volibear.addBuff(new ChosenOfTheStorm(volibear));
  }
}

class ChosenOfTheStorm extends TimedBuff {
  static double totalDuration = 120.0;
  static double healingDuration = 6.0;

  ChosenOfTheStorm(Mob target)
      : super(
          name: "Chosen of the Storm",
          target: target,
          duration: totalDuration,
        );

  // Volibear periodically regenerates 30% maximum health over 6 seconds when below 30% maximum health.
  double hpPerFive() {
    double timeActive = duration - remaining;
    if (timeActive >= healingDuration) return 0.0;
    double totalHeal = 0.3 * target.stats.hp;
    return (5.0 / healingDuration) * totalHeal;
  }

  @override
  Map<String, num> get stats => {
        FlatHPRegenMod: hpPerFive(),
      };
}
