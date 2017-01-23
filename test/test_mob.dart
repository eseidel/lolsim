import "package:lol_duel/lolsim.dart";
import 'package:lol_duel/mastery_pages.dart';
import 'package:lol_duel/dragon.dart';

CritProvider alwaysCrit = (Mob) => true;

Mob createTestMob({
  double hp: 100.0,
  double ad: 10.0,
  double armor: 0.0,
  MobType type: MobType.minion,
  double hp5: 0.0,
  List<Mastery> masteries: const [],
}) {
  Mob mob = new Mob(
    new MobDescription(
      name: 'Test Mob',
      baseStats: new BaseStats(
        armor: armor,
        armorPerLevel: 0.0,
        attackDamage: ad,
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
  mob.updateStats();
  return mob;
}
