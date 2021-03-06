import 'package:lol_duel/effects.dart';
import 'package:lol_duel/mob.dart';

class Lulu extends ChampionEffects {
  final Mob lulu;

  Lulu(this.lulu);

  @override
  String get lastUpdate => VERSION_7_2_1;

  double get damagePerPixShot =>
      3 + (2 * lulu.level) + 0.05 * lulu.stats.abilityPower;

  // FIXME: Pix should be implemented as a buff or separate mob (or both).
  // FIXME: Also Pix's attacks are delayed skillshots/missles with a travel time.
  // Maybe an on-attack trigger of an independent AA from an untargetable mob?
  @override
  void onAutoAttackHit(Hit hit) {
    hit.addOnHitDamage(new Damage(
      label: 'Pix',
      magicDamage: damagePerPixShot * 3,
    ));
  }
}
