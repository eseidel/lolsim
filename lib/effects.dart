import 'mob.dart';

const String VERSION_7_2_1 = '7.2.1';
const String VERSION_7_8_1 = '7.8.1';
const String VERSION_7_9_1 = '7.9.1';
const String VERSION_7_10_1 = '7.10.1';
const String VERSION_7_11_1 = '7.11.1';
const String VERSION_7_24_1 = '7.24.1';

// Champion, Buff, Item, Spell (Ability)
abstract class EffectsBase {
  String get lastUpdate;

  void onCreate() {}
  void onLevelUp() {}

  // FIXME: Most of these should move onto BuffEffects.
  void onSpellHit(Hit hit) {}
  void onAutoAttackHit(Hit hit) {}

  // This is only hit for auto attacks.
  void onBeingHit(Hit hit) {}

  // Unclear the right name, called before damage adjustments.
  void onBeforeDamageRecieved(Hit hit) {}
  // Unclear the right name, called after dmg applied:
  void onDamageRecieved() {}

  void onKill(Mob victim) {}
  void onDeath(Mob killer) {}

  String toStringAdditions() => "";

  Map<String, num> get stats => null;
}

abstract class MasteryEffects extends ChampionEffects {
  final int rank;
  final Mob champ;
  MasteryEffects(this.champ, this.rank);

  void damageRecievedModifier(Hit hit, DamageRecievedDelta delta) {}
  void damageDealtModifier(Hit hit, DamageDealtDelta delta) {}
}

abstract class RuneEffects extends ChampionEffects {
  final Mob champ;
  RuneEffects(this.champ);

  void damageRecievedModifier(Hit hit, DamageRecievedDelta delta) {}
  void damageDealtModifier(Hit hit, DamageDealtDelta delta) {}
}

abstract class ChampionEffects extends EffectsBase {}

abstract class BuffEffects extends EffectsBase {
  // Many of EffectsBase should move here.
  void damageRecievedModifier(Hit hit, DamageRecievedDelta delta) {}
  void damageDealtModifier(Hit hit, DamageDealtDelta delta) {}
}
