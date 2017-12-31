import 'package:lol_duel/buffs.dart';
import 'package:lol_duel/effects.dart';
import 'package:lol_duel/mob.dart';
import 'package:lol_duel/dragon/stat_constants.dart';

class Diana extends ChampionEffects {
  final Mob diana;

  Diana(this.diana);

  @override
  String get lastUpdate => VERSION_7_2_1;

  static double onHitDamageForLevel(int level) {
    // Values from lolwiki.
    return const [
      20,
      25,
      30,
      35,
      40,
      50,
      60,
      70,
      80,
      90,
      105,
      120,
      135,
      155,
      175,
      200,
      225,
      250
    ][level - 1]
        .toDouble();
  }

  @override
  void onAutoAttackHit(Hit hit) {
    MoonsilverBladeOnHit buff = diana.buffs
        .firstWhere((buff) => buff is MoonsilverBladeOnHit, orElse: () => null);
    if (buff == null) {
      diana.addBuff(new MoonsilverBladeOnHit(diana));
      return;
    }
    if (buff.stacks < 2) {
      buff.refreshAndAddStack();
      return;
    }

    diana.removeBuff(buff);
    hit.addOnHitDamage(new Damage(
      label: buff.name,
      magicDamage:
          onHitDamageForLevel(diana.level) + .8 * diana.stats.abilityPower,
    ));
  }

  @override
  void onCreate() {
    diana.addBuff(new MoonsilverBladeAttackSpeed(diana));
  }
}

class MoonsilverBladeAttackSpeed extends PermanentBuff {
  MoonsilverBladeAttackSpeed(Mob target) : super("Moonsilver Blade", target);

  @override
  String get lastUpdate => VERSION_7_2_1;

  @override
  Map<String, num> get stats => {
        PercentAttackSpeedMod: 0.20,
      };
}

class MoonsilverBladeOnHit extends StackedBuff {
  MoonsilverBladeOnHit(Mob diana)
      : super(
          target: diana,
          duration: 3.5,
          maxStacks: 3,
          timeBetweenFalloffs: 0.0, // Unclear what this should be?
          name: 'Moonsilver Blade',
        );

  @override
  String get lastUpdate => VERSION_7_2_1;
}
