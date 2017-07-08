import 'package:lol_duel/lolsim.dart';
import 'package:lol_duel/buffs.dart';
import 'package:lol_duel/dragon/stat_constants.dart';
import 'package:lol_duel/effects.dart';

class Nasus extends ChampionEffects {
  final Mob nasus;

  Nasus(this.nasus);

  @override
  String get lastUpdate => VERSION_7_2_1;

  @override
  void onCreate() {
    nasus.addBuff(new SoulEater(nasus));
  }
}

class SoulEater extends PermanentBuff {
  SoulEater(Mob target) : super(name: "Soul Eater", target: target);

  @override
  String get lastUpdate => VERSION_7_2_1;

  double bonusLifestealForLevel(int level) {
    // http://leagueoflegends.wikia.com/wiki/Nasus
    if (level < 7) return 0.10;
    if (level < 13) return 0.15;
    return 0.20;
  }

  @override
  Map<String, num> get stats => {
        PercentLifeStealMod: bonusLifestealForLevel(target.level),
      };
}
