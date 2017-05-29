import 'lolsim.dart';
import 'dragon/dragon.dart';

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
        hp: hp,
        hpPerLevel: 0.0,
        hpRegen: 10 * hp,
        hpRegenPerLevel: 0.0,
        mp: 0.0,
        mpPerLevel: 0.0,
        spellBlock: 0.0,
        spellBlockPerLevel: 0.0,
      ),
    ),
    type,
  );
  mob.updateStats();
  return mob;
}
