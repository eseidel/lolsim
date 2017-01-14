import "package:lol_duel/dragon.dart";
import 'package:lol_duel/lolsim.dart';
import "package:test/test.dart";

main() async {
  DragonData data = await DragonData.loadLatest();
  group("Berserker Rage", () {
    test("basic", () {
      // Uses integer health values.
      // Should test that it ignores shields (once those exist).
      Mob olaf = data.champs.championById('Olaf');
      double initialAttackSpeed = olaf.stats.attackSpeed;
      olaf.hpLost += olaf.currentHp / 2;
      olaf.updateStats();
      expect(initialAttackSpeed, lessThan(olaf.stats.attackSpeed));
    });
  });
}
