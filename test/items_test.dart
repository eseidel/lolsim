import 'package:lol_duel/creator.dart';
import 'package:lol_duel/dragon/dragon.dart';
import 'package:lol_duel/items.dart';
import 'package:lol_duel/lolsim.dart';
import 'package:lol_duel/planning.dart';
import 'package:test/test.dart';

import 'utils.dart';

dynamic main() async {
  Creator data = await Creator.loadLatest();
  List<ItemDescription> items = data.items
      .all()
      .where((item) =>
          item.isAvailableOn(Maps.CURRENT_SUMMONERS_RIFT) &&
          item.generallyAvailable)
      .toList();

  ItemDescription itemNamed(String name) {
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
    test("basic", () {
      Mob mob = createTestMob(hp: 100.0, ad: 10.0);
      Mob minion = createTestMob(type: MobType.minion);
      Mob champ = createTestMob(type: MobType.champion);
      mob.addItem(itemNamed(ItemNames.DoransShield));
      expect(mob.maxHp, 180.0);
      expect(mob.stats.hpRegen, 6.0);
      World world = new World(blues: [mob]);
      new AutoAttack(mob, minion).apply(world);
      expect(minion.hpLost, 15.0);
      applyHit(target: mob, source: champ, trueDamage: 50.0);
      expect(mob.currentHp, 130.0);
      world.tickFor(10.0);
      // 12 + 20 from recovery = 32hp.
      expect(mob.currentHp, closeTo(162.0, 0.01));
      world.tickFor(5.0);
      // Recovery is done now.
      // FIXME: Buffs appear to tick one extra time?
      expect(mob.currentHp, closeTo(168.0, 0.01));
    });
  });

  group("Doran's Blade", () {
    test("lifesteal", () {
      Mob attacker = createTestMob(hp: 100.0, ad: 192.0);
      Mob noArmor = createTestMob(hp: 1000.0, baseArmor: 0.0);
      Mob withArmor = createTestMob(hp: 1000.0, baseArmor: 100.0);

      attacker.addItem(itemNamed(ItemNames.DoransBlade));

      // Get attacker below full health so it can heal:
      expect(attacker.currentHp, 180.0);
      applyHit(source: noArmor, target: attacker, trueDamage: 80.0);
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

  group("Health Potion", () {
    test("basic", () {
      Mob user = createTestMob(hp: 1000.0);
      applyHit(target: user, source: createTestMob(), trueDamage: 500.0);
      user.addItem(itemNamed(ItemNames.HealthPotion));
      expect(user.items.length, 1);
      World world = new World(reds: [user]);
      new SelfCastItem(user.items[0]).apply(world);
      expect(user.items.length, 0);
      world.tickFor(12.0);
      expect(user.hpLost, 350.0);
    });
  });

  group("Refillable Potion", () {
    test("basic", () {
      Mob user = createTestMob(hp: 1000.0);
      applyHit(target: user, source: createTestMob(), trueDamage: 500.0);
      user.addItem(itemNamed(ItemNames.RefillablePotion));
      expect(user.items.length, 1);
      World world = new World(reds: [user]);
      new SelfCastItem(user.items[0]).apply(world);
      expect(user.items.length, 1);
      world.tickFor(12.0);
      expect(user.hpLost, closeTo(375.0, 0.1));
    });
  });
}
