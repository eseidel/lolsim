import 'lolsim.dart';

const String VERSION_7_2_1 = '7.2.1';
const String VERSION_7_8_1 = '7.8.1';
const String VERSION_7_9_1 = '7.9.1';
const String VERSION_7_10_1 = '7.10.1';

// Champion, Buff, Item, Spell (Ability)
// FIXME: Champion doesn't have to inherit from this.
abstract class EffectsBase {
  String get lastUpdate;

  void onActionHit(Hit hit) {}
  void onHit(Hit target) {}
  // Unclear the right name, should be called after dmg applied:
  void onDamageRecieved() {}

  void damageDealtModifier(Hit hit, DamageDealtDelta delta) {}
  Map<String, num> get stats => null;
}

abstract class ChampionEffects extends EffectsBase {
  void onChampionCreate() {}
}

abstract class ItemEffects extends EffectsBase {
  void damageRecievedModifier(Hit hit, DamageRecievedDelta delta) {}
}
