import "package:lol_duel/creator.dart";
import 'package:lol_duel/lolsim.dart';
import "package:test/test.dart";
import 'package:lol_duel/champions/ekko.dart';
import '../test_mob.dart';

dynamic main() async {
  Creator data = await Creator.loadLatest();
  group('Z-Drive Resonance', () {
    test('basic', () {
      Mob ekko = data.champs.championById('Ekko');
      Mob mob = createTestMob(hp: 1000.0);
      World world = new World();
      new AutoAttack(ekko, mob).apply(world);
      expect(mob.hpLost, ekko.stats.attackDamage);
      ZDriveResonance buff =
          mob.buffs.firstWhere((buff) => buff is ZDriveResonance);
      expect(buff.stacks, 1);
      new AutoAttack(ekko, mob).apply(world);
      expect(buff.stacks, 2);
      expect(mob.hpLost, 2.0 * ekko.stats.attackDamage);
      new AutoAttack(ekko, mob).apply(world);
      expect(buff.stacks, 3);
      expect(mob.hpLost, 3.0 * ekko.stats.attackDamage + 30.0);
      expect(mob.buffs.any((buff) => buff is ZDriveResonance), false);
      expect(mob.buffs.any((buff) => buff is ZDriveResonanceDown), true);
      new AutoAttack(ekko, mob).apply(world);
      expect(mob.hpLost, 4.0 * ekko.stats.attackDamage + 30.0);
      expect(mob.buffs.any((buff) => buff is ZDriveResonance), false);
      expect(mob.buffs.any((buff) => buff is ZDriveResonanceDown), true);
      mob.tick(5.0);
      expect(mob.buffs.any((buff) => buff is ZDriveResonanceDown), false);
    });
    test('up to 4s between hits', () {
      Mob ekko = data.champs.championById('Ekko');
      Mob mob = createTestMob(hp: 1000.0);
      World world = new World();
      new AutoAttack(ekko, mob).apply(world);
      mob.tick(3.5);
      new AutoAttack(ekko, mob).apply(world);
      mob.tick(3.5);
      new AutoAttack(ekko, mob).apply(world);
      expect(mob.hpLost, 3.0 * ekko.stats.attackDamage + 30.0);
      expect(mob.buffs.any((buff) => buff is ZDriveResonanceDown), true);
    });
  });
}
