import 'package:lol_duel/lolsim.dart';
import 'package:lol_duel/buffs.dart';
import 'package:lol_duel/stat_constants.dart';
import 'package:lol_duel/champions.dart';

class Rammus extends ChampionEffects {
  Mob rammus;
  Rammus(this.rammus);

  @override
  String get lastUpdate => VERSION_7_2_1;

  @override
  void onChampionCreate() {
    rammus.addBuff(new SpikedShell(rammus));
  }
}

class SpikedShell extends PermanentBuff {
  SpikedShell(Mob target) : super(name: "Spiked Shell", target: target);

  @override
  Map<String, num> get stats => {
        FlatPhysicalDamageMod: target.stats.armor * 0.25,
      };
}
