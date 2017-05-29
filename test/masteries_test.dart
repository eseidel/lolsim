import "package:lol_duel/dragon/dragon.dart";
import "package:lol_duel/creator.dart";
import 'package:lol_duel/lolsim.dart';
import "package:test/test.dart";

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

      // Take 2.5% more damage, deal 5% more damage.
      expect(doubleEdgeMob.currentHp, 897.5);
      expect(normalMob.currentHp, 895.0);
    });
  });
  group("Tough Skin", () {
    test("damage reduction", () {
      Mob toughSkinMob =
          createTestMob(hp: 100.0, masteries: [masteryByName('Tough Skin', 1)]);
      Mob champion = createTestMob(ad: 10.0, type: MobType.champion);
      Mob monster = createTestMob(ad: 10.0, type: MobType.monster);
      Mob minion = createTestMob(ad: 10.0, type: MobType.minion);
      World world = new World();
      new AutoAttack(champion, toughSkinMob).apply(world);
      expect(toughSkinMob.currentHp, 92.0);
      new AutoAttack(monster, toughSkinMob).apply(world);
      expect(toughSkinMob.currentHp, 84.0);
      new AutoAttack(minion, toughSkinMob).apply(world);
      expect(toughSkinMob.currentHp, 74.0);
      toughSkinMob.applyHit(new Hit(
        label: 'test',
        physicalDamage: 10.0,
        source: champion,
        targeting: Targeting.singleTargetSpell,
      ));
      // Tough Skin has no effect on non-basic attacks.
      expect(toughSkinMob.currentHp, 64.0);
    });
  });
  group("Merciless", () {
    test("damage amp", () {
      Mob mercilessMob =
          createTestMob(hp: 100.0, masteries: [masteryByName('Merciless', 5)]);
      Mob healthyMob = createTestMob(hp: 1000.0);
      Hit physicalHit = mercilessMob.createHitForTarget(
        target: healthyMob,
        label: 'test',
        physicalDamage: 10.0,
      );
      expect(10.0, healthyMob.applyHit(physicalHit));

      Mob hurtMob = createTestMob(hp: 1000.0);
      hurtMob.hpLost = 601.0;
      expect(hurtMob.healthPercent, lessThan(0.4));
      Hit healthyHit = mercilessMob.createHitForTarget(
        target: hurtMob,
        label: 'test',
        physicalDamage: 10.0,
      );
      expect(10.5, hurtMob.applyHit(healthyHit));
      Hit magicalHit = mercilessMob.createHitForTarget(
        target: hurtMob,
        label: 'test',
        physicalDamage: 10.0,
      );
      expect(10.5, hurtMob.applyHit(magicalHit));
      Hit mixedHit = mercilessMob.createHitForTarget(
        target: hurtMob,
        label: 'test',
        physicalDamage: 10.0,
        magicDamage: 10.0,
      );
      expect(21.0, hurtMob.applyHit(mixedHit));
    });
  });
  group("Savagery", () {
    test("damage amp", () {
      Mob savageryMob =
          createTestMob(hp: 100.0, masteries: [masteryByName('Savagery', 5)]);
      Mob normalMob = createTestMob(hp: 100.0);
      Hit physicalHit = savageryMob.createHitForTarget(
        target: normalMob,
        label: 'test',
        physicalDamage: 10.0,
      );
      expect(15.0, normalMob.applyHit(physicalHit));
      Hit magicalHit = savageryMob.createHitForTarget(
        target: normalMob,
        label: 'test',
        physicalDamage: 10.0,
      );
      expect(15.0, normalMob.applyHit(magicalHit));
      Hit mixedHit = savageryMob.createHitForTarget(
        target: normalMob,
        label: 'test',
        physicalDamage: 10.0,
        magicDamage: 10.0,
      );
      expect(25.0, normalMob.applyHit(mixedHit));
    });
  });
}
