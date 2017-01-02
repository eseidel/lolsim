import "package:lol_duel/lolsim.dart";

Mob createTestMob({
  double hp: 100.0,
  double ad: 10.0,
  double armor: 0.0,
  isChampion: false,
}) {
  Mob mob = Mob.createMinion(MinionType.melee);
  mob.name = 'Test Mob';
  mob.baseStats.hp = hp;
  mob.baseStats.attackDamage = ad;
  mob.baseStats.armor = armor;
  mob.isChampion = isChampion;
  mob.updateStats();
  return mob;
}
