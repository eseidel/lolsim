import 'package:lol_duel/lolsim.dart';
import 'package:lol_duel/buffs.dart';
import 'package:lol_duel/stat_constants.dart';
import 'package:lol_duel/champions.dart';

class Rammus extends ChampionEffects {
  Mob rammus;
  Rammus(this.rammus);

  @override
  void onChampionCreate() {
    rammus.addBuff(new SpikedShell(rammus));
  }
}

class SpikedShell extends PermanentBuff {
  SpikedShell(Mob target) : super(name: "Spiked Shell", target: target);

  // FIXME: This doesn't work, since it reads from base stats, instead of total.
  @override
  Map<String, num> get stats => {
        FlatPhysicalDamageMod: target.stats.armor * 0.25,
      };
}
