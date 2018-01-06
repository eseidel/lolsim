import '../dragon/spell_parser.dart';
import '../effects.dart';
import '../mob.dart';
import 'amumu.dart';
import 'darius.dart';
import 'diana.dart';
import 'drmundo.dart';
import 'ekko.dart';
import 'fiora.dart';
import 'jarvaniv.dart';
import 'jax.dart';
import 'lulu.dart';
import 'masteryi.dart';
import 'nasus.dart';
import 'nocturne.dart';
import 'olaf.dart';
import 'orianna.dart';
import 'rammus.dart';
import 'singed.dart';
import 'tahm_kench.dart';
import 'tryndamere.dart';
import 'trundle.dart';
import 'twitch.dart';
import 'urgot.dart';
import 'volibear.dart';
import 'warwick.dart';
import 'xinzhao.dart';
import 'zed.dart';
import '../summoners.dart';

typedef ChampionEffects ChampionEffectsConstructor(Mob champion);
Map<String, ChampionEffectsConstructor> _championEffectsConstructors = {
  'Amumu': (Mob champ) => new Amumu(champ),
  'Darius': (Mob champ) => new Darius(champ),
  'Diana': (Mob champ) => new Diana(champ),
  'DrMundo': (Mob champ) => new DrMundo(champ),
  'Ekko': (Mob champ) => new Ekko(champ),
  'Fiora': (Mob champ) => new Fiora(champ),
  'Jax': (Mob champ) => new Jax(champ),
  'JarvanIV': (Mob champ) => new JarvanIV(champ),
  'Lulu': (Mob champ) => new Lulu(champ),
  'MasterYi': (Mob champ) => new MasterYi(champ),
  'Nasus': (Mob champ) => new Nasus(champ),
  'Nocturne': (Mob champ) => new Nocturne(champ),
  'Olaf': (Mob champ) => new Olaf(champ),
  'Orianna': (Mob champ) => new Orianna(champ),
  'Rammus': (Mob champ) => new Rammus(champ),
  'Singed': (Mob champ) => new Singed(champ),
  'TahmKench': (Mob champ) => new TahmKench(champ),
  'Tryndamere': (Mob champ) => new Tryndamere(champ),
  'Trundle': (Mob champ) => new Trundle(champ),
  'Twitch': (Mob champ) => new Twitch(champ),
  'Urgot': (Mob champ) => new Urgot(champ),
  'Volibear': (Mob champ) => new Volibear(champ),
  'Warwick': (Mob champ) => new Warwick(champ),
  'XinZhao': (Mob champ) => new XinZhao(champ),
  'Zed': (Mob champ) => new Zed(champ),
};

bool haveImplementedChampionPassive(String id) {
  return _championEffectsConstructors[id] != null;
}

ChampionEffects constructEffectsForChampion(Mob champ) {
  ChampionEffectsConstructor constructor =
      _championEffectsConstructors[champ.id];
  if (constructor == null) return null;
  ChampionEffects effects = constructor(champ);
  if (effects != null) effects.onCreate();
  return effects;
}

typedef BuffEffects SpellEffectsConstructor(Mob champ, int rank);
final Map<String, SpellEffectsConstructor> _spellEffectsConstructors = {
  'VolibearW': (Mob champ, int rank) => new VolibearW(champ, rank),
  'TryndamereQ': (Mob champ, int rank) => new TryndamereQ(champ, rank),
  'AmumuW': (Mob champ, int rank) => new AmumuW(champ, rank),
  'AmumuE': (Mob champ, int rank) => new AmumuE(champ, rank),
  'Smite': (Mob champ, int _) => new Smite(champ),
};

BuffEffects constructEffectsForSpell(
    SpellDescription description, Mob champ, int rank) {
  SpellEffectsConstructor constructor =
      _spellEffectsConstructors[description.id];
  if (constructor == null) return null;
  BuffEffects effects = constructor(champ, rank);
  if (effects != null) effects.onCreate();
  return effects;
}
