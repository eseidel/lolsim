import 'package:lol_duel/creator.dart';
import 'package:lol_duel/lolsim.dart';
import 'package:test/test.dart';
import 'package:lol_duel/buffs.dart';

import '../utils.dart';

dynamic main() async {
  Creator data = await Creator.loadLatest();

  void castOn(Mob mob, SpellKey key, Mob target) {
    var spell = mob.spells.spellForKey(key).effects as SingleTargetSpell;
    assert(spell.canBeCastOn(target));
    spell.castOn(target);
  }

  group("Consume", () {
    test("basic", () {
      Mob nunu = data.champs.championByName('Nunu');
      nunu.hpLost = 150.0;
      nunu.spells.addSkillPointTo(SpellKey.q);
      Mob monster = createTestMob(type: MobType.largeMonster, hp: 2000.0);
      castOn(nunu, SpellKey.q, monster);
      // Visionary values:
      expect(monster.hpLost, 500.0);
      expect(nunu.hpLost, 50.0);
      // If we waited and cast again, would be smaller numbers.
    });
  });
}
