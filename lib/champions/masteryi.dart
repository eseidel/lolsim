import 'package:lol_duel/effects.dart';
import 'package:lol_duel/mob.dart';
import 'package:lol_duel/world.dart';
import 'package:lol_duel/buffs.dart';
import 'package:lol_duel/dragon/stat_constants.dart';

class MasterYi extends ChampionEffects {
  final Mob masterYi;

  MasterYi(this.masterYi);

  @override
  String get lastUpdate => VERSION_7_9_1;

  @override
  void onAutoAttackHit(Hit hit) {
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
      world,
      masterYi,
      attackTarget,
      masterYi.stats.attackDamage * .5,
      label: 'Double Strike',
    );
  }
}

class WujuStyleActive extends TimedBuff {
  double damage;
  WujuStyleActive(Mob champ, this.damage)
      : super(target: champ, name: 'Wuju Style', duration: 5.0);

  @override
  String get lastUpdate => VERSION_7_24_1;

  @override
  void onAutoAttackHit(Hit hit) {
    hit.addOnHitDamage(new Damage(label: name, trueDamage: damage));
  }
}

class MasterYiE extends SelfTargetedSpell {
  int rank;
  MasterYiE(Mob champ, this.rank) : super(champ, 'Wuju Style');

  @override
  String get lastUpdate => VERSION_7_24_1;

  @override
  bool get isActiveToggle => false;
  @override
  bool get canBeCastOnSelf => !isOnCooldown;
  @override
  double get cooldownDuration => 19.0 - rank;

  @override
  void castOnSelf() {
    if (isOnCooldown) return;
    startCooldown(champ);

    double damage = 5 + 9 * rank + .25 * champ.stats.attackDamage;
    champ.addBuff(new WujuStyleActive(champ, damage));
  }

  @override
  Map<String, num> get stats => isOnCooldown
      ? null
      : {
          // FIXME: This is likely wrong should be PercentPhysicalDamageMod?
          FlatPhysicalDamageMod: 0.1 * champ.stats.attackDamage,
        };
}
