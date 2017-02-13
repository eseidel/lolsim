import 'package:lol_duel/champions/heimerdinger.dart';
import "package:test/test.dart";

dynamic main() async {
  group('Techmaturgical Repair Bots', () {
    test('hp5 scaling', () {
      List<int> levels = [1, 2, 5, 9, 13, 17, 18];
      List<double> expectedHp5Bonus = [
        10.0,
        10.0,
        15.0,
        20.0,
        25.0,
        30.0,
        30.0
      ];
      List<double> actualHp5Bonus =
          levels.map(TechmaturgicalRepairBots.bonusHpRegenForLevel).toList();
      expect(actualHp5Bonus, expectedHp5Bonus);
    });
  });
}
