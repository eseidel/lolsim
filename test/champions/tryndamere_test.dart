import 'package:lol_duel/champions/tryndamere.dart';
import "package:lol_duel/creator.dart";
import 'package:lol_duel/lolsim.dart';
import "package:test/test.dart";

import '../test_mob.dart';

main() async {
  Creator data = await Creator.loadLatest();

  group("Battle Fury", () {
    test("basic", () {
      Mob tryndamere = data.champs.championById('Tryndamere');
      Mob mob = createTestMob(hp: 1000.0);
      BattleFury battleFury =
          tryndamere.buffs.firstWhere((buff) => buff is BattleFury);
      expect(battleFury.fury, 0);
      World world = new World();
      new AutoAttack(tryndamere, mob).apply(world);
      // Each aa gives 5 Fury
      expect(battleFury.fury, 5);
      world.critProvider = alwaysCrit;
      // crits give 10 Fury
      new AutoAttack(tryndamere, mob).apply(world);
      expect(battleFury.fury, 15);
      // 100 is fury cap.
      battleFury.fury = 95;
      new AutoAttack(tryndamere, mob).apply(world);
      expect(battleFury.fury, 100);
      new AutoAttack(tryndamere, mob).apply(world);
      expect(battleFury.fury, 100);

      // fury gives crit chance
      tryndamere.updateStats();
      expect(tryndamere.stats.critChance, closeTo(0.35, 0.001));

      // FIXME: Not taking or dealing dmg for 8s causes fury decay
      // fury decays at 5 fury per second.
      // tryndamere.tick(7.0);
      // expect(battleFury.fury, 100);
      // tryndamere.tick(1.0);
      // expect(battleFury.fury, 95);
      // tryndamere.tick(1.0);
      // expect(battleFury.fury, 90);
      // tryndamere.tick(18.0);
      // expect(battleFury.fury, 0);
    });
  });
}
