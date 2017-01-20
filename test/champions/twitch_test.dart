import 'package:lol_duel/champions/twitch.dart';
import "package:lol_duel/dragon.dart";
import 'package:lol_duel/lolsim.dart';
import "package:test/test.dart";

import '../test_mob.dart';

main() async {
  DragonData data = await DragonData.loadLatest();

  group("Deadly Venom", () {
    test("basic", () {
      Mob twitch = data.champs.championById('Twitch');
      double twitchAd = twitch.stats.attackDamage;
      Mob mob = createTestMob(hp: 1000.0);
      World world = new World();
      // AA applies bleed.
      new AutoAttack(twitch, mob).apply(world);
      DeadlyVenom buff = mob.buffs.firstWhere((buff) => buff is DeadlyVenom);
      // DOT has not yet ticked yet.
      expect(mob.hpLost, twitchAd);
      // Bleeds tick every 1 seconds?
      buff.tick(2.0);
      expect(mob.hpLost, greaterThan(twitchAd));
      expect(buff.stacks, 1);
      new AutoAttack(twitch, mob).apply(world);
      expect(buff.stacks, 2);
      // Stacks are limited to 6.
      new AutoAttack(twitch, mob).apply(world);
      expect(buff.stacks, 3);
      new AutoAttack(twitch, mob).apply(world);
      expect(buff.stacks, 4);
      new AutoAttack(twitch, mob).apply(world);
      expect(buff.stacks, 5);
      new AutoAttack(twitch, mob).apply(world);
      expect(buff.stacks, 6);
      new AutoAttack(twitch, mob).apply(world);
      expect(buff.stacks, 6);
    });
    test("structures", () {
      // The wiki doesn't say, but I don't believe he applies to structures?
      Mob twitch = data.champs.championById('Twitch');
      Mob structure = createTestMob(hp: 1000.0, type: MobType.structure);
      World world = new World();
      // AA does not apply bleed to structures?
      new AutoAttack(twitch, structure).apply(world);
      bool hasBleed = structure.buffs.any((buff) => buff is DeadlyVenom);
      expect(hasBleed, false);
    });
  });
}
