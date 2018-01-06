import 'package:lol_duel/creator.dart';
import 'package:lol_duel/lolsim.dart';
import 'package:test/test.dart';
import '../utils.dart';

dynamic main() async {
  Creator data = await Creator.loadLatest();
  group("King's Tribute", () {
    test("basic", () {
      Mob trundle = data.champs.championById('Trundle');
      Mob victim = createTestMob(hp: 100.0);
      applyHit(target: trundle, source: victim, trueDamage: 100.0);
      expect(trundle.hpLost, 100.0);
      applyHit(target: victim, source: trundle, trueDamage: 100.0);
      expect(victim.alive, false);
      expect(trundle.hpLost, 98.0);
    });
  });
}
