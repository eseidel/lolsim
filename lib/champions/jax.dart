import 'package:lol_duel/buffs.dart';
import 'package:lol_duel/effects.dart';
import 'package:lol_duel/mob.dart';
import 'package:lol_duel/dragon/stat_constants.dart';

class RelentlessAssault extends StackedBuff {
  RelentlessAssault(Mob jax)
      : super(
          name: 'Relentless Assault',
          target: jax,
          duration: 2.5,
          maxStacks: 8,
          timeBetweenFalloffs: 0.25,
        );

  @override
  String get lastUpdate => VERSION_7_2_1;

  double bonusAttackSpeedPerStackForLevel(int level) {
    // http://leagueoflegends.wikia.com/wiki/Jax
    // 3.5,5,6.5,8,9.5,11
    // 1,4,7,10,13,16
    if (level < 4) return 0.035;
    if (level < 7) return 0.050;
    if (level < 10) return 0.065;
    if (level < 13) return 0.080;
    if (level < 16) return 0.095;
    return 0.0110;
  }

  @override
  Map<String, num> get stats => {
        PercentAttackSpeedMod:
            stacks * bonusAttackSpeedPerStackForLevel(target.level),
      };
}

class Jax extends ChampionEffects {
  final Mob jax;

  Jax(this.jax);

  @override
  String get lastUpdate => VERSION_7_2_1;

  void gainRelentlessAssault() {
    RelentlessAssault assault = jax.buffs
        .firstWhere((buff) => buff is RelentlessAssault, orElse: () => null);
    if (assault != null)
      assault.refreshAndAddStack();
    else {
      jax.addBuff(new RelentlessAssault(jax));
    }
  }

  @override
  void onAutoAttackHit(Hit hit) => gainRelentlessAssault();
}
