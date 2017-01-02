import "package:test/test.dart";
import "package:lol_duel/dragon.dart";

main() async {
  group("Minions", () {
    test("attackspeed", () {
      Mob mob = Mob.createMinion(MinionType.melee);
      // Make sure I did the attack-delay math correctly:
      expect(mob.baseStats.baseAttackSpeed, 1.25);
    });
  });
}
