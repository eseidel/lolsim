import 'package:lol_duel/lolsim.dart';
import 'package:lol_duel/monsters.dart';
import 'package:test/test.dart';

import 'utils.dart';

dynamic main() async {
  group('Gromp', () {
    test('Attack speed buff', () {
      Mob mob = createTestMob(hp: 1000.0);
      Mob gromp = createMonster(MonsterType.gromp);
      World world = new World(reds: [gromp], blues: [mob]);
      expect(gromp.stats.attackSpeed, closeTo(1.004, 0.001));
      expect(gromp.stats.attackDamage, 70.0);
      world.tickFor(1.0);
      expect(gromp.stats.attackSpeed, closeTo(0.876, 0.001), skip: true);
      expect(gromp.stats.attackDamage, 66.0);
      world.tickFor(1.0);
      expect(gromp.stats.attackSpeed, closeTo(0.781, 0.001), skip: true);
      expect(gromp.stats.attackDamage, 62.0);
      world.tickFor(1.0);
      expect(gromp.stats.attackSpeed, closeTo(0.661, 0.001), skip: true);
      expect(gromp.stats.attackDamage, 58.0);
      world.tickFor(1.0);
      expect(gromp.stats.attackSpeed, closeTo(0.575, 0.001), skip: true);
      expect(gromp.stats.attackDamage, 54.0);
      world.tickFor(1.0);
      expect(gromp.stats.attackSpeed, closeTo(0.501, 0.001));
      expect(gromp.stats.attackDamage, 50.0);
    });
  });
}
