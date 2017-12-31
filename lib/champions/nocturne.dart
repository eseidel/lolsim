import 'package:lol_duel/buffs.dart';
import 'package:lol_duel/effects.dart';
import 'package:lol_duel/mob.dart';

class Nocturne extends ChampionEffects {
  final Mob nocturne;

  Nocturne(this.nocturne);

  @override
  String get lastUpdate => VERSION_7_2_1;

  double _baseHealPerEnemyHitForLevel(int level) {
    if (level < 7) return 10.0;
    if (level < 13) return 18.0;
    return 26.0;
  }

  double get healPerEnemyHit {
    return _baseHealPerEnemyHitForLevel(nocturne.level) +
        0.15 * nocturne.stats.abilityPower;
  }

  // FIXME: This is implemented as a self-buff in game.
  @override
  void onAutoAttackHit(Hit hit) {
    // Unclear if this reduction portion is on-attack or on-hit?
    UmbraBladesCooldown cooldown = nocturne.buffs
        .firstWhere((buff) => buff is UmbraBladesCooldown, orElse: () => null);
    if (cooldown != null) {
      cooldown.tick(1.0); // Maybe we should a reduceCooldownBy method?
      return;
    }

    // Structure hits reduce cooldown but do not trigger splash.
    if (hit.target.isStructure) return;

    nocturne.addBuff(new UmbraBladesCooldown(nocturne));
    // lolwiki is phrased strangely, but since this does not interact
    // with critical strikes, I believe that it's just a 20% AD onHit.
    // FIXME: This also should cause splash around the target for 120% AD.
    hit.addOnHitDamage(new Damage(
      label: 'Umbra Blades',
      physicalDamage: 0.20 * nocturne.stats.attackDamage,
    ));

    // FIXME: This should heal per target hit (when splashing)
    nocturne.healFor(healPerEnemyHit, 'Umbra Blades');
  }
}

class UmbraBladesCooldown extends TimedBuff {
  UmbraBladesCooldown(Mob nocturne)
      : super(
          target: nocturne,
          duration: 10.0,
          name: 'Umbra Blades',
        );

  @override
  String get lastUpdate => VERSION_7_2_1;
}
