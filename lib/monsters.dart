import 'dragon/dragon.dart';
import 'lolsim.dart';
import 'buffs.dart';
import 'effects.dart';
import 'dragon/stat_constants.dart';

final Map<String, double> _sharedMonsterStats = {
  'attackspeedperlevel': 0.0,
  'hpregen': 0.0,
  'hpregenperlevel': 0.0,
  'mp': 0.0,
  'mpperlevel': 0.0,
  'mpregen': 0.0,
  'mpregenperlevel': 0.0,
};

final MobDescription grompDescription = new MobDescription.fromJson({
  'name': 'Gromp',
  'stats': new Map.from(_sharedMonsterStats)
    ..addAll(<String, double>{
      // These are values at level 2:
      'hp': 1800.0,
      'hpperlevel': 0.0, // FIXME: Wrong.
      'armor': 0.0,
      'armorperlevel': 0.0, // FIXME: Wrong.
      'spellblock': -15.0,
      'spellblockperlevel': 0.0, // FIXME: Wrong.
      'movespeed': 330.0,
      'attackspeedoffset': attackDelayFromBaseAttackSpeed(0.638),
      'attackdamage': 70.0,
      'attackdamageperlevel': 0.0, // FIXME: Wrong.
      'attackrange': 250.0,
    }),
});

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
      'movespeed': 200.0, // 180 + 20?
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

// Krugs -- 185 + 18

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
  'name': 'Raptor',
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

// Gromp in-combat per-hit stats reported in-client:
// 1.004 (0.638 + 0.367) AS, 70 AD
// 0.876 (0.638 + 0.236) AS, 66 AD
// 0.760 (0.638 + 0.123) AS, 62 AD
// 0.661 (0.638 + 0.024) AS, 58 AD
// 0.575 (0.575 + 0.000) AS, 54 AD
// 0.501 (0.501 + 0.000) AS, 50 AD
class GrompGetsTired extends PermanentBuff {
  @override
  String get lastUpdate => VERSION_7_11_1;

  int attackCount = 0;

  @override
  Map<String, num> get stats => {
        // FIXME: The middle attack speeds are wrong.  Shrug.
        PercentAttackSpeedMod: .575 + -0.158 * attackCount,
        FlatPhysicalDamageMod: -4 * attackCount,
      };

  @override
  void onAutoAttackHit(Hit hit) {
    if (attackCount < 6) attackCount += 1;
  }

  // FIXME: Need to reset attackCount on out of combat.
}

enum MonsterType {
  blueSentinal,
  redBrambleback,
  greaterMurkWolf,
  murkWolf,
  crimsonRaptor,
  raptor,
  gromp,
}

Mob createMonster(MonsterType type) {
  switch (type) {
    case MonsterType.blueSentinal:
      return new Mob(blueSentinalDescription, MobType.largeMonster);
    case MonsterType.redBrambleback:
      return new Mob(redBramblebackDescription, MobType.largeMonster);
    case MonsterType.greaterMurkWolf:
      return new Mob(greaterMurkWolfDescription, MobType.largeMonster);
    case MonsterType.murkWolf:
      return new Mob(murkWolfDescription, MobType.smallMonster);
    case MonsterType.crimsonRaptor:
      return new Mob(crimsonRaptorDescription, MobType.largeMonster);
    case MonsterType.raptor:
      return new Mob(raptorDescription, MobType.smallMonster);
    case MonsterType.gromp:
      Mob gromp = new Mob(grompDescription, MobType.largeMonster);
      gromp.addBuff(new GrompGetsTired());
      return gromp;
  }
  assert(false);
  return null;
}

enum CampType {
  gromp,
  blue,
  wolves,
  raptors,
  red,
  // krugs, // Missing spawning rules.
  // scuttle, // Missing movement.
}

String campTypeToString(CampType type) => type.toString().split('.')[1];

List<Mob> createCamp(CampType type) {
  switch (type) {
    case CampType.gromp:
      return <Mob>[createMonster(MonsterType.gromp)];
    case CampType.blue:
      return <Mob>[createMonster(MonsterType.blueSentinal)];
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
    case CampType.red:
      return <Mob>[createMonster(MonsterType.redBrambleback)];
  }
  assert(false);
  return null;
}
