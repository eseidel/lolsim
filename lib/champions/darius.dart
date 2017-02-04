import 'package:lol_duel/buffs.dart';
import 'package:lol_duel/champions.dart';
import 'package:lol_duel/lolsim.dart';
import 'package:lol_duel/stat_constants.dart';
import 'package:meta/meta.dart';

class NoxianMight extends TimedBuff {
  NoxianMight(Mob target)
      : super(name: "Noxian Might", target: target, duration: 5.0);

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
  Mob source;
  Hemorrhage({@required this.source, @required Mob target, int initialStacks})
      : super(
          name: 'Hemorrhage',
          target: target,
          duration: 5.0,
          secondsBetweenTicks: 1.25,
          initialStacks: initialStacks,
          maxStacks: 5,
        );

  @override
  Hit createHitForStacks(int stackCount) {
    // FIXME: This should include bonus Ad, including buffs, not total.
    double totalDmgPerStack = 9.0 + source.level;
    double dmgPerStackPerTick = totalDmgPerStack / initialTicks;
    // Choosing to do all the dmg at once for all stacks.
    return new Hit(
      source: source,
      target: target,
      label: name,
      physicalDamage: dmgPerStackPerTick * stackCount,
    );
  }
}

// On-hit DOT 10-27 + 30ad, 5s, can stack 5 times.
// On 5th stack, Darius gets Noxian might.
// With noxian might, 40-200 AD. applies full stacks.
// ticks every 1.25s
class Darius extends ChampionEffects {
  Mob darius;
  Darius(this.darius);

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
    if (target.type == MobType.structure) return;
    bool hasNoxianMight = darius.buffs.any((buff) => buff is NoxianMight);
    int stacksToApply = hasNoxianMight ? 5 : 1;
    Hemorrhage bleed = target.buffs
        .firstWhere((buff) => buff is Hemorrhage, orElse: () => null);
    if (bleed == null) {
      bleed = new Hemorrhage(
        source: darius,
        target: target,
        initialStacks: stacksToApply,
      );
      target.addBuff(bleed);
    } else {
      bleed.addStacks(stacksToApply);
    }
    if (bleed.stacks == 5) gainNoxianMight();
  }

  @override
  void onActionHit(Hit hit) => applyHemorrhageStack(hit.target);
}
