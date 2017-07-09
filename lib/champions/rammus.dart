import 'package:lol_duel/lolsim.dart';
import 'package:lol_duel/buffs.dart';
import 'package:lol_duel/dragon/stat_constants.dart';
import 'package:lol_duel/effects.dart';

class Rammus extends ChampionEffects {
  final Mob rammus;

  Rammus(this.rammus);

  @override
  String get lastUpdate => VERSION_7_2_1;

  @override
  void onCreate() {
    rammus.addBuff(new SpikedShell(rammus));
  }
}

// FIXME: This is now wrong in 7.10.1, but easy to fix.
class SpikedShell extends PermanentBuff {
  SpikedShell(Mob target) : super("Spiked Shell", target);

  @override
  String get lastUpdate => VERSION_7_2_1;

  @override
  Map<String, num> get stats => {
        FlatPhysicalDamageMod: target.stats.armor * 0.25,
      };
}
