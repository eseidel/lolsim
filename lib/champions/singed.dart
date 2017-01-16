import 'package:lol_duel/lolsim.dart';
import 'package:lol_duel/buffs.dart';
import 'package:lol_duel/stat_constants.dart';
import 'package:lol_duel/champions.dart';

class Singed extends ChampionEffects {
  Mob singed;
  Singed(this.singed);

  @override
  void onChampionCreate() {
    singed.addBuff(new EmpoweredBulwark(singed));
  }
}

class EmpoweredBulwark extends PermanentBuff {
  EmpoweredBulwark(Mob target)
      : super(name: "Empowered Bulwark", target: target);

  // FIXME: This doesn't work, since it reads from base stats, instead of total.
  @override
  Map<String, num> get stats => {
        FlatHPPoolMod: target.stats.mp * 0.25,
      };
}
