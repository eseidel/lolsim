import 'package:lol_duel/champions/fiora.dart';
import "package:lol_duel/creator.dart";
import 'package:lol_duel/lolsim.dart';
import "package:test/test.dart";

import '../test_mob.dart';

dynamic main() async {
  Creator data = await Creator.loadLatest();

  group("Duelist's Dance", () {
    test("basic", () {
      Mob fiora = data.champs.championById('Fiora');
      // Make sure the buff appears on another champion
      // After a delay
      // AAing the champ consumes the buff and does extra damage.
      Mob mob = createTestMob(hp: 1000.0, type: MobType.champion);
      World world = new World(reds: [fiora], blues: [mob]);
      expect(mob.buffs.any((buff) => buff is MarkedWithVital), false);
      new AutoAttack(fiora, mob).apply(world);
      double damageWithoutVital = mob.hpLost;
      world.tickFor(.5);
      MarkedWithVital buff =
          mob.buffs.firstWhere((buff) => buff is MarkedWithVital);
      expect(buff, isNotNull);
      expect(buff.isActive, false);
      world.tickFor(.5);
      expect(buff.isActive, true);
      mob.hpLost = 0.0;
      new AutoAttack(fiora, mob).apply(world);
      expect(mob.buffs.any((buff) => buff is MarkedWithVital), false);
      expect(mob.hpLost, greaterThan(damageWithoutVital));
    });
  });
}
