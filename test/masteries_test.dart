import 'package:lol_duel/dragon/dragon.dart';
import 'package:lol_duel/creator.dart';
import 'package:lol_duel/lolsim.dart';
import 'package:test/test.dart';

import 'utils.dart';

dynamic main() async {
  Creator creator = await Creator.loadLatest();

  Mastery masteryByName(String name, int rank) {
    MasteryDescription description =
        creator.dragon.masteries.masteryByName(name);
    return new Mastery(description, rank);
  }

  group("Double Edged Sword", () {
    test("damage amp", () {
      Mob doubleEdgeMob = createTestMob(
          hp: 1000.0,
          ad: 100.0,
          masteries: [masteryByName('Double Edged Sword', 1)]);
      Mob normalMob = createTestMob(hp: 1000.0, ad: 100.0);
      World world = new World();
      new AutoAttack(doubleEdgeMob, normalMob).apply(world);
      new AutoAttack(normalMob, doubleEdgeMob).apply(world);

      // Take 1.5% more damage, deal 3% more damage.
      expect(doubleEdgeMob.currentHp, 898.5);
      expect(normalMob.currentHp, 897.0);
    });
  });
  group('Sorcery', () {
    test('damage amp', () {
      Mob sorceryMob =
          createTestMob(hp: 1000.0, masteries: [masteryByName('Sorcery', 5)]);
      expect(sorceryMob.masteryPage.masteries.first.effects, isNotNull);
      Mob normalMob = createTestMob(hp: 1000.0);
      applyHit(source: sorceryMob, target: normalMob, magicDamage: 100.0);
      applyHit(target: sorceryMob, source: normalMob, magicDamage: 100.0);

      expect(sorceryMob.currentHp, 900.0);
      expect(normalMob.currentHp, 898.0);
    });
  });
  group("Tough Skin", () {
    test("damage reduction", () {
      Mob toughSkinMob =
          createTestMob(hp: 100.0, masteries: [masteryByName('Tough Skin', 1)]);
      Mob champion = createTestMob(ad: 10.0, type: MobType.champion);
      Mob monster = createTestMob(ad: 10.0, type: MobType.largeMonster);
      Mob minion = createTestMob(ad: 10.0, type: MobType.minion);
      World world = new World();
      new AutoAttack(champion, toughSkinMob).apply(world);
      expect(toughSkinMob.currentHp, 92.0);
      new AutoAttack(monster, toughSkinMob).apply(world);
      expect(toughSkinMob.currentHp, 84.0);
      new AutoAttack(minion, toughSkinMob).apply(world);
      expect(toughSkinMob.currentHp, 74.0);
      applyHit(source: champion, target: toughSkinMob, physicalDamage: 10.0);
      // Tough Skin has no effect on non-basic attacks.
      expect(toughSkinMob.currentHp, 64.0);
    });
  });
  group("Merciless", () {
    test("damage amp", () {
      Mob mercilessMob = createTestMob(
        hp: 100.0,
        masteries: [masteryByName('Merciless', 5)],
      );
      Mob healthyMob = createTestMob(hp: 1000.0, type: MobType.champion);
      expect(
        10.0,
        applyHit(
            target: healthyMob, source: mercilessMob, physicalDamage: 10.0),
      );

      Mob hurtMob = createTestMob(hp: 1000.0, type: MobType.champion);
      hurtMob.hpLost = 601.0;
      expect(hurtMob.healthPercent, lessThan(0.4));
      expect(
        10.5,
        applyHit(target: hurtMob, source: mercilessMob, physicalDamage: 10.0),
      );
      expect(
        10.5,
        applyHit(target: hurtMob, source: mercilessMob, magicDamage: 10.0),
      );
      expect(
        21.0,
        applyHit(
            target: hurtMob,
            source: mercilessMob,
            physicalDamage: 10.0,
            magicDamage: 10.0),
      );
    });
  });
  group("Savagery", () {
    test("damage amp", () {
      Mob savageryMob =
          createTestMob(hp: 100.0, masteries: [masteryByName('Savagery', 5)]);
      Mob normalMob = createTestMob(hp: 100.0);
      expect(
        15.0,
        applyHit(target: normalMob, source: savageryMob, physicalDamage: 10.0),
      );
      expect(
        15.0,
        applyHit(target: normalMob, source: savageryMob, magicDamage: 10.0),
      );
      expect(
        25.0,
        applyHit(
            target: normalMob,
            source: savageryMob,
            magicDamage: 10.0,
            physicalDamage: 10.0),
      );
    });

    test("single target only", () {
      Mob savageryMob =
          createTestMob(hp: 100.0, masteries: [masteryByName('Savagery', 5)]);
      Mob normalMob = createTestMob(hp: 100.0);
      expect(
        10.0,
        applyHit(
            target: normalMob,
            source: savageryMob,
            physicalDamage: 10.0,
            targeting: Targeting.aoe),
      );
    });
  });
  group('Precision', () {
    test('levels', () {
      Mob precisionMob =
          createTestMob(masteries: [masteryByName('Precision', 5)]);
      var expectedValues = <double>[
        1.75,
        2.0,
        2.25,
        2.5,
        2.75,
        3.0,
        3.25,
        3.5,
        3.75,
        4.0,
        4.25,
        4.5,
        4.75,
        5.0,
        5.25,
        5.5,
        5.75,
        6.0
      ];
      int level = 1;
      expectedValues.forEach((var expectedValue) {
        precisionMob.jumpToLevel(level);
        expect(precisionMob.stats.flatMagicPenetration, expectedValue);
        level++;
      });
    });
  });
  group('Unyielding', () {
    test('basic', () {
      Mob unyieldingMob = createTestMob(
          baseArmor: 100.0,
          baseSpellBlock: 100.0,
          masteries: [masteryByName('Unyielding', 5)]);
      expect(unyieldingMob.stats.spellBlock, 105.0);
      expect(unyieldingMob.stats.armor, 105.0);
    });
  });
}
