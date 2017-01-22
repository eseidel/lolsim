import "package:lol_duel/dragon.dart";
import 'package:lol_duel/lolsim.dart';
import "package:test/test.dart";
import '../test_mob.dart';
import 'package:lol_duel/champions/lulu.dart';

main() async {
  DragonData data = await DragonData.loadLatest();
  group('Pix', () {
    test('basic', () {
      Mob lulu = data.champs.championById('Lulu');
      Mob mob = createTestMob(hp: 1000.0);
      World world = new World();
      new AutoAttack(lulu, mob).apply(world);
      expect(mob.hpLost, lulu.stats.attackDamage + 9);
    });
    test('level scaling', () {
      // expected copied from lolwiki.
      List<double> expected = [
        3,
        3,
        7,
        7,
        11,
        11,
        15,
        15,
        19,
        19,
        23,
        23,
        27,
        27,
        31,
        31,
        35,
        35
      ].map((i) => i.toDouble()).toList();
      Mob lulu = data.champs.championById('Lulu');

      Lulu luluEffects = lulu.effects;
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
