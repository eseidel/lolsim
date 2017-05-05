import 'champions/all.dart';
import 'lolsim.dart';

const String VERSION_7_2_1 = '7.2.1';
const String VERSION_7_8_1 = '7.8.1';
const String VERSION_7_9_1 = '7.9.1';

abstract class ChampionEffects {
  String get lastUpdate;
  void onChampionCreate() {}
  void onActionHit(Hit hit) {}
  void onHit(Hit target) {}
  // Unclear the right name, should be called after dmg applied:
  void onDamageRecieved() {}
}

typedef ChampionEffects ChampionEffectsConstructor(Mob champion);
Map<String, ChampionEffectsConstructor> championEffectsConstructors = {
  'Darius': (Mob champ) => new Darius(champ),
  'Diana': (Mob champ) => new Diana(champ),
  'DrMundo': (Mob champ) => new DrMundo(champ),
  'Ekko': (Mob champ) => new Ekko(champ),
  'Fiora': (Mob champ) => new Fiora(champ),
  'Heimerdinger': (Mob champ) => new Heimerdinger(champ),
  'Jax': (Mob champ) => new Jax(champ),
  'JarvanIV': (Mob champ) => new JarvanIV(champ),
  'Lulu': (Mob champ) => new Lulu(champ),
  'Nasus': (Mob champ) => new Nasus(champ),
  'Nocturne': (Mob champ) => new Nocturne(champ),
  'Olaf': (Mob champ) => new Olaf(champ),
  'Orianna': (Mob champ) => new Orianna(champ),
  'Rammus': (Mob champ) => new Rammus(champ),
  'Singed': (Mob champ) => new Singed(champ),
  'TahmKench': (Mob champ) => new TahmKench(champ),
  'Tryndamere': (Mob champ) => new Tryndamere(champ),
  'Twitch': (Mob champ) => new Twitch(champ),
  'Urgot': (Mob champ) => new Urgot(champ),
  'Volibear': (Mob champ) => new Volibear(champ),
  'Warwick': (Mob champ) => new Warwick(champ),
  'Zed': (Mob champ) => new Zed(champ),
};
