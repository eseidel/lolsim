import 'package:lol_duel/buffs.dart';
import 'package:lol_duel/effects.dart';
import 'package:lol_duel/mob.dart';
import 'package:lol_duel/dragon/stat_constants.dart';
import 'package:meta/meta.dart';

class NoxianMight extends TimedBuff {
  NoxianMight(Mob target)
      : super(name: "Noxian Might", target: target, duration: 5.0);

  @override
  String get lastUpdate => VERSION_7_2_1;

  static int bonusAdForLevel(int level) {
    // http://leagueoflegends.wikia.com/wiki/Darius
    if (level < 3) return 30;
    if (level < 7) return 35;
    if (level < 14) return (level * 10) - 30;
    return (level - 8) * 20;
  }

  @override
  Map<String, num> get stats => {
        FlatPhysicalDamageMod: bonusAdForLevel(target.level),
      };
}

class Hemorrhage extends DOT {
  final Mob darius;

  Hemorrhage({@required this.darius, @required Mob target, int initialStacks})
      : super(
          name: 'Hemorrhage',
          target: target,
          duration: 5.0,
          secondsBetweenTicks: 1.25,
          initialStacks: initialStacks,
          maxStacks: 5,
        );

  @override
  String get lastUpdate => VERSION_7_2_1;

  @override
  Hit createHitForStacks(int stackCount) {
    // FIXME: This should include bonus Ad, including buffs, not total.
    double totalDmgPerStack =
        9.0 + darius.level + (0.3 * darius.stats.bonusAttackDamage);
    double dmgPerStackPerTick = totalDmgPerStack / initialTicks;
    // Choosing to do all the dmg at once for all stacks.
    return darius.createHitForTarget(
      target: target,
      label: name,
      physicalDamage: dmgPerStackPerTick * stackCount,
      targeting: Targeting.dot,
    );
  }
}

// On-hit DOT 10-27 + 30ad, 5s, can stack 5 times.
// On 5th stack, Darius gets Noxian might.
// With noxian might, 40-200 AD. applies full stacks.
// ticks every 1.25s
class Darius extends ChampionEffects {
  final Mob darius;

  Darius(this.darius);

  @override
  String get lastUpdate => VERSION_7_2_1;

  void gainNoxianMight() {
    NoxianMight might = darius.buffs
        .firstWhere((buff) => buff is NoxianMight, orElse: () => null);
    if (might != null)
      might.refresh();
    else {
      darius.addBuff(new NoxianMight(darius));
    }
  }

  // FIXME: I don't think this should apply to structures, right?
  void applyHemorrhageStack(Mob target) {
    if (target.isStructure) return;
    bool hasNoxianMight = darius.buffs.any((buff) => buff is NoxianMight);
    int stacksToApply = hasNoxianMight ? 5 : 1;
    Hemorrhage bleed = target.buffs
        .firstWhere((buff) => buff is Hemorrhage, orElse: () => null);
    if (bleed == null) {
      bleed = new Hemorrhage(
        darius: darius,
        target: target,
        initialStacks: stacksToApply,
      );
      target.addBuff(bleed);
    } else {
      bleed.addStacks(stacksToApply);
    }
    if (bleed.stacks == 5 && target.isChampion) gainNoxianMight();
  }

  @override
  void onSpellHit(Hit hit) => applyHemorrhageStack(hit.target);

  @override
  void onAutoAttackHit(Hit hit) => applyHemorrhageStack(hit.target);
}
