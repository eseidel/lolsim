import 'package:lol_duel/champions/urgot.dart';
import "package:lol_duel/dragon.dart";
import 'package:lol_duel/lolsim.dart';
import "package:test/test.dart";

import '../test_mob.dart';

main() async {
  DragonData data = await DragonData.loadLatest();

  group("Zaun-Touched Bolt Augmenter", () {
    test("basic", () {
      Mob urgot = data.champs.championById('Urgot');
      Mob mob1 = createTestMob(ad: 100.0);
      Mob mob2 = createTestMob(hp: 1000.0);
      World world = new World();
      new AutoAttack(mob1, mob2).apply(world);
      expect(mob2.currentHp, 900);
      new AutoAttack(urgot, mob1).apply(world);
      expect(mob1.buffs.any((buff) => buff is ZaunTouchedBoltAugmenter), true);
      new AutoAttack(mob1, mob2).apply(world);
      expect(mob2.currentHp, 815);
      mob1.tick(2.0);
      expect(mob1.buffs.any((buff) => buff is ZaunTouchedBoltAugmenter), true);
      mob1.tick(0.5);
      expect(mob1.buffs.any((buff) => buff is ZaunTouchedBoltAugmenter), false);
    });
    test("structures", () {
      Mob urgot = data.champs.championById('Urgot');
      Mob structure = createTestMob(hp: 1000.0, type: MobType.structure);
      World world = new World();
      new AutoAttack(urgot, structure).apply(world);
      expect(structure.buffs.any((buff) => buff is ZaunTouchedBoltAugmenter),
          false);
    });
  });
}
