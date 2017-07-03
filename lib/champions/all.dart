import '../dragon/spell_parser.dart';
import '../effects.dart';
import '../lolsim.dart';
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
import 'twitch.dart';
import 'urgot.dart';
import 'volibear.dart';
import 'warwick.dart';
import 'xinzhao.dart';
import 'zed.dart';
import '../summoners.dart';

typedef ChampionEffects ChampionEffectsConstructor(Mob champion);
Map<String, ChampionEffectsConstructor> championEffectsConstructors = {
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
  'Twitch': (Mob champ) => new Twitch(champ),
  'Urgot': (Mob champ) => new Urgot(champ),
  'Volibear': (Mob champ) => new Volibear(champ),
  'Warwick': (Mob champ) => new Warwick(champ),
  'XinZhao': (Mob champ) => new XinZhao(champ),
  'Zed': (Mob champ) => new Zed(champ),
};

typedef SpellEffects SpellEffectsConstructor(Mob champ, int rank);
final Map<String, SpellEffectsConstructor> _spellEffectsConstructors = {
  'VolibearW': (Mob champ, int rank) => new VolibearW(champ, rank),
  'TryndamereQ': (Mob champ, int rank) => new TryndamereQ(champ, rank),
  'AmumuW': (Mob champ, int rank) => new AmumuW(champ, rank),
  'AmumuE': (Mob champ, int rank) => new AmumuE(champ, rank),
  'Smite': (Mob champ, int _) => new Smite(champ),
};

SpellEffects constructEffectsForSpell(
    SpellDescription description, Mob champ, int rank) {
  SpellEffectsConstructor constructor =
      _spellEffectsConstructors[description.id];
  if (constructor == null) return null;
  return constructor(champ, rank);
}
