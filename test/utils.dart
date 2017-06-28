import 'package:lol_duel/lolsim.dart';
import 'package:lol_duel/mastery_pages.dart';
import 'package:lol_duel/dragon/dragon.dart';
import 'package:lol_duel/buffs.dart';
import 'package:meta/meta.dart';

CritProvider alwaysCrit = (Mob) => true;

Item createTestItem({Map<String, num> stats}) {
  return new Item(new ItemDescription.forTesting(
    stats: stats,
  ));
}

class TestBuff extends PermanentBuff {
  final Map<String, num> _stats;

  TestBuff(this._stats);

  @override
  String get lastUpdate => null;

  @override
  Map<String, num> get stats => _stats;
}

Buff createTestBuff({Map<String, num> stats}) {
  return new TestBuff(stats);
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
  List<Mastery> masteries: const [],
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
        attackSpeedPerLevel: 0.0,
        attackDelay: 0.0,
        hp: hp,
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
  if (masteries.isNotEmpty) {
    mob.masteryPage = new MasteryPage(
      name: 'Test Page',
      masteries: masteries,
    );
    mob.masteryPage.initForChamp(mob);
    mob.masteryPage.logAnyMissingEffects();
  }
  mob.level = level;
  mob.updateStats();
  return mob;
}
