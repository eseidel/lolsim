import 'dragon.dart';

final Map<String, double> _sharedMinionStats = {
  'spellblockperlevel': 0.0,
  'armorperlevel': 0.0,
  'mpperlevel': 0.0,
  'movespeed': 325.0,
  'attackspeedperlevel': 0.0,
  'armor': 0.0,
  'spellblock': 0.0,
  'hpregen': 0.0,
  'hpregenperlevel': 0.0,
  'mp': 0.0,
};

final MobDescription meleeMinionDescription = new MobDescription.fromJson({
  'name': 'Melee Minion',
  'stats': new Map.from(_sharedMinionStats)
    ..addAll(<String, double>{
      'hp': 455.0,
      'hpperlevel': 18.0,
      'attackspeedoffset': attackDelayFromBaseAttackSpeed(1.25),
      'attackdamage': 12.0,
      'attackdamageperlevel': 0.0,
      'attackrange': 110.0,
    }),
}, MobType.minion);

final MobDescription rangedMinionDescription = new MobDescription.fromJson({
  'name': 'Ranged Minion',
  'stats': new Map.from(_sharedMinionStats)
    ..addAll(<String, double>{
      'hp': 290.0,
      'hpperlevel': 6.0,
      'attackspeedoffset': attackDelayFromBaseAttackSpeed(0.667),
      'attackdamage': 22.5,
      'attackdamageperlevel': 1.5,
      'attackrange': 550.0,
    }),
}, MobType.minion);

final MobDescription siegeMinionDescription = new MobDescription.fromJson({
  'name': 'Siege Minion',
  'stats': new Map.from(_sharedMinionStats)
    ..addAll(<String, double>{
      'hp': 805.0,
      'hpperlevel': 0.0, // FIXME: This is likely wrong, missing from wiki.
      'attackspeedoffset': attackDelayFromBaseAttackSpeed(1.0),
      'attackdamage': 39.5,
      'attackdamageperlevel': 1.5,
      'attackrange': 300.0,
    }),
}, MobType.minion);

final MobDescription superMinionDescription = new MobDescription.fromJson({
  'name': 'Siege Minion',
  'stats': new Map.from(_sharedMinionStats)
    ..addAll(<String, double>{
      'hp': 1500.0,
      'hpperlevel': 200.0,
      'attackspeedoffset': attackDelayFromBaseAttackSpeed(0.694),
      'attackdamage': 190.0,
      'attackdamageperlevel': 10.0,
      'attackrange': 170.0,
      'armor': 30.0,
      'spellblock': -30.0,
    }),
}, MobType.minion);
