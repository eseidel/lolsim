import 'package:lol_duel/champions/masteryi.dart';
import 'package:lol_duel/creator.dart';
import 'package:lol_duel/lolsim.dart';
import 'package:test/test.dart';

import '../utils.dart';

dynamic main() async {
  Creator data = await Creator.loadLatest();

  group("Double Strike", () {
    test("basic", () {
      Mob masterYi = data.champs.championById('MasterYi');
      Mob mob = createTestMob(hp: 1000.0);
      mob.shouldRecordDamage = true;
      double oneAttackLength = masterYi.stats.attackDuration;
      World world = new World(reds: [masterYi], blues: [mob]);
      world.tickFor(oneAttackLength);
      DoubleStrike doubleStrike =
          masterYi.buffs.firstWhere((buff) => buff is DoubleStrike);
      expect(doubleStrike.stacks, 1);
      expect(mob.damageLog.totalDamage, masterYi.stats.attackDamage);

      world.tickFor(oneAttackLength);
      expect(doubleStrike.stacks, 2);
      expect(mob.damageLog.totalDamage, 2.0 * masterYi.stats.attackDamage);

      world.tickFor(oneAttackLength);
      expect(doubleStrike.stacks, 3);
      expect(mob.damageLog.totalDamage, 3.0 * masterYi.stats.attackDamage);

      world.tickFor(oneAttackLength);
      expect(mob.damageLog.totalDamage, 4.5 * masterYi.stats.attackDamage);
      expect(doubleStrike.expired, true);
      doubleStrike = masterYi.buffs.firstWhere((buff) => buff is DoubleStrike);
      expect(doubleStrike.stacks, 1);
    });
  });
}
