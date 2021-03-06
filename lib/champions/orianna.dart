import 'package:lol_duel/buffs.dart';
import 'package:lol_duel/effects.dart';
import 'package:lol_duel/mob.dart';

class Orianna extends ChampionEffects {
  final Mob orianna;
  // FIXME: lastTarget should clear when ClockworkWinding expires.
  Mob lastTarget;

  Orianna(this.orianna);

  @override
  String get lastUpdate => VERSION_7_2_1;

  ClockworkWinding validateLastTargetBuff(Hit hit) {
    if (lastTarget == null) return null;
    ClockworkWinding lastTargetBuff = lastTarget.buffs
        .firstWhere((buff) => buff is ClockworkWinding, orElse: () => null);
    if (lastTargetBuff == null) return null;
    if (lastTarget == hit.target) return lastTargetBuff;
    lastTarget.removeBuff(lastTargetBuff);
    return null;
  }

  void addBuffOrStackAndRefresh(Mob target) {
    ClockworkWinding buff = target.buffs
        .firstWhere((buff) => buff is ClockworkWinding, orElse: () => null);
    if (buff == null) {
      target.addBuff(new ClockworkWinding(target));
    } else {
      buff.refreshAndAddStack();
    }
  }

  // FIXME: This is implemented as a self-buff in game.
  // Unclear what happens to the existing stacks if target blocks?
  @override
  void onAutoAttackHit(Hit hit) {
    if (hit.target.isStructure) return;

    double windupDamage = 10.0 + (((orianna.level - 1) / 3) * 5.0);
    windupDamage += .15 * orianna.stats.abilityPower;
    ClockworkWinding lastTargetBuff = validateLastTargetBuff(hit);
    if (lastTargetBuff != null)
      windupDamage *= 1.0 + (.2 * lastTargetBuff.stacks);

    addBuffOrStackAndRefresh(hit.target);
    lastTarget = hit.target;

    hit.addOnHitDamage(new Damage(
      label: 'Clockwork Windup',
      magicDamage: windupDamage,
    ));
  }
}

class ClockworkWinding extends StackedBuff {
  ClockworkWinding(Mob target)
      : super(
          target: target,
          // According to OrianaMains discord both falloff at 4s.
          duration: 4.0,
          maxStacks: 2,
          timeBetweenFalloffs: 0.0,
          name: 'Clockwork Winding',
        );

  @override
  String get lastUpdate => VERSION_7_2_1;
}
