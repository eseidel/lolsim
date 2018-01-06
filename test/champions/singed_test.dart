import 'package:lol_duel/creator.dart';
import 'package:lol_duel/lolsim.dart';
import 'package:test/test.dart';
import 'package:lol_duel/champions/singed.dart';

dynamic main() async {
  Creator data = await Creator.loadLatest();
  group("Empowered Bulwark", () {
    test("basic", () {
      Mob singed = data.champs.championById('Singed');
      expect(singed.buffs.any((buff) => buff is EmpoweredBulwark), true);
    });
    test('items', () {
      Mob singed = data.champs.championById('Singed');
      double intialHealth = singed.maxHp;
      double initialMana = singed.stats.mp;
      singed.addItem(data.items.itemByName('Sapphire Crystal'));
      expect(initialMana, lessThan(singed.stats.mp));
      expect(intialHealth, lessThan(singed.maxHp));
    });
  });
}
