import "package:lol_duel/dragon.dart";
import 'package:lol_duel/lolsim.dart';
import "package:test/test.dart";
import 'package:lol_duel/champions/volibear.dart';
import '../test_mob.dart';

main() async {
  DragonData data = await DragonData.loadLatest();
  group("Chosen of the Storm", () {
    test("basic", () {
      Mob volibear = data.champs.championById('Volibear');
      Mob mob = createTestMob();
      double initialHp5 = volibear.stats.hpRegen;
      expect(false, volibear.buffs.any((buff) => buff is ChosenOfTheStorm));
      World world = new World();
      // Not triggered until < 30%.
      new AutoAttack(mob, volibear).apply(world);
      expect(false, volibear.buffs.any((buff) => buff is ChosenOfTheStorm));
      volibear.hpLost = volibear.stats.hp * .71;
      // Dmg below 30% triggers the buff.
      new AutoAttack(mob, volibear).apply(world);
      expect(true, volibear.buffs.any((buff) => buff is ChosenOfTheStorm));
      // hp5 increases
      expect(volibear.stats.hpRegen, greaterThan(initialHp5));
      volibear.tick(6.0);
      expect(volibear.stats.hpRegen, initialHp5);
    });
  });
}
