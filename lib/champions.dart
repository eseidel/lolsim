import 'lolsim.dart';

import 'champions/darius.dart';
import 'champions/olaf.dart';

class ChampionEffects {
  void onChampionCreate() {}
  void onActionHit(Mob target) {}
}

typedef ChampionEffects ChampionEffectsConstructor(Mob champion);
Map<String, ChampionEffectsConstructor> championEffectsConstructors = {
  'Darius': (Mob champ) => new Darius(champ),
  'Olaf': (Mob champ) => new Olaf(champ),
};
