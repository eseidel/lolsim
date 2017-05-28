import 'dragon.dart';

final Map<String, double> _sharedMonsterStats = {
  'spellblockperlevel': 0.0,
  'armorperlevel': 0.0,
  'mpperlevel': 0.0,
  'attackspeedperlevel': 0.0,
  'hpregen': 0.0,
  'hpregenperlevel': 0.0,
  'mp': 0.0,
};

// Spawns at lvl 2, 4, 6
final MobDescription blueSentinalDescription = new MobDescription.fromJson({
  'name': 'Blue Sentinal',
  'stats': new Map.from(_sharedMonsterStats)
    ..addAll(<String, double>{
      // These are values at lvl 2.
      // Dying to blue doesn't seem to level it up.
      // Spawn level seems related to levels in game?
      'hp': 2100.0,
      'hpperlevel': 0.0, // FIXME: Wrong.
      'armor': 10.0,
      'spellblock': -15.0,
      'movespeed': 200.0,
      'attackspeedoffset': attackDelayFromBaseAttackSpeed(0.493),
      'attackdamage': 82.0,
      'attackdamageperlevel': 6.0, // FIXME: Wrong according to wiki.
      'attackrange': 125.0, // FIXME: No clue if this is right.
    }),
});
