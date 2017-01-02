import "package:test/test.dart";
import "package:lol_duel/dragon.dart";

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
      mob.applyHit(new Hit(attackDamage: 100.0));
      expect(mob.currentHp, 1423.076923076923);

      mob.revive();
      expect(mob.currentHp, 1500.0);
      mob.applyHit(new Hit(magicDamage: 100.0));
      expect(mob.currentHp, 1376.923076923077);
    });
  });
}
