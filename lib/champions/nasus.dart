import 'package:lol_duel/lolsim.dart';
import 'package:lol_duel/buffs.dart';
import 'package:lol_duel/stat_constants.dart';
import 'package:lol_duel/champions.dart';

class Nasus extends ChampionEffects {
  Mob nasus;
  Nasus(this.nasus);

  void onChampionCreate() {
    nasus.addBuff(new SoulEater(nasus));
  }
}

class SoulEater extends PermanentBuff {
  SoulEater(Mob target) : super(name: "Soul Eater", target: target);

  double bonusLifestealForLevel(int level) {
    // http://leagueoflegends.wikia.com/wiki/Nasus
    if (level < 7) return 0.10;
    if (level < 13) return 0.15;
    return 0.20;
  }

  Map<String, num> get stats => {
        PercentLifeStealMod: bonusLifestealForLevel(target.level),
      };
}