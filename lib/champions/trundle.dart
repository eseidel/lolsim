import 'package:lol_duel/buffs.dart';
import 'package:lol_duel/effects.dart';
import 'package:lol_duel/mob.dart';

class Trundle extends ChampionEffects {
  final Mob trundle;

  Trundle(this.trundle);

  @override
  String get lastUpdate => VERSION_7_24_1;

  @override
  void onCreate() => trundle.addBuff(new KingsTribute(trundle));
}

class KingsTribute extends PermanentBuff {
  KingsTribute(Mob target) : super("King's Tribute", target);

  @override
  String get lastUpdate => VERSION_7_24_1;

  double _percentHealPerLevel(int level) {
    if (level < 5) return 0.02;
    if (level < 9) return 0.03;
    if (level < 12) return 0.04;
    if (level < 15) return 0.05;
    return 0.06;
  }

  // FIXME: This should be any death, not just something Trundle kills.
  @override
  void onKill(Mob victim) {
    // Unclear how this interacts with level-ups.
    target.healFor(_percentHealPerLevel(target.level) * victim.stats.hp, name);
  }
}
