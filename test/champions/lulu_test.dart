import "package:lol_duel/dragon.dart";
import 'package:lol_duel/lolsim.dart';
import "package:test/test.dart";
import '../test_mob.dart';

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
    // Should test ap scaling
    // Should probably test that they're a delay, not an on-hit
    // Test Pix does not provide lifesteal (likely does currently).
  });
}
