import 'package:lol_duel/dragon/stat_constants.dart';
import 'package:lol_duel/lolsim.dart';
import 'package:lol_duel/minions.dart';
import 'package:test/test.dart';

import 'utils.dart';

dynamic main() async {
  group("Minions", () {
    test("attackspeed", () {
      Mob mob = createMinion(MinionType.melee);
      // Make sure I did the attack-delay math correctly:
      expect(mob.description.baseStats.baseAttackSpeed, 1.25);
    });
    test("super minion resistances", () {
      Mob attacker = createTestMob();
      Mob mob = createMinion(MinionType.superMinion);
      expect(mob.stats.armor, 30.0);
      expect(mob.stats.spellBlock, -30.0);

      expect(mob.currentHp, 1700.0);
      applyHit(source: attacker, target: mob, physicalDamage: 100.0);
      expect(mob.currentHp, 1623.076923076923);

      mob.revive();
      expect(mob.currentHp, 1700.0);
      applyHit(source: attacker, target: mob, magicDamage: 100.0);
      expect(mob.currentHp, 1576.923076923077);
    });
  });
  group("Mob", () {
    test("death", () {
      Mob attacker = createTestMob();
      // This is very confusing behavior, but at least we're testing it.
      Mob mob = createTestMob(hp: 100.0);
      applyHit(source: attacker, target: mob, trueDamage: 99.9);
      expect(mob.alive, true);
      applyHit(source: attacker, target: mob, trueDamage: 0.1);
      expect(mob.alive, false);
    });
    test('healing', () {
      World world = new World();
      Mob attacker = createTestMob(ad: 10.0);
      Mob healer = createTestMob(hp: 100.0, hp5: 10.0);
      new AutoAttack(attacker, healer).apply(world);
      expect(healer.currentHp, 90);
      expect(healer.buffs.any((buff) => buff is Healing), true);
      healer.tick(1.0);
      expect(healer.currentHp, 92);
      healer.tick(4.0);
      expect(healer.currentHp, 100);
      expect(healer.buffs.any((buff) => buff is Healing), false);
    });
  });
  group('AutoAttacks', () {
    test('crit', () {
      World world = new World();
      Mob mob1 = createTestMob(ad: 10.0);
      Mob mob2 = createTestMob(hp: 100.0);
      new AutoAttack(mob1, mob2).apply(world);
      expect(mob2.currentHp, 90);
      world.critProvider = alwaysCrit;
      new AutoAttack(mob1, mob2).apply(world);
      expect(mob2.currentHp, 70);
      mob1.stats.critDamageMultiplier = 3.0;
      new AutoAttack(mob1, mob2).apply(world);
      expect(mob2.currentHp, 40);
    });
  });
  group('Letahlity', () {
    test('basic', () {
      // Flat Armor Penetration = LETHALITY × (0.6 + 0.4 × Target's level ÷ 18)
      expect(letalityToFlatPenatration(1), closeTo(0.622, 0.01));
      expect(letalityToFlatPenatration(6), closeTo(0.733, 0.01));
      expect(letalityToFlatPenatration(11), closeTo(0.844, 0.01));
      expect(letalityToFlatPenatration(18), 1);
    });
  });
  group('Armor', () {
    test('lolwiki example', () {
      World world = new World();
      // Given 30 flat armor reduction and 30% armor reduction, and the target
      // is affected by 10 flat armor penetration and 45% bonus armor penetration,
      var attacker = createTestMob(ad: 100.0);
      attacker.addItem(createTestItem(stats: {
        Lethality: 10,
        PercentBonusArmorPenetrationMod: 45,
      }));
      // Target A has 300 armor (100 base and 200 bonus armor).
      var targetA = createTestMob(
        baseArmor: 100.0,
        level: 18,
        hp: 1000.0,
      );
      targetA.addItem(createTestItem(stats: {
        FlatArmorMod: 200,
      }));
      Map debuffStats = {
        FlatArmorReduction: 30,
        PercentArmorMod: -30,
      };
      targetA.addBuff(createTestBuff(targetA, debuffStats));
      // The 300 is reduced to 270 (90 base and 180 bonus armor) by the 30 armor reduction.
      // The 270 is reduced to 189 (63 base and 126 bonus armor) by the 30% armor reduction.
      expect(targetA.stats.percentArmorMod, 0.7);
      expect(targetA.stats.baseArmor, closeTo(63, 0.01));
      expect(targetA.stats.bonusArmor, closeTo(126, 0.01));
      expect(targetA.stats.armor, closeTo(189, 0.01));
      // The 189 is considered to be 132.3 (63 base and 69.3 bonus armor) by the 45% bonus armor penetration.
      // The 132.3 is considered to be 122.3 by the 10 armor penetration.
      // Target A takes damage as if it has 122.3 armor.
      new AutoAttack(attacker, targetA).apply(world);
      expect(targetA.hpLost, closeTo(100.0 * (100.0 / (100.0 + 122.3)), 0.01));
      // Target B has 18 armor.
      var targetB = createTestMob(
        baseArmor: 18.0,
        level: 18,
        hp: 1000.0,
      );
      targetB.addBuff(createTestBuff(targetB, debuffStats));
      expect(targetB.stats.armor, -12);
      // The 18 is reduced to −12 by the 30 armor reduction.
      // The −12 is not affected by any further calculations because it is less than 0.
      // Target B takes damage as if it has −12 armor.
      new AutoAttack(attacker, targetB).apply(world);
      expect(targetB.hpLost, 100.0 * (2 - (100.0 / 112.0)));
    });
  });
  group('spell penetration', () {
    test('lolwiki example', () {
      // Given 20 flat magic resistance reduction and 30% magic resistance
      // reduction, and the target is affected by 10 flat magic penetration
      // and 35% magic penetration,

      var attacker = createTestMob();
      attacker.addItem(createTestItem(stats: {
        FlatMagicPenetrationMod: 10,
        PercentMagicPenetrationMod: 35,
      }));
      Map debuffStats = {
        FlatSpellBlockMod: -20,
        PercentSpellBlockMod: -30,
      };

      // Target A has 80 magic resistance.
      var targetA = createTestMob(hp: 1000.0);
      targetA.addItem(createTestItem(stats: {FlatSpellBlockMod: 80}));
      targetA.addBuff(createTestBuff(targetA, debuffStats));
      // The 80 is reduced to 60 by the 20 magic resistance reduction.
      // The 60 is reduced to 42 by the 30% magic resistance reduction.
      expect(targetA.stats.percentSpellBlockMod, 0.70);
      expect(targetA.stats.spellBlock, closeTo(42, 0.01));

      // The 42 is considered to be 27.3 by the 35% magic resistance penetration.
      // The 27.3 is considered to be 17.3 by the 10 magic resistance penetration.
      // Target A takes damage as if it has 17.3 magic resistance.
      applyHit(source: attacker, target: targetA, magicDamage: 100.0);
      expect(targetA.hpLost, closeTo(100.0 * (100.0 / (100.0 + 17.3)), 0.01));

      // Target B has 18 magic resistance.
      var targetB = createTestMob(baseSpellBlock: 18.0, hp: 1000.0);
      // The 18 is reduced to −2 by the 20 magic resistance reduction.
      // The −2 is not affected by any further calculations because it is less than 0.
      targetB.addBuff(createTestBuff(targetB, debuffStats));
      expect(targetB.stats.spellBlock, -2);
      // Target B takes damage as if it has −2 magic resistance.
      applyHit(source: attacker, target: targetB, magicDamage: 100.0);
      expect(targetB.hpLost, 100.0 * (2 - (100.0 / 102.0)));
    });
  });
  group('Champion Kill Experiance', () {
    test('basic', () {
      void expectKillExp(int killerLevel, int victimLevel, double expectedExp) {
        Mob killer = createTestMob(type: MobType.champion, level: killerLevel);
        Mob victim = createTestMob(type: MobType.champion, level: victimLevel);
        double beforeExp = killer.totalExperiance;
        World world = new World();
        world.makeCurrentForScope(() {
          applyHit(source: killer, target: victim, trueDamage: 10000.0);
        });
        double actualExp = killer.totalExperiance - beforeExp;
        expect(actualExp, closeTo(expectedExp, 0.5));
      }

      // FIXME: These numbers have not been validated with the practice tool.
      expectKillExp(1, 1, 140.0);
      expectKillExp(2, 2, 190.0);
      expectKillExp(1, 2, 203.5); // 7% bump for greater level.
      expectKillExp(3, 2, 176.7); // 7% reduction from lesser level
      expectKillExp(4, 2, 163.4); // -14%
      expectKillExp(5, 2, 152.0); // -20% (capped)
      expectKillExp(6, 2, 152.0); // -20% (capped)

      // 1880xp to reach lvl 18.
      // 1880 * 0.5 = 940
      // level diff = 17 - 1 = 16
      // 1.0 + (16 * 0.7) = 2.12x bonus exp for level diff
      // 940 * 2.12 = 1992.8
      expectKillExp(1, 17, 1992.8);
      expectKillExp(1, 18, 2168.1); // Is this right?
    });
  });
}
