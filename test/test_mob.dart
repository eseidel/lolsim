import "package:lol_duel/lolsim.dart";
import 'package:lol_duel/mastery_pages.dart';
import 'package:lol_duel/dragon.dart';
import 'package:lol_duel/buffs.dart';

CritProvider alwaysCrit = (Mob) => true;

Item createTestItem({Map<String, num> stats}) {
  return new Item(new ItemDescription.forTesting(
    stats: stats,
  ));
}

class TestBuff extends PermanentBuff {
  Map<String, num> _stats;
  TestBuff(this._stats);

  @override
  Map<String, num> get stats => _stats;
}

Buff createTestBuff({Map<String, num> stats}) {
  return new TestBuff(stats);
}

Mob createTestMob({
  double hp: 100.0,
  double ad: 10.0,
  double armor: 0.0,
  MobType type: MobType.minion,
  double hp5: 0.0,
  List<Mastery> masteries: const [],
  int level: 1,
}) {
  Mob mob = new Mob(
    new MobDescription.forTesting(
      name: 'Test Mob',
      baseStats: new BaseStats(
        baseArmor: armor,
        armorPerLevel: 0.0,
        baseAttackDamage: ad,
        attackDamagePerLevel: 0.0,
        attackSpeedPerLevel: 0.0,
        attackDelay: 0.0,
        hp: hp,
        hpPerLevel: 0.0,
        hpRegen: hp5,
        hpRegenPerLevel: 0.0,
        mp: 0.0,
        mpPerLevel: 0.0,
        spellBlock: 0.0,
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
    mob.masteryPage.logAnyMissingEffects();
  }
  mob.level = level;
  mob.updateStats();
  return mob;
}
