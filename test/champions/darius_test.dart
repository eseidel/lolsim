import 'package:lol_duel/champions/darius.dart';
import "package:lol_duel/dragon.dart";
import 'package:lol_duel/lolsim.dart';
import "package:test/test.dart";

import '../test_mob.dart';

main() async {
  DragonData data = await DragonData.loadLatest();

  group("Hemorrhage", () {
    test("basic", () {
      Mob darius = data.champs.championById('Darius');
      double dariusAd = darius.stats.attackDamage;
      Mob mob = createTestMob(hp: 1000.0);
      World world = new World();
      // AA applies bleed.
      new AutoAttack(darius, mob).apply(world);
      Hemorrhage buff = mob.buffs.firstWhere((buff) => buff is Hemorrhage);
      // DOT has not yet ticked yet.
      double singleTickDmg = (10 + (dariusAd * .3)) / 4;
      expect(mob.hpLost, dariusAd);
      // Bleeds tick every 1.25 seconds?
      buff.tick(2.0);
      expect(mob.hpLost, dariusAd + singleTickDmg);
      // Bleeds stack.
      expect(buff.stacks, 1);
      new AutoAttack(darius, mob).apply(world);
      expect(buff.stacks, 2);
      // Stacks are limited to 5.
      new AutoAttack(darius, mob).apply(world);
      expect(buff.stacks, 3);
      new AutoAttack(darius, mob).apply(world);
      expect(buff.stacks, 4);
      new AutoAttack(darius, mob).apply(world);
      expect(buff.stacks, 5);
      new AutoAttack(darius, mob).apply(world);
      expect(buff.stacks, 5);
      // Darius's AD increases at 5 stacks.
      expect(darius.stats.attackDamage, greaterThan(dariusAd));
      // Bleeds update on next application and scale with his AD.
      // Bleeds update on leveling?
      // Darius's AA's apply 5 stacks to new targets.
      // Stacks fall off one at a time.
    });
    test("structures", () {
      // The wiki doesn't say, but I don't believe he applies to structures?
      Mob darius = data.champs.championById('Darius');
      Mob structure = createTestMob(hp: 1000.0, type: MobType.structure);
      World world = new World();
      // AA does not apply bleed to structures?
      new AutoAttack(darius, structure).apply(world);
      bool hasBleed = structure.buffs.any((buff) => buff is Hemorrhage);
      expect(hasBleed, false);
    });
  });
}