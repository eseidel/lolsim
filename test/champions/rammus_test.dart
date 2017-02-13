import "package:lol_duel/creator.dart";
import 'package:lol_duel/lolsim.dart';
import "package:test/test.dart";
import 'package:lol_duel/champions/rammus.dart';

dynamic main() async {
  Creator data = await Creator.loadLatest();
  group("Spiked Shell", () {
    test("basic", () {
      // Should test against Armor reduction
      // Should test that this applies bonus AD (doesn't affect sheen).
      Mob rammus = data.champs.championById('Rammus');
      expect(rammus.buffs.any((buff) => buff is SpikedShell), true);
    });
    test('items', () {
      Mob rammus = data.champs.championById('Rammus');
      double initialAd = rammus.stats.attackDamage;
      double initialArmor = rammus.stats.armor;
      rammus.addItem(data.items.itemByName('Cloth Armor'));
      expect(initialArmor, lessThan(rammus.stats.armor));
      expect(initialAd, lessThan(rammus.stats.attackDamage));
    }, skip: 'Buffs can only read base stats, so this fails.');
  });
}
