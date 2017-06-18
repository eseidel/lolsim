import 'package:lol_duel/champions/lulu.dart';
import 'package:lol_duel/creator.dart';
import 'package:lol_duel/lolsim.dart';
import 'package:test/test.dart';

import '../utils.dart';

dynamic main() async {
  Creator data = await Creator.loadLatest();
  group('Pix', () {
    test('basic', () {
      Mob lulu = data.champs.championById('Lulu');
      Mob mob = createTestMob(hp: 1000.0);
      World world = new World();
      new AutoAttack(lulu, mob).apply(world);
      expect(mob.hpLost, lulu.stats.attackDamage + 15);
    });
    test('level scaling', () {
      // expected copied from lolwiki.
      List<double> expected = [
        5,
        7,
        9,
        11,
        13,
        15,
        17,
        19,
        21,
        23,
        25,
        27,
        29,
        31,
        33,
        35,
        37,
        39
      ].map((i) => i.toDouble()).toList();
      Mob lulu = data.champs.championById('Lulu');

      Lulu luluEffects = lulu.championEffects;
      List<double> actual = new List.generate(18, (i) {
        lulu.level = i + 1;
        return luluEffects.damagePerPixShot;
      });
      expect(actual, expected);
    });
    // Should test ap scaling
    // Should probably test that they're a delay, not an on-hit
    // Test Pix does not provide lifesteal (likely does currently).
  });
}
