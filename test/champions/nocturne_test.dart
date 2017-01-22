import 'package:lol_duel/creator.dart';
import 'package:lol_duel/champions/nocturne.dart';
import 'package:lol_duel/lolsim.dart';
import 'package:test/test.dart';
import '../test_mob.dart';

main() async {
  Creator data = await Creator.loadLatest();
  group('Umbra Blades', () {
    test('basic', () {
      Mob nocturne = data.champs.championById('Nocturne');
      Mob mob = createTestMob(hp: 1000.0);
      World world = new World();
      new AutoAttack(nocturne, mob).apply(world);
      expect(mob.hpLost, 1.2 * nocturne.stats.attackDamage);
      UmbraBladesCooldown cooldown =
          nocturne.buffs.firstWhere((buff) => buff is UmbraBladesCooldown);
      expect(cooldown.remaining, 10.0);
      new AutoAttack(nocturne, mob).apply(world);
      expect(mob.hpLost, 2.2 * nocturne.stats.attackDamage);
      expect(cooldown.remaining, 9.0);
    });
    test('structures', () {
      Mob nocturne = data.champs.championById('Nocturne');
      Mob mob = createTestMob(hp: 1000.0);
      Mob structure = createTestMob(hp: 1000.0, type: MobType.structure);

      World world = new World();
      new AutoAttack(nocturne, structure).apply(world);
      // Structures do not trigger splash.
      expect(structure.hpLost, nocturne.stats.attackDamage);

      // But attacking structures will reduce the cooldown of the passive.
      new AutoAttack(nocturne, mob).apply(world);
      UmbraBladesCooldown cooldown =
          nocturne.buffs.firstWhere((buff) => buff is UmbraBladesCooldown);
      expect(cooldown.remaining, 10.0);
      new AutoAttack(nocturne, structure).apply(world);
      expect(cooldown.remaining, 9.0);
    });
  });
}
