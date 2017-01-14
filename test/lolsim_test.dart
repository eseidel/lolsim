import 'package:lol_duel/lolsim.dart';
import "package:test/test.dart";

import 'test_mob.dart';

main() async {
  group("Minions", () {
    test("attackspeed", () {
      Mob mob = Mob.createMinion(MinionType.melee);
      // Make sure I did the attack-delay math correctly:
      expect(mob.baseStats.baseAttackSpeed, 1.25);
    });
    test("super minion resistances", () {
      Mob mob = Mob.createMinion(MinionType.superMinion);
      expect(mob.stats.armor, 30.0);
      expect(mob.stats.spellBlock, -30.0);

      expect(mob.currentHp, 1500.0);
      mob.applyHit(new Hit(physicalDamage: 100.0));
      expect(mob.currentHp, 1423.076923076923);

      mob.revive();
      expect(mob.currentHp, 1500.0);
      mob.applyHit(new Hit(magicDamage: 100.0));
      expect(mob.currentHp, 1376.923076923077);
    });
  });
  group("Mob", () {
    test("death", () {
      // This is very confusing behavior, but at least we're testing it.
      Mob mob = createTestMob(hp: 100.0);
      mob.applyHit(new Hit(trueDamage: 99.9));
      expect(mob.alive, true);
      mob.applyHit(new Hit(trueDamage: 0.1));
      expect(mob.alive, false);
    });
  });
  group('AutoAttacks', () {
    test('crit', () {
      World world = new World();
      Mob mob1 = createTestMob(ad: 10.0);
      Mob mob2 = createTestMob(hp: 100.0);
      new AutoAttack(mob1, mob2).apply(world);
      expect(mob2.currentHp, 90);
      world.critProvider = alwaysCrit;
      new AutoAttack(mob1, mob2).apply(world);
      expect(mob2.currentHp, 70);
      mob1.stats.critDamageMultiplier = 3.0;
      new AutoAttack(mob1, mob2).apply(world);
      expect(mob2.currentHp, 40);
    });
  });
}
