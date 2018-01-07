import 'package:lol_duel/mob.dart';
import 'package:lol_duel/buffs.dart';
import 'package:lol_duel/effects.dart';

class Nunu extends ChampionEffects {
  final Mob nunu;
  // Visionary could be a separate buff if needed.
  int visionaryStacks = 5;

  Nunu(this.nunu);

  @override
  String get lastUpdate => VERSION_7_24_1;

  bool get consumeVisionaryStacks {
    if (visionaryStacks < 5) return false;
    visionaryStacks = 0;
    return true;
  }

  @override
  void onAutoAttackHit(Hit hit) => visionaryStacks += 1;
}

class NunuQ extends SingleTargetSpell {
  int rank;
  NunuQ(Mob champ, this.rank) : super(champ, 'Consume');

  @override
  String get lastUpdate => VERSION_7_24_1;

  @override
  bool canBeCastOn(Mob target) => target.isMonster && !isOnCooldown;

  @override
  double get cooldownDuration => 13.0 - rank;

  bool checkAndResetEmpoweredSpell() {
    Nunu passive = champ.championEffects;
    return passive.consumeVisionaryStacks;
  }

  @override
  void castOn(Mob monster) {
    if (isOnCooldown) return;
    bool empowered = checkAndResetEmpoweredSpell();
    if (!empowered && !champ.spendManaIfPossible(60)) return;
    startCooldown(champ);
    int effectiveRank = empowered ? rank + 1 : rank;
    double consumeDamage = 180.0 + 160.0 * effectiveRank;
    monster.applyHit(champ.createHitForTarget(
      label: name,
      trueDamage: consumeDamage,
      target: monster,
      targeting: Targeting.singleTargetSpell,
    ));
    double consumeHeal = 50 * effectiveRank + 0.7 * champ.stats.abilityPower;
    champ.healFor(consumeHeal, name);
    // FIXME: Well Fed Passive
  }
}
