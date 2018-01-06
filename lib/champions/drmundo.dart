import 'package:lol_duel/mob.dart';
import 'package:lol_duel/buffs.dart';
import 'package:lol_duel/dragon/stat_constants.dart';
import 'package:lol_duel/effects.dart';

class DrMundo extends ChampionEffects {
  final Mob mundo;

  DrMundo(this.mundo);

  @override
  String get lastUpdate => VERSION_7_2_1;

  @override
  void onCreate() {
    mundo.addBuff(new AdrenalineRush(mundo));
  }
}

class AdrenalineRush extends PermanentBuff {
  AdrenalineRush(Mob target) : super("Adrenaline Rush", target);

  @override
  Map<String, num> get stats => {
        FlatHPRegenMod: 0.003 * target.maxHp * 5.0,
      };

  @override
  String get lastUpdate => VERSION_7_2_1;
}
