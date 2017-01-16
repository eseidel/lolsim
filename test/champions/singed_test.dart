import "package:lol_duel/dragon.dart";
import 'package:lol_duel/lolsim.dart';
import "package:test/test.dart";
import 'package:lol_duel/champions/singed.dart';

main() async {
  DragonData data = await DragonData.loadLatest();
  group("Empowered Bulwark", () {
    test("basic", () {
      Mob singed = data.champs.championById('Singed');
      expect(singed.buffs.any((buff) => buff is EmpoweredBulwark), true);
    });
    test('items', () {
      Mob singed = data.champs.championById('Singed');
      double intialHealth = singed.stats.hp;
      double initialMana = singed.stats.mp;
      singed.addItem(data.items.itemByName('Sapphire Crystal'));
      expect(initialMana, lessThan(singed.stats.mp));
      expect(intialHealth, lessThan(singed.stats.hp));
    }, skip: 'Buffs can only read base stats, so this fails.');
  });
}
