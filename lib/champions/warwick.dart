import 'package:lol_duel/champions.dart';
import 'package:lol_duel/lolsim.dart';

class Warwick extends ChampionEffects {
  Mob warwick;
  Warwick(this.warwick);

  @override
  String get lastUpdate => VERSION_7_8_1;

  static double bonusDamagePerLevel(int level) => 8.0 + 2.0 * level;

  // FIXME: This could be a buff instead.
  @override
  void onHit(Hit hit) {
    String name = 'Eternal Hunger';
    double bonusDamage = bonusDamagePerLevel(warwick.level);
    hit.addOnHitDamage(new Damage(
      label: name,
      magicDamage: bonusDamage,
    ));

    if (warwick.healthPercent < 0.25)
      warwick.healFor(3 * bonusDamage, name);
    else if (warwick.healthPercent < 0.50) warwick.healFor(bonusDamage, name);
  }
}
