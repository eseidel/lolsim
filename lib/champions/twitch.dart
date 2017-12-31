import 'package:lol_duel/buffs.dart';
import 'package:lol_duel/effects.dart';
import 'package:lol_duel/mob.dart';
import 'package:meta/meta.dart';

class DeadlyVenom extends DOT {
  final Mob source;

  DeadlyVenom({@required this.source, @required Mob target})
      : super(
          name: 'Deadly Venom',
          target: target,
          duration: 6.0,
          secondsBetweenTicks: 1.0, // No clue if this is correct.
          maxStacks: 6,
        );

  @override
  String get lastUpdate => VERSION_7_2_1;

  double damagePerStackForLevel(int level) {
    if (level < 5) return 6.0;
    if (level < 9) return 12.0;
    if (level < 13) return 18.0;
    if (level < 17) return 24.0;
    return 30.0;
  }

  @override
  Hit createHitForStacks(int stackCount) {
    double totalDmgPerStack = damagePerStackForLevel(source.level);
    double dmgPerStackPerTick = totalDmgPerStack / initialTicks;
    // Choosing to do all the dmg at once for all stacks.
    return source.createHitForTarget(
      target: target,
      label: name,
      trueDamage: dmgPerStackPerTick * stackCount,
      targeting: Targeting.dot,
    );
  }
}

class Twitch extends ChampionEffects {
  Mob twitch;
  Twitch(this.twitch);

  @override
  String get lastUpdate => VERSION_7_2_1;

  // FIXME: I don't think this should apply to structures, right?
  void applyDeadlyVenomStack(Mob target) {
    if (target.isStructure) return;
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
  void onAutoAttackHit(Hit hit) => applyDeadlyVenomStack(hit.target);
}
