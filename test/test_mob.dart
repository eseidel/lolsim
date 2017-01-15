import "package:lol_duel/lolsim.dart";
import 'package:lol_duel/mastery_pages.dart';

CritProvider alwaysCrit = (Mob) => true;

Mob createTestMob({
  double hp: 100.0,
  double ad: 10.0,
  double armor: 0.0,
  MobType type: MobType.minion,
  double hp5: 0.0,
  List<Mastery> masteries: const [],
}) {
  Mob mob = Mob.createMinion(MinionType.melee);
  mob.name = 'Test Mob';
  mob.baseStats.hp = hp;
  mob.baseStats.attackDamage = ad;
  mob.baseStats.armor = armor;
  mob.baseStats.hpRegen = hp5;
  mob.type = type;
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
