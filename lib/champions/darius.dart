import 'package:lol_duel/lolsim.dart';
import 'package:lol_duel/buffs.dart';
import 'package:lol_duel/stat_constants.dart';
import 'package:lol_duel/champions.dart';
import 'package:meta/meta.dart';

class NoxianMight extends TimedBuff {
  // Alternatively runtimeType.toString()?
  // In python I would just override a static to set this.
  // Unclear what the right pattern is in Dart.
  static String constName = 'NoxianMight';

  NoxianMight(Mob target)
      : super(name: constName, target: target, duration: 5.0);
  int bonusAdForLevel(int level) {
    // http://leagueoflegends.wikia.com/wiki/Darius
    if (level < 3) return 40;
    if (level < 7) return 45;
    if (level < 15) return (level * 10) - 20;
    return level * 10 + (level - 16) * 20;
  }

  @override
  Map<String, num> get stats => {
        FlatPhysicalDamageMod: bonusAdForLevel(target.level),
      };
}

class Hemorrhage extends DOT {
  static String constName = 'Hemorrhage';
  Mob source;
  Hemorrhage({@required this.source, @required Mob target, int initialStacks})
      : super(
          name: constName,
          target: target,
          duration: 5.0,
          secondsBetweenTicks: 1.25,
          initialStacks: initialStacks,
          maxStacks: 5,
        );

  Hit createHitForStacks(int stackCount) {
    double totalDmgPerStack =
        9 + source.level + (.3 * source.stats.attackDamage);
    double dmgPerStackPerTick = totalDmgPerStack / initialTicks;
    // Choosing to do all the dmg at once for all stacks.
    return new Hit(
      source: source,
      target: target,
      label: constName,
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

  void applyHemorrhageStack(Mob target) {
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
  void onActionHit(Mob target) => applyHemorrhageStack(target);
}
