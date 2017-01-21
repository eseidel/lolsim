import "package:lol_duel/dragon.dart";
import 'package:lol_duel/lolsim.dart';
import "package:test/test.dart";
import 'package:lol_duel/champions/orianna.dart';
import '../test_mob.dart';

main() async {
  DragonData data = await DragonData.loadLatest();
  group("Clockwork Winding", () {
    test("basic", () {
      Mob oriana = data.champs.championById('Orianna');
      Mob mob = createTestMob(hp: 1000.0);
      World world = new World();
      new AutoAttack(oriana, mob).apply(world);
      expect(mob.hpLost, oriana.stats.attackDamage + 10);
      ClockworkWinding buff =
          mob.buffs.firstWhere((buff) => buff is ClockworkWinding);
      expect(buff.stacks, 1);
      new AutoAttack(oriana, mob).apply(world);
      expect(buff.stacks, 2);
      expect(mob.hpLost, 2.0 * oriana.stats.attackDamage + 22.0);
      new AutoAttack(oriana, mob).apply(world);
      expect(mob.hpLost, 3.0 * oriana.stats.attackDamage + 36.0);
      expect(buff.stacks, 2);
      // According to OrianaMains discord, both stacks drop at 4s.
      mob.tick(3.5);
      expect(buff.stacks, 2);
      mob.tick(.5);
      expect(buff.stacks, 0);
      // dmg per level?
      // attacking a structure in between?
      // ap scaling.
    });
  });
}
