import "package:test/test.dart";
import "package:lol_duel/dragon.dart";

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

  group("Doran's Shield", () {
    test("flat damage reduction", () {
      Mob mob = Mob.createMinion(MinionType.melee);
      mob.baseStats.hp = 100.0;
      mob.tick(0.0);

      expect(mob.currentHp, 100.0);
      mob.applyHit(new Hit(attackDamage: 20.0));
      expect(mob.currentHp, 80.0);
      mob.revive();
      expect(mob.currentHp, 100.0);
      Item doransShield = itemNamed("Doran's Shield");
      expect(doransShield.effects, isNotNull);
      mob.addItem(doransShield);
      mob.tick(0.0);
      expect(mob.currentHp, 180.0);
      mob.applyHit(new Hit(attackDamage: 20.0));
      expect(mob.currentHp, 168.0);
      mob.applyHit(new Hit(magicDamage: 20.0));
      expect(mob.currentHp, 156.0);
      mob.applyHit(new Hit(attackDamage: 10.0, magicDamage: 10.0));
      expect(mob.currentHp, 144.0);
      mob.applyHit(new Hit(trueDamage: 20.0));
      expect(mob.currentHp, 124.0);
    });
  });
}
