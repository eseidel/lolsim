import 'package:lol_duel/buffs.dart';
import 'package:lol_duel/champions.dart';
import 'package:lol_duel/lolsim.dart';
import 'package:lol_duel/stat_constants.dart';

// FIXME: This could share code with DOT.
class RelentlessAssault extends Buff {
  // 9 stacks
  // ticks every .25s
  // Duration of 2.5s
  // Refresh works differently, stacks get 2.5 + stack number.
  static int maxStacks = 8;
  static double duration = 2.5;
  static double timeBetweenFalloffs = 0.25;

  int stacks = 0;
  double untilFirstFalloff;
  double untilNextFalloff;

  RelentlessAssault(Mob jax) : super(name: 'RelentlessAssault', target: jax) {
    addStack();
  }

  void tick(double totalTimeDelta) {
    // FIXME: Handling totalTimeDelta > timeBetweenFalloffs is only for unittests
    // instead this 'catch-up' logic should move to a higher level.
    while (totalTimeDelta > 0 && !expired) {
      totalTimeDelta -= timeBetweenFalloffs;
      if (untilFirstFalloff > 0) {
        untilFirstFalloff -= timeBetweenFalloffs;
      } else {
        untilNextFalloff -= timeBetweenFalloffs;
      }
      if (untilFirstFalloff <= 0) {
        stacks -= 1;
        untilNextFalloff = timeBetweenFalloffs;
      }
      if (stacks <= 0) expire();
    }
  }

  void addStack() {
    if (stacks < maxStacks) stacks += 1;
    untilFirstFalloff = duration;
    untilNextFalloff = 0.0;
  }

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

  Map<String, num> get stats => {
        PercentAttackSpeedMod:
            stacks * bonusAttackSpeedPerStackForLevel(target.level),
      };
}

class Jax extends ChampionEffects {
  Mob jax;
  Jax(this.jax);

  void gainRelentlessAssault() {
    RelentlessAssault assault = jax.buffs
        .firstWhere((buff) => buff is RelentlessAssault, orElse: () => null);
    if (assault != null)
      assault.addStack();
    else {
      jax.addBuff(new RelentlessAssault(jax));
    }
  }

  @override
  void onHit(Hit hit) => gainRelentlessAssault();
}
