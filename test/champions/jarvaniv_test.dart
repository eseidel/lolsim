import 'package:lol_duel/champions/jarvaniv.dart';
import 'package:lol_duel/creator.dart';
import 'package:lol_duel/lolsim.dart';
import 'package:test/test.dart';
import 'package:matcher/matcher.dart';

import '../test_mob.dart';

dynamic main() async {
  Creator data = await Creator.loadLatest();
  group('Martial Cadence', () {
    test('basic', () {
      Mob jarvan = data.champs.championById('JarvanIV');
      Mob mob = createTestMob(hp: 1000.0, type: MobType.champion);
      World world = new World();
      new AutoAttack(jarvan, mob).apply(world);
      expect(mob.buffs.any((buff) => buff is MartialCadence), true);
      expect(mob.hpLost, closeTo(jarvan.stats.attackDamage + 100.0, 0.01));
      mob.tick(5.0);
      expect(mob.buffs.any((buff) => buff is MartialCadence), true);
      new AutoAttack(jarvan, mob).apply(world);
      expect(
          mob.hpLost, closeTo(2.0 * jarvan.stats.attackDamage + 100.0, 0.01));
      mob.tick(5.0);
      expect(mob.buffs.any((buff) => buff is MartialCadence), false);
      double percentCurrentHp = mob.currentHp * 0.10;
      new AutoAttack(jarvan, mob).apply(world);
      expect(mob.hpLost,
          3.0 * jarvan.stats.attackDamage + 100.0 + percentCurrentHp);
    });
  });
}
