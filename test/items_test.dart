import 'package:lol_duel/creator.dart';
import 'package:lol_duel/lolsim.dart';
import 'package:test/test.dart';
import 'package:lol_duel/dragon/dragon.dart';

import 'utils.dart';

dynamic main() async {
  Creator data = await Creator.loadLatest();
  List<Item> items = data.items
      .allItems()
      .where((item) =>
          item.description.isAvailableOn(Maps.CURRENT_SUMMONERS_RIFT) &&
          item.description.generallyAvailable)
      .toList();

  Item itemNamed(String name) {
    try {
      return items.firstWhere((item) => item.name == name);
    } catch (e) {
      print("Failed to find $name");
      return null;
    }
  }

  group("Helper methods", () {
    test("createTestMob", () {
      Mob attacker = createTestMob();
      Mob mob = createTestMob(hp: 100.0);
      expect(mob.currentHp, 100.0);
      applyHit(source: attacker, target: mob, trueDamage: 10.0);
      expect(mob.currentHp, 90.0);
      mob.revive();
      expect(mob.currentHp, 100.0);
    });
  });

  group("Doran's Shield", () {
    test("flat damage reduction", () {
      Mob mob = createTestMob(hp: 100.0);
      Mob champ = createTestMob(hp: 100.0, type: MobType.champion);
      applyHit(source: champ, target: mob, physicalDamage: 20.0);
      expect(mob.currentHp, 80.0);
      mob.revive();

      Item doransShield = itemNamed("Doran's Shield");
      expect(doransShield.effects, isNotNull);
      mob.addItem(doransShield);
      expect(mob.currentHp, 180.0);
      mob.applyHit(champ.createHitForTarget(
          target: mob, physicalDamage: 20.0, label: 'test'));
      expect(mob.currentHp, 168.0);
      mob.applyHit(champ.createHitForTarget(
          target: mob, physicalDamage: 20.0, label: 'test'));
      expect(mob.currentHp, 156.0);
      mob.applyHit(champ.createHitForTarget(
          target: mob, physicalDamage: 10.0, magicDamage: 10.0, label: 'test'));
      expect(mob.currentHp, 144.0);
      mob.applyHit(champ.createHitForTarget(
          target: mob, trueDamage: 20.0, label: 'test'));
      expect(mob.currentHp, 124.0);
    });
    test("passive only applies to champion sources", () {
      Item doransShield = itemNamed("Doran's Shield");
      Mob champ = createTestMob(hp: 100.0, type: MobType.champion);
      champ.addItem(doransShield);
      Mob minion = createTestMob(hp: 100.0);
      minion.addItem(doransShield);
      expect(
          10.0, applyHit(source: minion, target: champ, physicalDamage: 10.0));
      expect(
          2.0, applyHit(source: champ, target: minion, physicalDamage: 10.0));
    });
    test("reduction cannot go negative", () {
      Item doransShield = itemNamed("Doran's Shield");
      Mob attacker = createTestMob(hp: 100.0, type: MobType.champion);
      Mob defender = createTestMob(hp: 100.0);
      defender.addItem(doransShield);
      expect(180.0, defender.currentHp);
      expect(
          12.0,
          defender.applyHit(attacker.createHitForTarget(
              physicalDamage: 20.0, target: defender, label: 'test')));
      expect(168.0, defender.currentHp);
      expect(
          0.0,
          defender.applyHit(attacker.createHitForTarget(
              physicalDamage: 1.0, target: defender, label: 'test')));
      expect(168.0, defender.currentHp);
    });
  });

  group("Doran's Blade", () {
    test("lifesteal", () {
      Mob attacker = createTestMob(hp: 100.0, ad: 192.0);
      Mob noArmor = createTestMob(hp: 1000.0, baseArmor: 0.0);
      Mob withArmor = createTestMob(hp: 1000.0, baseArmor: 100.0);

      attacker.addItem(itemNamed("Doran's Blade"));

      // Get attacker below full health so it can heal:
      expect(attacker.currentHp, 180.0);
      attacker.applyHit(noArmor.createHitForTarget(
          trueDamage: 80.0, target: attacker, label: 'test'));
      expect(attacker.currentHp, 100.0);

      expect(attacker.stats.attackDamage, 200.0);
      expect(attacker.stats.lifesteal, 0.03);

      World world = new World();
      new AutoAttack(attacker, noArmor).apply(world);
      expect(attacker.currentHp, 106.0);

      new AutoAttack(attacker, withArmor).apply(world);
      expect(attacker.currentHp, 109.0);
    });
  });
}
