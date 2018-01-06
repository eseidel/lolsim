import '../mob.dart';
import '../dragon/dragon.dart';

// FIXME: Potentially merge with createTestMob() in test/
Mob createDummyMob({double hp: 1000.0, MobType type: MobType.champion}) {
  Mob mob = new Mob(
    new MobDescription.forTesting(
      name: 'Dummy',
      baseStats: new BaseStats(
        baseArmor: 0.0,
        armorPerLevel: 0.0,
        baseAttackDamage: 0.0,
        attackDamagePerLevel: 0.0,
        attackSpeedPerLevel: 0.0,
        attackDelay: 0.0,
        baseHp: hp,
        hpPerLevel: 0.0,
        baseHpRegen: 10 * hp,
        hpRegenPerLevel: 0.0,
        mpRegenPerLevel: 0.0,
        baseMpRegen: 0.0,
        mp: 0.0,
        mpPerLevel: 0.0,
        baseSpellBlock: 0.0,
        spellBlockPerLevel: 0.0,
      ),
    ),
    type,
  );
  mob.updateStats();
  return mob;
}
