import 'package:lol_duel/lolsim.dart';
import 'package:lol_duel/buffs.dart';
import 'package:lol_duel/stat_constants.dart';
import 'package:lol_duel/champions.dart';

class Olaf extends ChampionEffects {
  Mob olaf;
  Olaf(this.olaf);

  void onChampionCreate() {
    olaf.addBuff(new BerserkerRage(olaf));
  }
}

class BerserkerRage extends PermenantBuff {
  BerserkerRage(Mob target) : super(name: "Berserker Rage", target: target);

  Map<String, num> get stats => {
        PercentAttackSpeedMod: 1.0 - target.healthPercent.floor(),
      };
}