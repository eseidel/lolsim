import "package:lol_duel/buffs.dart";
import 'package:lol_duel/lolsim.dart';
import "package:test/test.dart";

import 'utils.dart';

dynamic main() async {
  group("StackedBuff", () {
    test("tick", () {
      Mob mob = createTestMob(hp: 100.0);
      StackedBuff buff = new StackedBuff(
        target: mob,
        duration: 0.5,
        timeBetweenFalloffs: 0.25,
        maxStacks: 2,
      );
      expect(buff.stacks, 1);
      // Make sure ticks smaller than timeBetweenFalloffs work correctly.
      buff.tick(0.125);
      expect(buff.stacks, 1);
      buff.tick(0.125);
      expect(buff.stacks, 1);
      buff.refreshAndAddStack();
      expect(buff.stacks, 2);
      buff.tick(0.25);
      expect(buff.stacks, 2);
      buff.tick(0.25);
      expect(buff.stacks, 1);
      buff.tick(0.25);
      expect(buff.stacks, 0);
      expect(buff.expired, true);
    });
    test("timeBetweenFalloffs = 0", () {
      Mob mob = createTestMob(hp: 100.0);
      StackedBuff buff = new StackedBuff(
        target: mob,
        duration: 0.5,
        timeBetweenFalloffs: 0.0,
        maxStacks: 2,
      );
      expect(buff.stacks, 1);
      buff.refreshAndAddStack();
      expect(buff.stacks, 2);
      buff.tick(.5);
      expect(buff.stacks, 0);
      expect(buff.expired, true);
    });
  });
}
