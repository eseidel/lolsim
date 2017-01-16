import 'package:lol_duel/lolsim.dart';
import 'package:lol_duel/buffs.dart';
import 'package:lol_duel/stat_constants.dart';
import 'package:lol_duel/champions.dart';

class DrMundo extends ChampionEffects {
  Mob mundo;
  DrMundo(this.mundo);

  @override
  void onChampionCreate() {
    mundo.addBuff(new AdrenalineRush(mundo));
  }
}

class AdrenalineRush extends PermanentBuff {
  AdrenalineRush(Mob target) : super(name: "Adrenaline Rush", target: target);

  // FIXME: This only reads from base hp and does not include other items!
  @override
  Map<String, num> get stats => {
        FlatHPRegenMod: 0.003 * target.stats.hp,
      };
}