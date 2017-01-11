import "package:test/test.dart";
import "package:lol_duel/dragon.dart";
import 'test_mob.dart';

main() async {
  DragonData data = await DragonData.loadLatest();

  group("Darius", () {
    test("Hemorrhage", () {
      // AA applies bleed.
      // Bleeds tick every 1.25 seconds?
      // Bleeds stack.
      // Stacks are limited to 5.
      // Darius's AD increases at 5 stacks.
      // Bleeds update on next application and scale with his AD.
      // Bleeds update on leveling?
      // Darius's AA's apply 5 stacks to new targets.
      // Stacks fall off one at a time.
    });
  });
}
