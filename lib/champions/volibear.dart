import 'package:lol_duel/lolsim.dart';
import 'package:lol_duel/buffs.dart';
import 'package:lol_duel/dragon/stat_constants.dart';
import 'package:lol_duel/effects.dart';

class Volibear extends ChampionEffects {
  final Mob volibear;

  Volibear(this.volibear);

  @override
  String get lastUpdate => VERSION_7_2_1;

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

  @override
  String get lastUpdate => VERSION_7_2_1;

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

class Frenzy extends StackedBuff {
  int rank;

  Frenzy(Mob target, this.rank)
      : super(
          name: 'Frenzy',
          maxStacks: 3,
          duration: 4.0,
          timeBetweenFalloffs: 0.0, // FIXME: Needs testing.
          target: target,
        );

  @override
  Map<String, num> get stats => {
        PercentAttackSpeedMod: 0.04 * rank,
      };

  @override
  String get lastUpdate => VERSION_7_10_1;
}

class VolibearW extends SpellEffects {
  Mob champ;
  int rank;
  VolibearW(this.champ, this.rank);

  @override
  String get lastUpdate => VERSION_7_10_1;

  @override
  void onHit(Hit hit) {
    Frenzy frenzy =
        champ.buffs.firstWhere((buff) => buff is Frenzy, orElse: () => null);
    if (frenzy == null)
      champ.addBuff(new Frenzy(champ, rank));
    else
      frenzy.refreshAndAddStack();
  }
}
