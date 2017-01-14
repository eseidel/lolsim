import "package:lol_duel/dragon.dart";
import 'package:lol_duel/lolsim.dart';
import "package:test/test.dart";
import 'package:lol_duel/champions/nasus.dart';

main() async {
  DragonData data = await DragonData.loadLatest();
  group("Soul Eater", () {
    test("basic", () {
      Mob nasus = data.champs.championById('Nasus');
      expect(nasus.buffs.any((buff) => buff is SoulEater), true);
      expect(nasus.stats.lifesteal, 0.10);
    });
  });
}
