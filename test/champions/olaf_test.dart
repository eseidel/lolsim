import 'package:lol_duel/creator.dart';
import 'package:lol_duel/lolsim.dart';
import 'package:test/test.dart';

dynamic main() async {
  Creator data = await Creator.loadLatest();
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
