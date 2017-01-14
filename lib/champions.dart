import 'lolsim.dart';

import 'champions/all.dart';

class ChampionEffects {
  void onChampionCreate() {}
  void onActionHit(Hit hit) {}
  void onHit(Hit target) {}
}

typedef ChampionEffects ChampionEffectsConstructor(Mob champion);
Map<String, ChampionEffectsConstructor> championEffectsConstructors = {
  'Darius': (Mob champ) => new Darius(champ),
  'Olaf': (Mob champ) => new Olaf(champ),
  'Jax': (Mob champ) => new Jax(champ),
};
