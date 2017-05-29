import 'package:lol_duel/buffs.dart';
import 'package:lol_duel/effects.dart';
import 'package:lol_duel/lolsim.dart';
import 'package:lol_duel/dragon/stat_constants.dart';

class XinZhao extends ChampionEffects {
  final Mob xin;
  // FIXME: lastTarget should clear when Challange expires.
  Mob lastTarget;

  XinZhao(this.xin);

  @override
  String get lastUpdate => VERSION_7_10_1;

  Challange validateLastTargetBuff(Hit hit) {
    if (lastTarget == null) return null;
    Challange lastTargetBuff = lastTarget.buffs
        .firstWhere((buff) => buff is Challange, orElse: () => null);
    if (lastTargetBuff == null) return null;
    if (lastTarget == hit.target) return lastTargetBuff;
    lastTarget.removeBuff(lastTargetBuff);
    return null;
  }

  // Unclear what happens if the target blocks?
  @override
  void onHit(Hit hit) {
    // Does this affect structures?
    if (hit.target.isStructure) return;

    Challange lastTargetBuff = validateLastTargetBuff(hit);
    lastTarget = hit.target;

    if (lastTargetBuff == null) {
      lastTarget.addBuff(new Challange(lastTarget));
    } else {
      lastTargetBuff.refresh();
    }
  }
}

class Challange extends TimedBuff {
  Challange(Mob target)
      : super(
          name: 'Challange',
          target: target,
          duration: 4.0,
        );

  @override
  String get lastUpdate => VERSION_7_2_1;

  @override
  Map<String, num> get stats => {
        PercentArmorMod: -15,
      };
}
