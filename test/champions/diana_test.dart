import "package:lol_duel/dragon.dart";
import 'package:lol_duel/lolsim.dart';
import "package:test/test.dart";
import '../test_mob.dart';

main() async {
  DragonData data = await DragonData.loadLatest();
  group('Moonsilver Blade', () {
    test('basic', () {
      Mob diana = data.champs.championById('Diana');
      Mob mob = createTestMob(hp: 1000.0);
      World world = new World();
      new AutoAttack(diana, mob).apply(world);
      expect(mob.hpLost, diana.stats.attackDamage);
      new AutoAttack(diana, mob).apply(world);
      expect(mob.hpLost, 2.0 * diana.stats.attackDamage);
      new AutoAttack(diana, mob).apply(world);
      expect(mob.hpLost, 3.0 * diana.stats.attackDamage + 20); // first proc
      new AutoAttack(diana, mob).apply(world);
      expect(mob.hpLost, 4.0 * diana.stats.attackDamage + 20);
      new AutoAttack(diana, mob).apply(world);
      expect(mob.hpLost, 5.0 * diana.stats.attackDamage + 20);
      new AutoAttack(diana, mob).apply(world);
      expect(mob.hpLost, 6.0 * diana.stats.attackDamage + 40); // second proc
    });
  });
}
