import "package:lol_duel/dragon.dart";
import 'package:lol_duel/lolsim.dart';
import "package:test/test.dart";
import 'package:lol_duel/champions/tahm_kench.dart';
import 'package:matcher/matcher.dart';
import '../test_mob.dart';

main() async {
  DragonData data = await DragonData.loadLatest();
  group("An Acquired Taste", () {
    test("basic", () {
      Mob tahm = data.champs.championById('TahmKench');
      Mob mob = createTestMob(hp: 1000.0);
      World world = new World();
      new AutoAttack(tahm, mob).apply(world);
      expect(mob.hpLost, tahm.stats.attackDamage);
      AnAcquiredTaste buff =
          mob.buffs.firstWhere((buff) => buff is AnAcquiredTaste);
      expect(buff.stacks, 1);
      expect(mob.hpLost, tahm.stats.attackDamage);
      new AutoAttack(tahm, mob).apply(world);
      expect(buff.stacks, 2);
      expect(mob.hpLost, 2.0 * tahm.stats.attackDamage + 0.01 * tahm.stats.hp);
      new AutoAttack(tahm, mob).apply(world);
      expect(buff.stacks, 3);
      new AutoAttack(tahm, mob).apply(world);
      expect(buff.stacks, 3);
    });
    test('lifesteal', () {
      Mob tahm = data.champs.championById('TahmKench');
      tahm.addItem(data.items.itemByName('Vampiric Scepter'));
      Mob mob = createTestMob(hp: 1000.0);
      World world = new World();
      tahm.stats.lifesteal = 0.10;
      tahm.hpLost = tahm.currentHp - 1; // 1 health.
      double previousHp = tahm.currentHp;
      double expectedBaseLifesteal = tahm.stats.attackDamage * 0.1;
      new AutoAttack(tahm, mob).apply(world);
      expect(
          tahm.currentHp - previousHp, closeTo(expectedBaseLifesteal, 0.001));
      previousHp = tahm.currentHp;
      new AutoAttack(tahm, mob).apply(world);
      // His on-hit should be included in lifesteal?
      expect(tahm.currentHp - previousHp, greaterThan(expectedBaseLifesteal));
    });
  });
}
