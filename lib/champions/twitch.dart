import 'package:lol_duel/lolsim.dart';
import 'package:lol_duel/buffs.dart';
import 'package:lol_duel/champions.dart';
import 'package:meta/meta.dart';

class DeadlyVenom extends DOT {
  Mob source;
  DeadlyVenom({@required this.source, @required Mob target})
      : super(
          name: 'Deadly Venom',
          target: target,
          duration: 6.0,
          secondsBetweenTicks: 1.0, // No clue if this is correct.
          maxStacks: 6,
        );

  double damagePerStackForLevel(int level) {
    if (level < 5) return 6.0;
    if (level < 9) return 12.0;
    if (level < 13) return 18.0;
    if (level < 17) return 24.0;
    return 30.0;
  }

  Hit createHitForStacks(int stackCount) {
    double totalDmgPerStack = damagePerStackForLevel(source.level);
    double dmgPerStackPerTick = totalDmgPerStack / initialTicks;
    // Choosing to do all the dmg at once for all stacks.
    return new Hit(
      source: source,
      target: target,
      label: name,
      trueDamage: dmgPerStackPerTick * stackCount,
    );
  }
}

class Twitch extends ChampionEffects {
  Mob twitch;
  Twitch(this.twitch);

  // FIXME: I don't think this should apply to structures, right?
  void applyDeadlyVenomStack(Mob target) {
    if (target.type == MobType.structure) return;
    DeadlyVenom bleed = target.buffs
        .firstWhere((buff) => buff is DeadlyVenom, orElse: () => null);
    if (bleed == null) {
      target.addBuff(new DeadlyVenom(
        source: twitch,
        target: target,
      ));
    } else {
      bleed.addStacks(1);
    }
  }

  @override
  void onHit(Hit hit) => applyDeadlyVenomStack(hit.target);
}
