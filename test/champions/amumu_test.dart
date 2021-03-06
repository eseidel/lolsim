import 'package:lol_duel/buffs.dart';
import 'package:lol_duel/champions/amumu.dart';
import 'package:lol_duel/creator.dart';
import 'package:lol_duel/lolsim.dart';
import 'package:test/test.dart';

import '../utils.dart';

dynamic main() async {
  Creator data = await Creator.loadLatest();

  group('Cursed Touch', () {
    test('basic', () {
      Mob amumu = data.champs.championById('Amumu');
      double amumuAd = amumu.stats.attackDamage;
      Mob mob = createTestMob(hp: 1000.0, baseSpellBlock: 100.0);
      World world = new World();
      // AA applies curse.
      new AutoAttack(amumu, mob).apply(world);
      expect(mob.buffs.any((buff) => buff is CursedTouch), isTrue);
      expect(mob.hpLost, amumuAd);
      applyHit(target: mob, source: amumu, magicDamage: 100.0);
      expect(mob.hpLost, amumuAd + 60.0);
      mob.tick(3.0);
      expect(mob.buffs.any((buff) => buff is CursedTouch), isFalse);
    });
  });
  group('Dispair', () {
    test('basic', () {
      Mob amumu = data.champs.championById('Amumu');
      amumu.spells.addSkillPointTo(SpellKey.w);
      amumu.state = MobState.stopped;
      Mob mob = createTestMob(hp: 1000.0);
      World world = new World(blues: [amumu], reds: [mob]);
      AmumuW spell = amumu.spells.w.effects;
      spell.castOnSelf(); // toggle on.
      spell.cooldown.expire(); // for testing.
      expect(spell.toggledOn, isTrue);
      world.tickFor(0.5);
      expect(mob.buffs.any((buff) => buff is CursedTouch), isTrue);
      expect(mob.hpLost, 11.0); // 5 + 0.005 * 1000 + 10% true.
      spell.castOnSelf(); // toggle off.
      spell.cooldown.expire(); // for testing.
      world.tickFor(0.5);
      expect(mob.hpLost, 22.0);
      world.tickFor(3.0);
      expect(mob.buffs.any((buff) => buff is CursedTouch), isFalse);
      spell.castOnSelf(); // toggle on.
      spell.cooldown.expire(); // for testing.
      world.tickFor(10.0);
      expect(spell.toggledOn, isTrue); // Auto-renews
      world.tickFor(90.0);
      expect(spell.toggledOn, isFalse); // Eventually runs out of mana.
    });
  });
  group('Tantrum', () {
    test('basic', () {
      Mob amumu = data.champs.championById('Amumu');
      amumu.spells.addSkillPointTo(SpellKey.e);
      amumu.state = MobState.stopped;
      Mob mob = createTestMob(hp: 1000.0);
      World world = new World(blues: [amumu], reds: [mob]);
      world.makeCurrentForScope(() {
        (amumu.spells.e.effects as SelfTargetedSpell).castOnSelf();
      });
      expect(mob.hpLost, 75.0);
    });
    test('flat damage reduction', () {
      Mob mob = createTestMob();
      Mob amumu = data.champs.championById('Amumu');
      amumu.spells.addSkillPointTo(SpellKey.e);
      applyHit(source: mob, target: amumu, physicalDamage: 20.0);
      double damageAfterArmor =
          Mob.resistanceMultiplier(amumu.stats.armor) * 20.0;
      expect(amumu.hpLost, damageAfterArmor - 2.0);
    });
  });
}
