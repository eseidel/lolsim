import 'package:lol_duel/creator.dart';
import 'package:lol_duel/lolsim.dart';
import 'package:test/test.dart';
import 'package:lol_duel/champions/drmundo.dart';
import '../utils.dart';

dynamic main() async {
  Creator data = await Creator.loadLatest();
  group("Adrenaline Rush", () {
    test("basic", () {
      Mob mundo = data.champs.championById('DrMundo');
      expect(mundo.buffs.any((buff) => buff is AdrenalineRush), true);
    });
    test("passive", () {
      Mob mundo = data.champs.championById('DrMundo');
      mundo.shouldRecordDamage = true;
      Mob attacker = createTestMob();
      World world = new World(reds: [mundo]);
      applyHit(source: attacker, target: mundo, trueDamage: 100.0);
      expect(mundo.hpLost, 100.0);
      double passiveHp5 = mundo.stats.hp * 0.003 * 5.0;
      double baseHp5 =
          mundo.description.baseStats.championCurvedStatsForLevel(1).hpRegen;
      expect(mundo.stats.hpRegen, passiveHp5 + baseHp5);
      double baseHpPerSecond = baseHp5 / 5.0;
      double passiveHpPerSecond = passiveHp5 / 5.0;
      double perSecondHp = baseHpPerSecond + passiveHpPerSecond;
      world.tickFor(1.0);
      expect(mundo.hpLost, closeTo(100.0 - perSecondHp, 0.01));
      world.tickFor(1.0);
      expect(mundo.hpLost, closeTo(100.0 - 2.0 * perSecondHp, 0.01));
    });
    test('items', () {
      Mob mundo = data.champs.championById('DrMundo');
      double initialHp = mundo.stats.hpRegen;
      // hp5 buff should be relative to total health, including items:
      mundo.addItem(data.items.itemByName('Ruby Crystal'));
      expect(mundo.stats.hpRegen, greaterThan(initialHp));
    });
  });
}
