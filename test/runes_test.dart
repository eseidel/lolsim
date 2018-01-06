import 'package:lol_duel/lolsim.dart';
import 'package:test/test.dart';
import 'package:lol_duel/creator.dart';
import 'package:lol_duel/rune_pages.dart';

import 'utils.dart';

dynamic main() async {
  Creator creator = await Creator.loadLatest();
  RuneDescriptionPage fromHash(String hash) =>
      creator.runes.library.pageFromChampionGGHash(hash);
  RuneDescriptionPage resolveExample =
      fromHash("8400-8437-8242-8430-8451-8200-8224-8237");
  RuneDescriptionPage precisionExample =
      fromHash("8000-8021-9111-9103-8014-8200-8236-8234");

  group("Traits", () {
    test("Resolve", () {
      Mob mob = createTestMob();
      expect(mob.stats.percentAttackSpeedMod, 0.0);
      double baseHp = mob.stats.hp;
      mob.runePage = new RunePage(mob, resolveExample);
      // Make sure I did the attack-delay math correctly:
      expect(mob.stats.hp - baseHp, 130.0);
    });
    test("Precision", () {
      Mob mob = createTestMob();
      expect(mob.stats.percentAttackSpeedMod, 0.0);
      mob.runePage = new RunePage(mob, precisionExample);
      // Make sure I did the attack-delay math correctly:
      expect(mob.stats.percentAttackSpeedMod, 0.18);
    });
  });
}
