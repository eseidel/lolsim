import "package:lol_duel/dragon/stats.dart";
import 'package:lol_duel/lolsim.dart';
import "package:test/test.dart";

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
      hpRegen: 100.0,
      hpRegenPerLevel: 5.0,
      mp: 0.0,
      mpPerLevel: 0.0,
      spellBlock: 100.0,
      spellBlockPerLevel: 5.0,
    );
    Stats one = base.statsForLevel(1);
    Stats five = base.statsForLevel(5);
    Stats eighteen = base.statsForLevel(18);
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
    expect(one.spellBlock, 100.0);
    expect(five.spellBlock, 115.45);
    expect(eighteen.spellBlock, 185.0);
    expect(one.bonusAttackSpeed, 0.0);
    expect(five.bonusAttackSpeed, closeTo(15.45, 0.001));
    expect(eighteen.bonusAttackSpeed, 85.0);
  });
}
