import 'lolsim.dart';

const String VERSION_7_2_1 = '7.2.1';
const String VERSION_7_8_1 = '7.8.1';
const String VERSION_7_9_1 = '7.9.1';
const String VERSION_7_10_1 = '7.10.1';
const String VERSION_7_11_1 = '7.11.1';

// Champion, Buff, Item, Spell (Ability)
abstract class EffectsBase {
  String get lastUpdate;

  // FIXME: Most of these should move onto BuffEffects.
  void onSpellHit(Hit hit) {}
  void onAutoAttackHit(Hit hit) {}

  void onBeingHit(Hit hit) {}

  // Unclear the right name, called before damage adjustments.
  void onBeforeDamageRecieved(Hit hit) {}
  // Unclear the right name, called after dmg applied:
  void onDamageRecieved() {}

  void onDeath(Mob killer) {}

  Map<String, num> get stats => null;
}

abstract class MasteryEffects extends ChampionEffects {
  final int rank;
  final Mob champ;
  MasteryEffects(this.champ, this.rank);

  void damageRecievedModifier(Hit hit, DamageRecievedDelta delta) {}
  void damageDealtModifier(Hit hit, DamageDealtDelta delta) {}
}

abstract class ChampionEffects extends EffectsBase {
  void onChampionCreate() {}
}

abstract class BuffEffects extends EffectsBase {
  // Many of EffectsBase should move here.
  void damageRecievedModifier(Hit hit, DamageRecievedDelta delta) {}
  void damageDealtModifier(Hit hit, DamageDealtDelta delta) {}
}

abstract class ItemEffects extends BuffEffects {}

abstract class SpellEffects extends BuffEffects {}
