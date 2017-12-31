import 'package:lol_duel/buffs.dart';
import 'package:lol_duel/dragon/stat_constants.dart';
import 'package:lol_duel/effects.dart';
import 'package:lol_duel/mob.dart';

class Olaf extends ChampionEffects {
  final Mob olaf;

  Olaf(this.olaf);

  @override
  String get lastUpdate => VERSION_7_2_1;

  @override
  void onCreate() {
    olaf.addBuff(new BerserkerRage(olaf));
  }
}

class BerserkerRage extends PermanentBuff {
  BerserkerRage(Mob target) : super("Berserker Rage", target);

  @override
  String get lastUpdate => VERSION_7_2_1;

  @override
  Map<String, num> get stats => {
        // FIXME: healthPercent could vary based on other stats.
        PercentAttackSpeedMod: 1.0 - target.healthPercent.floor(),
      };
}
