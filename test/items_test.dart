import "package:test/test.dart";
import "package:lol_duel/dragon.dart";
import 'test_mob.dart';

main() async {
  DragonData data = await DragonData.loadLatest();
  List<Item> items = data.items
      .allItems()
      .where((item) =>
          item.isAvailableOn(Maps.CURRENT_SUMMONERS_RIFT) &&
          item.generallyAvailable)
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
      Mob mob = createTestMob(hp: 100.0);
      expect(mob.currentHp, 100.0);
      mob.applyHit(new Hit(trueDamage: 10.0));
      expect(mob.currentHp, 90.0);
      mob.revive();
      expect(mob.currentHp, 100.0);
    });
  });

  group("Doran's Shield", () {
    test("flat damage reduction", () {
      Mob mob = createTestMob(hp: 100.0);
      Mob champ = createTestMob(hp: 100.0, isChampion: true);
      mob.applyHit(new Hit(attackDamage: 20.0));
      expect(mob.currentHp, 80.0);
      mob.revive();

      Item doransShield = itemNamed("Doran's Shield");
      expect(doransShield.effects, isNotNull);
      mob.addItem(doransShield);
      mob.tick(0.0);
      expect(mob.currentHp, 180.0);
      mob.applyHit(new Hit(attackDamage: 20.0, source: champ));
      expect(mob.currentHp, 168.0);
      mob.applyHit(new Hit(magicDamage: 20.0, source: champ));
      expect(mob.currentHp, 156.0);
      mob.applyHit(
          new Hit(attackDamage: 10.0, magicDamage: 10.0, source: champ));
      expect(mob.currentHp, 144.0);
      mob.applyHit(new Hit(trueDamage: 20.0, source: champ));
      expect(mob.currentHp, 124.0);
    });
    test("passive only applies to champion sources", () {
      Item doransShield = itemNamed("Doran's Shield");
      Mob champ = createTestMob(hp: 100.0, isChampion: true);
      champ.addItem(doransShield);
      Mob minion = createTestMob(hp: 100.0);
      minion.addItem(doransShield);
      expect(10.0, champ.applyHit(new Hit(attackDamage: 10.0, source: minion)));
      expect(2.0, minion.applyHit(new Hit(attackDamage: 10.0, source: champ)));
    });
  });

  group("Doran's Blade", () {
    test("lifesteal", () {
      Mob attacker = createTestMob(hp: 100.0, ad: 192.0);
      Mob noArmor = createTestMob(hp: 1000.0, armor: 0.0);
      Mob withArmor = createTestMob(hp: 1000.0, armor: 100.0);

      attacker.addItem(itemNamed("Doran's Blade"));
      attacker.tick(0.0);

      // Get attacker below full health so it can heal:
      expect(attacker.currentHp, 180.0);
      attacker.applyHit(new Hit(trueDamage: 80.0));
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
