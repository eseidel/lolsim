import 'package:lol_duel/effects.dart';
import 'package:lol_duel/lolsim.dart';
import 'package:lol_duel/buffs.dart';

class MasterYi extends ChampionEffects {
  final Mob masterYi;

  MasterYi(this.masterYi);

  @override
  String get lastUpdate => VERSION_7_9_1;

  @override
  void onHit(Hit hit) {
    DoubleStrike buff = masterYi.buffs
        .firstWhere((buff) => buff is DoubleStrike, orElse: () => null);
    if (buff == null) {
      masterYi.addBuff(new DoubleStrike(masterYi));
      return;
    }

    if (buff.atMaxStacks) {
      buff.expire();
      masterYi.addBuff(new DoubleStrikeExecuting(masterYi));
    } else {
      buff.refreshAndAddStack();
    }
  }
}

class DoubleStrike extends StackedBuff {
  DoubleStrike(Mob masterYi)
      : super(
          name: "Double Strike",
          target: masterYi,
          duration: 4.0,
          timeBetweenFalloffs: 0.0,
          maxStacks: 3,
        );

  @override
  String get lastUpdate => VERSION_7_2_1;
}

class DoubleStrikeExecuting extends TimedBuff {
  DoubleStrikeExecuting(Mob masterYi)
      : super(name: "Double Strike", target: masterYi, duration: 0.1);

  @override
  String get lastUpdate => VERSION_7_2_1;

  @override
  void expire() {
    super.expire();

    Mob masterYi = target;
    if (!masterYi.alive) return;
    World world = World.current;
    Mob attackTarget = world.closestEnemyWithin(masterYi, 300);
    if (attackTarget == null) return;
    AutoAttack.applyAuto(
        world, masterYi, attackTarget, masterYi.stats.attackDamage * .5,
        label: 'Double Strike');
  }
}
