import 'package:lol_duel/champions/darius.dart';
import "package:lol_duel/creator.dart";
import 'package:lol_duel/lolsim.dart';
import "package:test/test.dart";

import '../utils.dart';

dynamic main() async {
  Creator data = await Creator.loadLatest();

  group("Hemorrhage", () {
    test("basic", () {
      Mob darius = data.champs.championById('Darius');
      double dariusAd = darius.stats.attackDamage;
      Mob mob = createTestMob(hp: 1000.0, type: MobType.champion);
      World world = new World();
      // AA applies bleed.
      new AutoAttack(darius, mob).apply(world);
      Hemorrhage buff = mob.buffs.firstWhere((buff) => buff is Hemorrhage);
      // DOT has not yet ticked yet.
      double singleTickDmg = 10 / 4;
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
    test("items", () {
      Mob darius = data.champs.championById('Darius');
      darius.addItem(data.items.itemByName('Long Sword'));
      darius.updateStats();
      double dariusAd = darius.stats.attackDamage;
      Mob mob = createTestMob(hp: 1000.0);
      World world = new World();
      new AutoAttack(darius, mob).apply(world);
      Hemorrhage buff = mob.buffs.firstWhere((buff) => buff is Hemorrhage);
      expect(mob.hpLost, dariusAd);
      buff.tick(2.0); // Bleeds tick every 1.25 seconds.
      double singleTickDmg = (10 + 3.0) / 4;
      expect(mob.hpLost, dariusAd + singleTickDmg);
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
    test('7.2 Noxian Might Damage', () {
      List<int> levels = [1, 4, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18];
      List<int> expectedAd = [
        30,
        35,
        40,
        50,
        60,
        70,
        80,
        90,
        100,
        120,
        140,
        160,
        180,
        200
      ];
      List<int> actualAd = levels.map(NoxianMight.bonusAdForLevel).toList();
      expect(actualAd, expectedAd);
    });
  });
}
