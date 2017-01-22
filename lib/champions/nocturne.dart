import 'package:lol_duel/buffs.dart';
import 'package:lol_duel/champions.dart';
import 'package:lol_duel/dragon.dart';
import 'package:lol_duel/lolsim.dart';

class Nocturne extends ChampionEffects {
  Mob nocturne;
  Nocturne(this.nocturne);

  // FIXME: This is implemented as a self-buff in game.
  @override
  void onHit(Hit hit) {
    // Unclear if this reduction portion is on-attack or on-hit?
    UmbraBladesCooldown cooldown = nocturne.buffs
        .firstWhere((buff) => buff is UmbraBladesCooldown, orElse: () => null);
    if (cooldown != null) {
      cooldown.tick(1.0); // Maybe we should a reduceCooldownBy method?
      return;
    }

    // Structure hits reduce cooldown but do not trigger splash.
    if (hit.target.type == MobType.structure) return;

    nocturne.addBuff(new UmbraBladesCooldown(nocturne));
    // lolwiki is phrased strangely, but since this does not interact
    // with critical strikes, I believe that it's just a 20% AD onHit.
    // FIXME: This also should cause splash around the target for 120% AD.
    hit.addOnHitDamage(new Damage(
      label: 'Umbra Blades',
      physicalDamage: 0.20 * nocturne.stats.attackDamage,
    ));
  }
}

class UmbraBladesCooldown extends TimedBuff {
  UmbraBladesCooldown(Mob nocturne)
      : super(
          target: nocturne,
          duration: 10.0,
          name: 'Umbra Blades',
        ) {}
}
