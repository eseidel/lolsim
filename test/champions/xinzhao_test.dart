import 'package:lol_duel/creator.dart';
import 'package:lol_duel/lolsim.dart';
import 'package:test/test.dart';

import '../utils.dart';

dynamic main() async {
  Creator data = await Creator.loadLatest();
  group('Challange', () {
    test('basic', () {
      Mob xin = data.champs.championById('XinZhao');
      Mob mob = createTestMob(hp: 1000.0, baseArmor: 100.0);
      World world = new World();
      expect(mob.stats.armor, 100.0);
      new AutoAttack(xin, mob).apply(world);
      expect(mob.stats.armor, 85.0);
      mob.tick(4.0);
      expect(mob.stats.armor, 100.0);
    });
  });
}
