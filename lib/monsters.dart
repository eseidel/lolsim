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

final MobDescription greaterMurkWolfDescription = new MobDescription.fromJson({
  'name': 'Greater Murk Wolf',
  'stats': new Map.from(_sharedMonsterStats)
    ..addAll(<String, double>{
      // These are values at level 2:
      'hp': 1300.0,
      'hpperlevel': 0.0, // FIXME: Wrong.
      'armor': 10.0,
      'armorperlevel': 0.0, // FIXME: Wrong.
      'spellblock': 0.0,
      'spellblockperlevel': 0.0, // FIXME: Wrong.
      'movespeed': 443.0,
      'attackspeedoffset': attackDelayFromBaseAttackSpeed(0.625),
      'attackdamage': 42.0,
      'attackdamageperlevel': 0.0, // FIXME: Wrong.
      'attackrange': 175.0,
    }),
});

// FIXME: Do the big vs. little wolves really have different values of MR/AR?
final MobDescription murkWolfDescription = new MobDescription.fromJson({
  'name': 'Murk Wolf',
  'stats': new Map.from(_sharedMonsterStats)
    ..addAll(<String, double>{
      // These are values at level 2:
      'hp': 380.0,
      'hpperlevel': 0.0, // FIXME: Wrong.
      'armor': 0.0,
      'armorperlevel': 0.0, // FIXME: Wrong.
      'spellblock': 10.0,
      'spellblockperlevel': 0.0, // FIXME: Wrong.
      'movespeed': 443.0,
      'attackspeedoffset': attackDelayFromBaseAttackSpeed(0.625),
      'attackdamage': 16.0,
      'attackdamageperlevel': 0.0, // FIXME: Wrong.
      'attackrange': 175.0,
    }),
});

final MobDescription crimsonRaptorDescription = new MobDescription.fromJson({
  'name': 'Crimson Raptor',
  'stats': new Map.from(_sharedMonsterStats)
    ..addAll(<String, double>{
      // These are values at level 2:
      'hp': 700.0,
      'hpperlevel': 0.0, // FIXME: Wrong.
      'armor': 30.0,
      'armorperlevel': 0.0, // FIXME: Wrong.
      'spellblock': 30.0,
      'spellblockperlevel': 0.0, // FIXME: Wrong.
      'movespeed': 350.0,
      'attackspeedoffset': attackDelayFromBaseAttackSpeed(0.667),
      'attackdamage': 20.0,
      'attackdamageperlevel': 0.0, // FIXME: Wrong.
      'attackrange': 300.0,
    }),
});

final MobDescription raptorDescription = new MobDescription.fromJson({
  'name': 'Raptor', // NOT DONE.
  'stats': new Map.from(_sharedMonsterStats)
    ..addAll(<String, double>{
      // These are values at level 2:
      'hp': 350.0,
      'hpperlevel': 0.0, // FIXME: Wrong.
      'armor': 0.0,
      'armorperlevel': 0.0, // FIXME: Wrong.
      'spellblock': 0.0,
      'spellblockperlevel': 0.0, // FIXME: Wrong.
      'movespeed': 443.0,
      'attackspeedoffset': attackDelayFromBaseAttackSpeed(1.0),
      'attackdamage': 16.0,
      'attackdamageperlevel': 0.0, // FIXME: Wrong.
      'attackrange': 300.0,
    }),
});

enum MonsterType {
  blueSentinal,
  redBrambleback,
  greaterMurkWolf,
  murkWolf,
  crimsonRaptor,
  raptor,
}

Mob createMonster(MonsterType type) {
  switch (type) {
    case MonsterType.blueSentinal:
      return new Mob(blueSentinalDescription, MobType.monster);
    case MonsterType.redBrambleback:
      return new Mob(redBramblebackDescription, MobType.monster);
    case MonsterType.greaterMurkWolf:
      return new Mob(greaterMurkWolfDescription, MobType.monster);
    case MonsterType.murkWolf:
      return new Mob(murkWolfDescription, MobType.monster);
    case MonsterType.crimsonRaptor:
      return new Mob(crimsonRaptorDescription, MobType.monster);
    case MonsterType.raptor:
      return new Mob(raptorDescription, MobType.monster);
  }
  assert(false);
  return null;
}

enum CampType {
  blue,
  red,
  wolves,
  raptors,
  // gromp, // Has some decaying attack-speed buff?
  // scuttle, // Difficult due to kiting?
  // krugs, // difficult due to spawning rules.
}

List<Mob> createCamp(CampType type) {
  switch (type) {
    case CampType.blue:
      return <Mob>[createMonster(MonsterType.blueSentinal)];
    case CampType.red:
      return <Mob>[createMonster(MonsterType.redBrambleback)];
    case CampType.wolves:
      return <Mob>[
        // FIXME: Artificially ordered for Amumu. :/
        createMonster(MonsterType.greaterMurkWolf),
        createMonster(MonsterType.murkWolf),
        createMonster(MonsterType.murkWolf),
      ];
    case CampType.raptors:
      return <Mob>[
        // FIXME: Artificially ordered for Amumu. :/
        createMonster(MonsterType.crimsonRaptor),
        createMonster(MonsterType.raptor),
        createMonster(MonsterType.raptor),
        createMonster(MonsterType.raptor),
        createMonster(MonsterType.raptor),
        createMonster(MonsterType.raptor),
      ];
  }
  assert(false);
  return null;
}
