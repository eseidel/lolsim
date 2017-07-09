import 'package:lol_duel/dragon/stats.dart';
import 'package:lol_duel/lolsim.dart';
import 'package:test/test.dart';

import 'utils.dart';

dynamic main() async {
  test("statsForLevel curve", () {
    BaseStats base = new BaseStats(
      baseArmor: 100.0,
      armorPerLevel: 5.0,
      baseAttackDamage: 100.0,
      attackDamagePerLevel: 5.0,
      attackSpeedPerLevel: 5.0,
      attackDelay: 0.0,
      hp: 100.0,
      hpPerLevel: 5.0,
      baseHpRegen: 100.0,
      hpRegenPerLevel: 5.0,
      mpRegenPerLevel: 5.0,
      baseMpRegen: 100.0,
      mp: 0.0,
      mpPerLevel: 0.0,
      baseSpellBlock: 100.0,
      spellBlockPerLevel: 5.0,
    );
    Stats one = base.championCurvedStatsForLevel(1);
    Stats five = base.championCurvedStatsForLevel(5);
    Stats eighteen = base.championCurvedStatsForLevel(18);
    expect(one.armor, 100.0);
    expect(five.armor, 115.45);
    expect(eighteen.armor, 185.0);
    expect(one.attackDamage, 100.0);
    expect(five.attackDamage, 115.45);
    expect(eighteen.attackDamage, 185.0);
    expect(one.hp, 100.0);
    expect(five.hp, 115.45);
    expect(eighteen.hp, 185.0);
    expect(one.hpRegen, 100.0);
    expect(five.hpRegen, 115.45);
    expect(eighteen.hpRegen, 185.0);
    expect(one.mpRegen, 100.0);
    expect(five.mpRegen, 115.45);
    expect(eighteen.mpRegen, 185.0);
    expect(one.spellBlock, 100.0);
    expect(five.spellBlock, 115.45);
    expect(eighteen.spellBlock, 185.0);
    expect(one.percentAttackSpeedMod, 0.0);
    expect(five.percentAttackSpeedMod, closeTo(15.45, 0.001));
    expect(eighteen.percentAttackSpeedMod, 85.0);
  });
  test('attack speed scaling', () {
    // From http://leagueoflegends.wikia.com/wiki/Attack_speed#Example
    Mob twistedFate = createTestMob(
      attackDelay: -0.04,
      attackSpeedPerLevel: 3.22,
      type: MobType.champion,
    );
    twistedFate.jumpToLevel(18);
    expect(twistedFate.stats.baseAttackSpeed, closeTo(0.651, 0.001));
    expect(twistedFate.stats.percentAttackSpeedMod, closeTo(54.74, 0.01));
  });
}
