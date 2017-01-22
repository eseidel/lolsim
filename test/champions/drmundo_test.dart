import "package:lol_duel/creator.dart";
import 'package:lol_duel/lolsim.dart';
import "package:test/test.dart";
import 'package:lol_duel/champions/drmundo.dart';

main() async {
  Creator data = await Creator.loadLatest();
  group("Adrenaline Rush", () {
    test("basic", () {
      Mob mundo = data.champs.championById('DrMundo');
      expect(mundo.buffs.any((buff) => buff is AdrenalineRush), true);
    });
    test('items', () {
      Mob mundo = data.champs.championById('DrMundo');
      double initialHp = mundo.stats.hpRegen;
      // hp5 buff should be relative to total health, including items:
      mundo.addItem(data.items.itemByName('Ruby Crystal'));
      expect(mundo.stats.hpRegen, greaterThan(initialHp));
    }, skip: 'Buffs can only read base stats, so this fails.');
  });
}
