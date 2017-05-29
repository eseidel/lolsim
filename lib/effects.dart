import 'lolsim.dart';

const String VERSION_7_2_1 = '7.2.1';
const String VERSION_7_8_1 = '7.8.1';
const String VERSION_7_9_1 = '7.9.1';
const String VERSION_7_10_1 = '7.10.1';

// Champion, Buff, Item, Spell (Ability)
abstract class EffectsBase {
  String get lastUpdate;

  // FIXME: Most of these should move onto BuffEffects.
  void onActionHit(Hit hit) {}
  void onHit(Hit target) {}
  // Unclear the right name, should be called after dmg applied:
  void onDamageRecieved() {}

  Map<String, num> get stats => null;
}

abstract class MasteryEffects extends ChampionEffects {
  final int rank;
  MasteryEffects(this.rank);

  void damageRecievedModifier(Hit hit, DamageRecievedDelta delta) {}
  void damageDealtModifier(Hit hit, DamageDealtDelta delta) {}
}

abstract class ChampionEffects extends EffectsBase {
  void onChampionCreate() {}
}

abstract class BuffEffects extends EffectsBase {
  // Many of EffectsBase should move here.
  void damageDealtModifier(Hit hit, DamageDealtDelta delta) {}
}

abstract class ItemEffects extends BuffEffects {
  void damageRecievedModifier(Hit hit, DamageRecievedDelta delta) {}
}

abstract class SpellEffects extends BuffEffects {}
