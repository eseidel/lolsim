import 'champions/all.dart';
import 'lolsim.dart';

class ChampionEffects {
  void onChampionCreate() {}
  void onActionHit(Hit hit) {}
  void onHit(Hit target) {}
  // Unclear the right name, should be called after dmg applied:
  void onDamageRecieved() {}
}

typedef ChampionEffects ChampionEffectsConstructor(Mob champion);
Map<String, ChampionEffectsConstructor> championEffectsConstructors = {
  'Darius': (Mob champ) => new Darius(champ),
  'Jax': (Mob champ) => new Jax(champ),
  'Nasus': (Mob champ) => new Nasus(champ),
  'Olaf': (Mob champ) => new Olaf(champ),
  'Tryndamere': (Mob champ) => new Tryndamere(champ),
  'Volibear': (Mob champ) => new Volibear(champ),
};
