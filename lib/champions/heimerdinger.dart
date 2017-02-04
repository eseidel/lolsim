import 'package:lol_duel/lolsim.dart';
import 'package:lol_duel/buffs.dart';
import 'package:lol_duel/stat_constants.dart';
import 'package:lol_duel/champions.dart';

class Heimerdinger extends ChampionEffects {
  Mob heimerdinger;
  Heimerdinger(this.heimerdinger);

  // FIXME: This should (also) be aplied to nearby champions.
  @override
  void onChampionCreate() {
    heimerdinger
        .addBuff(new TechmaturgicalRepairBots(heimerdinger, heimerdinger));
  }
}

class TechmaturgicalRepairBots extends PermanentBuff {
  Mob source;
  TechmaturgicalRepairBots(this.source, Mob target)
      : super(name: 'Techmaturgical Repair Bots', target: target);

  static double bonusHpRegenForLevel(int level) =>
      10.0 + 5 * ((level - 1) ~/ 4);

  @override
  Map<String, num> get stats => {
        FlatHPRegenMod: bonusHpRegenForLevel(source.level),
      };
}
