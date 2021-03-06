import 'package:lol_duel/lolsim.dart';
import 'package:lol_duel/dragon/dragon.dart';
import 'package:lol_duel/buffs.dart';
import 'package:meta/meta.dart';

CritProvider alwaysCrit = (Mob) => true;

ItemDescription createTestItem({Map<String, num> stats}) {
  return new ItemDescription.forTesting(
    stats: stats,
  );
}

class TestBuff extends PermanentBuff {
  final Map<String, num> _stats;

  TestBuff(Mob target, this._stats) : super('Test Buff', target);

  @override
  String get lastUpdate => null;

  @override
  Map<String, num> get stats => _stats;
}

Buff createTestBuff(Mob target, Map<String, num> stats) {
  return new TestBuff(target, stats);
}

double applyHit({
  @required Mob target,
  @required Mob source,
  double magicDamage: 0.0,
  double physicalDamage: 0.0,
  double trueDamage: 0.0,
  Targeting targeting: Targeting.singleTargetSpell,
}) {
  return target.applyHit(source.createHitForTarget(
    label: 'test',
    magicDamage: magicDamage,
    physicalDamage: physicalDamage,
    trueDamage: trueDamage,
    target: target,
    targeting: targeting,
  ));
}

Mob createTestMob({
  double hp: 100.0,
  double ad: 10.0,
  double baseArmor: 0.0,
  double baseSpellBlock: 0.0,
  MobType type: MobType.minion,
  double hp5: 0.0,
  double attackDelay: 0.0,
  double attackSpeedPerLevel: 0.0,
  int level: 1,
}) {
  Mob mob = new Mob(
    new MobDescription.forTesting(
      name: 'Test Mob',
      baseStats: new BaseStats(
        baseArmor: baseArmor,
        armorPerLevel: 0.0,
        baseAttackDamage: ad,
        attackDamagePerLevel: 0.0,
        attackSpeedPerLevel: attackSpeedPerLevel,
        attackDelay: attackDelay,
        baseHp: hp,
        hpPerLevel: 0.0,
        baseHpRegen: hp5,
        hpRegenPerLevel: 0.0,
        mpRegenPerLevel: 0.0,
        baseMpRegen: 0.0,
        mp: 0.0,
        mpPerLevel: 0.0,
        baseSpellBlock: baseSpellBlock,
        spellBlockPerLevel: 0.0,
      ),
    ),
    type,
  );
  mob.jumpToLevel(level);
  return mob;
}
