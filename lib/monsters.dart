import 'dragon/dragon.dart';
import 'lolsim.dart';

final Map<String, double> _sharedMonsterStats = {
  'attackspeedperlevel': 0.0,
  'hpregen': 0.0,
  'hpregenperlevel': 0.0,
  'mp': 0.0,
  'mpperlevel': 0.0,
  'mpregen': 0.0,
  'mpregenperlevel': 0.0,
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
      'armorperlevel': 0.0, // FIXME: Wrong.
      'spellblock': -15.0,
      'spellblockperlevel': 0.0, // FIXME: Wrong.
      'movespeed': 200.0,
      'attackspeedoffset': attackDelayFromBaseAttackSpeed(0.493),
      'attackdamage': 82.0,
      'attackdamageperlevel': 0.0, // FIXME: Wrong.
      'attackrange': 125.0, // FIXME: No clue if this is right.
    }),
});

final MobDescription redBramblebackDescription = new MobDescription.fromJson({
  'name': 'Red Brambleback',
  'stats': new Map.from(_sharedMonsterStats)
    ..addAll(<String, double>{
      // These are values at level 2:
      'hp': 2100.0,
      'hpperlevel': 0.0, // FIXME: Wrong.
      'armor': -15.0,
      'armorperlevel': 0.0, // FIXME: Wrong.
      'spellblock': 10.0,
      'spellblockperlevel': 0.0, // FIXME: Wrong.
      'movespeed': 275.0,
      'attackspeedoffset': attackDelayFromBaseAttackSpeed(0.599),
      'attackdamage': 82.0,
      'attackdamageperlevel': 0.0, // FIXME: Wrong.
      'attackrange': 125.0, // FIXME: No clue if this is right.
    }),
});

enum MonsterType {
  blueSentinal,
  redBrambleback,
}

Mob createMonster(MonsterType type) {
  switch (type) {
    case MonsterType.blueSentinal:
      return new Mob(blueSentinalDescription, MobType.monster);
    case MonsterType.redBrambleback:
      return new Mob(redBramblebackDescription, MobType.monster);
  }
  assert(false);
  return null;
}

enum CampType {
  blue,
  red,
  // chickens,
  // scuttle,
  // gromp,
  // krugs,
  // wolves,
}

List<Mob> createCamp(CampType type) {
  switch (type) {
    case CampType.blue:
      return <Mob>[createMonster(MonsterType.blueSentinal)];
    case CampType.red:
      return <Mob>[createMonster(MonsterType.redBrambleback)];
  }
  assert(false);
  return null;
}
