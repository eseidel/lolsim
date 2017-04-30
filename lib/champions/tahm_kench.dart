import 'package:lol_duel/buffs.dart';
import 'package:lol_duel/champions.dart';
import 'package:lol_duel/lolsim.dart';
import 'package:meta/meta.dart';

class TahmKench extends ChampionEffects {
  Mob tahm;
  TahmKench(this.tahm);

  @override
  String get lastUpdate => VERSION_7_2_1;

  @override
  void onActionHit(Hit hit) {
    if (hit.target.type == MobType.structure) return;
    AnAcquiredTaste buff = hit.target.buffs
        .firstWhere((buff) => buff is AnAcquiredTaste, orElse: () => null);

    if (buff == null) {
      hit.target.addBuff(new AnAcquiredTaste(
        tahm: tahm,
        target: hit.target,
      ));
    } else {
      // Unclear if An Acquired Taste is a single-tick DOT, or if it applies
      // on-hit magic damage.  Assuming on-hit damage for now.
      // Damage is based on existing stacks, not stacks applied this time.
      hit.addOnHitDamage(buff.createOnHitDamage());
      buff.refreshAndAddStack();
    }
  }
}

class AnAcquiredTaste extends StackedBuff {
  final Mob tahm;

  AnAcquiredTaste({@required this.tahm, @required Mob target})
      : super(
          target: target,
          duration: 5.0,
          maxStacks: 3,
          timeBetweenFalloffs: .5, // According to lolwiki.
          name: 'An Acquired Taste',
        );

  static double percentMaxHealthDamagePerStack(int level) {
    if (level < 6) return 0.0100;
    if (level < 11) return 0.0125;
    return 0.0150;
  }

  Damage createOnHitDamage() {
    double dmgPerStack =
        percentMaxHealthDamagePerStack(tahm.level) * tahm.stats.hp;
    return new Damage(
      label: name,
      magicDamage: dmgPerStack * stacks,
    );
  }
}
