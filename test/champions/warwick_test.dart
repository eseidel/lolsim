import 'package:lol_duel/champions/warwick.dart';
import "package:lol_duel/creator.dart";
import 'package:lol_duel/lolsim.dart';
import "package:test/test.dart";

import '../test_mob.dart';

main() async {
  Creator data = await Creator.loadLatest();
  group('Eternal Hunger', () {
    test('basic', () {
      Mob warwick = data.champs.championById('Warwick');
      Mob mob = createTestMob(hp: 1000.0);
      World world = new World();
      new AutoAttack(warwick, mob).apply(world);
      double onHitBonus = 10.0;
      expect(mob.hpLost, warwick.stats.attackDamage + onHitBonus);
      // Heals when under 50% hp.
      warwick.hpLost = warwick.stats.hp * 0.51;
      double previousHp = warwick.currentHp;
      new AutoAttack(warwick, mob).apply(world);
      expect(warwick.currentHp, previousHp + onHitBonus);
      // 3x heals under 25% hp.
      warwick.hpLost = warwick.stats.hp * 0.76;
      previousHp = warwick.currentHp;
      new AutoAttack(warwick, mob).apply(world);
      expect(warwick.currentHp, previousHp + 3 * onHitBonus);
    });
    test('level scaling', () {
      // expected copied from lolwiki.
      List<double> expected = [
        10,
        12,
        14,
        16,
        18,
        20,
        22,
        24,
        26,
        28,
        30,
        32,
        34,
        36,
        38,
        40,
        42,
        44
      ].map((i) => i.toDouble()).toList();
      List<double> actual = new List.generate(18, (i) {
        return Warwick.bonusDamagePerLevel(i + 1);
      });
      expect(actual, expected);
    });
  });
}
