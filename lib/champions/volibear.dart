import 'package:lol_duel/mob.dart';
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
    double totalHeal = 0.3 * target.maxHp;
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

class VolibearW extends SingleTargetSpell {
  int rank;
  VolibearW(Mob champ, this.rank) : super(champ, 'Frenzy');

  @override
  String get lastUpdate => VERSION_7_10_1;

  @override
  bool canBeCastOn(Mob target) {
    Frenzy buff = frenzyBuff;
    return buff != null && buff.atMaxStacks && !isOnCooldown;
  }

  @override
  double get cooldownDuration => 18.0;

  Frenzy get frenzyBuff =>
      champ.buffs.firstWhere((buff) => buff is Frenzy, orElse: () => null);

  @override
  void onAutoAttackHit(Hit hit) {
    Frenzy frenzy = frenzyBuff;
    if (frenzy == null)
      champ.addBuff(new Frenzy(champ, rank));
    else
      frenzy.refreshAndAddStack();
  }

  double get _minimumDamage {
    // MINIMUM PHYSICAL DAMAGE: 60 / 110 / 160 / 210 / 260 (+ 15% bonus health)
    double base = [60.0, 110.0, 160.0, 210.0, 260.0][rank];
    return base + champ.stats.bonusHp * 0.15;
  }

  @override
  void castOn(Mob enemy) {
    if (isOnCooldown) return;
    if (!champ.spendManaIfPossible(35)) return;

    // Frenzy's cooldown is halved if it is used on a monster.
    double overrideDuration = enemy.isMonster ? cooldownDuration / 2.0 : null;
    startCooldown(champ, overrideBaseDuration: overrideDuration);

    // ACTIVE: Volibear bites the target enemy, dealing physical damage,
    // increasing by 0% - 100% (based on target's missing health).
    double damageAmp = 2.0 - enemy.healthPercent;
    enemy.applyHit(champ.createHitForTarget(
      label: name,
      physicalDamage: _minimumDamage * damageAmp,
      target: enemy,
      targeting: Targeting.singleTargetSpell,
    ));
  }
}
