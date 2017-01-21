import 'package:lol_duel/champions/zed.dart';
import 'package:lol_duel/dragon.dart';
import 'package:lol_duel/lolsim.dart';
import 'package:test/test.dart';

import '../test_mob.dart';

main() async {
  DragonData data = await DragonData.loadLatest();
  group("Contempt for the Weak", () {
    test("basic", () {
      Mob zed = data.champs.championById('Zed');
      Mob mob = createTestMob(hp: 1000.0);
      World world = new World();
      new AutoAttack(zed, mob).apply(world);
      expect(mob.hpLost, zed.stats.attackDamage);
      expect(mob.buffs.any((buff) => buff is ContemptForTheWeak), false);
      mob.hpLost = 501.0; // below 50%
      new AutoAttack(zed, mob).apply(world);
      expect(mob.hpLost, 501.0 + zed.stats.attackDamage + 60.0);
      expect(mob.buffs.any((buff) => buff is ContemptForTheWeak), true);
      mob.tick(5.0);
      expect(mob.buffs.any((buff) => buff is ContemptForTheWeak), true);
      new AutoAttack(zed, mob).apply(world);
      expect(mob.hpLost, 501.0 + 2.0 * zed.stats.attackDamage + 60.0);
      mob.tick(5.0);
      expect(mob.buffs.any((buff) => buff is ContemptForTheWeak), false);
      new AutoAttack(zed, mob).apply(world);
      expect(mob.hpLost, 501.0 + 3.0 * zed.stats.attackDamage + 120.0);
    });
  });
}
