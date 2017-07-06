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
  group('Buffs', () {
    test('Crest of Cinders', () {
      Mob attacker = createTestMob(ad: 10.0);
      attacker.addBuff(new CrestOfCinders(attacker));
      Mob mob = createTestMob();
      World world = new World();
      new AutoAttack(attacker, mob).apply(world);
      expect(mob.hpLost, 14);
      mob.tick(1.0);
      expect(mob.hpLost, 14);
      mob.tick(0.5);
      expect(mob.hpLost, 18);
      mob.tick(1.5);
      expect(mob.hpLost, 22);
      mob.tick(1.5);
      expect(mob.hpLost, 22);
    });
  });
  group('Dragons', () {
    test('Level 18 hp', () {
      Mob ocean = createMonster(MonsterType.oceanDrake);
      ocean.level = 18;
      ocean.updateStats();
      // stat curving is currently always applied, but at least 18 should be right.
      expect(ocean.stats.hp, 7820.0);
    });
    test('Levels', () {
      // FIXME: Determined by average level of champions with a floor of lvl 6.
      void _verify(MonsterType type, int expectedLevel, double expectedHp) {
        Mob dragon = createMonster(type);
        expect(dragon.level, expectedLevel, reason: '$type level');
        expect(dragon.stats.hp, expectedHp, reason: '$type hp');
      }

      _verify(MonsterType.oceanDrake, 6, 4940.0);
      _verify(MonsterType.mountainDrake, 6, 5434.0);
      _verify(MonsterType.infernalDrake, 6, 4940.0);
      _verify(MonsterType.cloudDrake, 6, 4940.0);
    });
  });
}
