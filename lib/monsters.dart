import 'buffs.dart';
import 'dragon/dragon.dart';
import 'dragon/stat_constants.dart';
import 'effects.dart';
import 'lolsim.dart';
import 'package:meta/meta.dart';

final Map<String, double> _sharedMonsterStats = {
  'attackspeedperlevel': 0.0,
  'hpregen': 0.0,
  'hpregenperlevel': 0.0,
  'mp': 0.0,
  'mpperlevel': 0.0,
  'mpregen': 0.0,
  'mpregenperlevel': 0.0,
  'hpperlevel': 0.0, // FIXME: Wrong.
  'armorperlevel': 0.0, // FIXME: Wrong.
  'spellblockperlevel': 0.0, // FIXME: Wrong.
  'attackdamageperlevel': 0.0, // FIXME: Wrong.
};

final MobDescription grompDescription = new MobDescription.fromJson({
  'name': 'Gromp',
  'stats': new Map.from(_sharedMonsterStats)
    ..addAll(<String, double>{
      'armor': 0.0,
      'attackdamage': 70.0,
      'attackrange': 250.0,
      'attackspeedoffset': attackDelayFromBaseAttackSpeed(0.638),
      'hp': 1800.0,
      'movespeed': 330.0,
      'spellblock': -15.0,
    }),
});

final MobDescription blueSentinalDescription = new MobDescription.fromJson({
  'name': 'Blue Sentinal',
  'stats': new Map.from(_sharedMonsterStats)
    ..addAll(<String, double>{
      'hp': 2100.0,
      'armor': 10.0,
      'spellblock': -15.0,
      'movespeed': 200.0, // 180 + 20?
      'attackspeedoffset': attackDelayFromBaseAttackSpeed(0.493),
      'attackdamage': 82.0,
      'attackrange': 125.0, // FIXME: No clue if this is right.
    }),
});

final MobDescription redBramblebackDescription = new MobDescription.fromJson({
  'name': 'Red Brambleback',
  'stats': new Map.from(_sharedMonsterStats)
    ..addAll(<String, double>{
      'hp': 2100.0,
      'armor': -15.0,
      'spellblock': 10.0,
      'movespeed': 275.0,
      'attackspeedoffset': attackDelayFromBaseAttackSpeed(0.599),
      'attackdamage': 82.0,
      'attackrange': 125.0, // FIXME: No clue if this is right.
    }),
});

final MobDescription greaterMurkWolfDescription = new MobDescription.fromJson({
  'name': 'Greater Murk Wolf',
  'stats': new Map.from(_sharedMonsterStats)
    ..addAll(<String, double>{
      'hp': 1300.0,
      'armor': 10.0,
      'spellblock': 0.0,
      'movespeed': 443.0,
      'attackspeedoffset': attackDelayFromBaseAttackSpeed(0.625),
      'attackdamage': 42.0,
      'attackrange': 175.0,
    }),
});

final MobDescription murkWolfDescription = new MobDescription.fromJson({
  'name': 'Murk Wolf',
  'stats': new Map.from(_sharedMonsterStats)
    ..addAll(<String, double>{
      'hp': 380.0,
      'armor': 0.0,
      'spellblock': 10.0,
      'movespeed': 443.0,
      'attackspeedoffset': attackDelayFromBaseAttackSpeed(0.625),
      'attackdamage': 16.0,
      'attackrange': 175.0,
    }),
});

final MobDescription crimsonRaptorDescription = new MobDescription.fromJson({
  'name': 'Crimson Raptor',
  'stats': new Map.from(_sharedMonsterStats)
    ..addAll(<String, double>{
      'hp': 700.0,
      'armor': 30.0,
      'spellblock': 30.0,
      'movespeed': 350.0,
      'attackspeedoffset': attackDelayFromBaseAttackSpeed(0.667),
      'attackdamage': 20.0,
      'attackrange': 300.0,
    }),
});

final MobDescription raptorDescription = new MobDescription.fromJson({
  'name': 'Raptor',
  'stats': new Map.from(_sharedMonsterStats)
    ..addAll(<String, double>{
      'armor': 0.0,
      'attackdamage': 16.0,
      'attackrange': 300.0,
      'attackspeedoffset': attackDelayFromBaseAttackSpeed(1.0),
      'hp': 350.0,
      'movespeed': 443.0,
      'spellblock': 0.0,
    }),
});

final MobDescription ancientKrugsDescription = new MobDescription.fromJson({
  'name': 'Ancient Krugs',
  'stats': new Map.from(_sharedMonsterStats)
    ..addAll(<String, double>{
      'armor': 10.0,
      'attackdamage': 80.0,
      'attackrange': 150.0,
      'attackspeedoffset': attackDelayFromBaseAttackSpeed(0.613),
      'hp': 1250.0,
      'movespeed': 203.0, // 185 + 18?
      'spellblock': -15.0,
    }),
});

final MobDescription krugsDescription = new MobDescription.fromJson({
  'name': 'Krugs',
  'stats': new Map.from(_sharedMonsterStats)
    ..addAll(<String, double>{
      'armor': 0.0,
      'attackdamage': 25.0,
      'attackrange': 110.0,
      'attackspeedoffset': attackDelayFromBaseAttackSpeed(0.625),
      'hp': 500.0,
      'movespeed': 285.0,
      'spellblock': 0.0,
    }),
});

final MobDescription miniKrugsDescription = new MobDescription.fromJson({
  'name': 'Mini Krugs',
  'stats': new Map.from(_sharedMonsterStats)
    ..addAll(<String, double>{
      'armor': 0.0,
      'attackdamage': 17.0,
      'attackrange': 110.0,
      'attackspeedoffset': attackDelayFromBaseAttackSpeed(0.625),
      'hp': 60.0,
      'movespeed': 335.0,
      'spellblock': 0.0,
    }),
});

// lvl, HP:
// 6, 4940
// 7, 5180
final MobDescription cloudDrakeDescription = new MobDescription.fromJson({
  'name': 'Cloud Drake',
  'stats': new Map.from(_sharedMonsterStats)
    ..addAll(<String, double>{
      'armor': 21.0,
      'attackdamage': 50.0,
      'attackrange': 500.0,
      'attackspeedoffset': attackDelayFromBaseAttackSpeed(1.0),
      'hp': 3500.0,
      'hpperlevel': 240.0,
      'movespeed': 300.0,
      'spellblock': 30.0,
    }),
});

// lvl 6, 4940hp
final MobDescription infernalDrakeDescription = new MobDescription.fromJson({
  'name': 'Infernal Drake',
  'stats': new Map.from(_sharedMonsterStats)
    ..addAll(<String, double>{
      'armor': 21.0,
      'attackdamage': 100.0,
      'attackrange': 500.0,
      'attackspeedoffset': attackDelayFromBaseAttackSpeed(0.5),
      'hp': 3500.0,
      'hpperlevel': 240.0,
      'movespeed': 330.0,
      'spellblock': 30.0,
    }),
});

// lvl 6, 5434 hp
final MobDescription mountainDrakeDescription = new MobDescription.fromJson({
  'name': 'Mountain Drake',
  'stats': new Map.from(_sharedMonsterStats)
    ..addAll(<String, double>{
      'armor': 41.0,
      'attackdamage': 150.0,
      'attackrange': 500.0,
      'attackspeedoffset': attackDelayFromBaseAttackSpeed(0.250),
      'hp': 3850.0,
      'hpperlevel': 264.0,
      'movespeed': 330.0,
      'spellblock': 50.0,
    }),
});

// lvl, hp, ar, mr:
//  6, 4940
//  7, 5180
//  8, 5420, 21, 30
//  9, 5660, 21, 30
// 10, 5900, 21, 30
// 11, 6140, 26, 33 (marked as yellow, but no +?)
// 12, 6380, 33, 37
// 13, 6620, 40, 42
// 14, 6860, 48, 47
// 15, 7100, 57, 53
// 16, 7340, 67, 59
// 17, 7580, 78, 66
// 18, 7820, 90, 73
final MobDescription oceanDrakeDescription = new MobDescription.fromJson({
  'name': 'Ocean Drake',
  'stats': new Map.from(_sharedMonsterStats)
    ..addAll(<String, double>{
      'armor': 21.0,
      'attackdamage': 100.0,
      'attackrange': 500.0,
      'attackspeedoffset': attackDelayFromBaseAttackSpeed(0.500),
      'hp': 3500.0,
      'hpperlevel': 240.0,
      'movespeed': 330.0,
      'spellblock': 30.0,
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

class AncientKrugsDeath extends PermanentBuff {
  AncientKrugsDeath(Mob target) : super(target: target);

  @override
  String get lastUpdate => VERSION_7_11_1;

  @override
  void onDeath(Mob killer) {
    // FIXME: These should spawn after 1-2s.
    World.current.addMobs([
      createMonster(MonsterType.krugs)..team = target.team,
      createMonster(MonsterType.krugs)..team = target.team,
    ]);
  }
}

class KrugsDeath extends PermanentBuff {
  KrugsDeath(Mob target) : super(target: target);

  @override
  String get lastUpdate => VERSION_7_11_1;

  @override
  void onDeath(Mob killer) {
    // FIXME: These should spawn after 1-2s.
    World.current.addMobs([
      createMonster(MonsterType.miniKrugs)..team = target.team,
      createMonster(MonsterType.miniKrugs)..team = target.team,
    ]);
  }
}

class DragonsHitHard extends PermanentBuff {
  DragonsHitHard(Mob dragon) : super(target: dragon, name: 'Dragons hit hard');

  @override
  String get lastUpdate => VERSION_7_11_1;

  @override
  Map<String, num> get stats => {
        PercentArmorPenetrationMod: 30.0,
      };

  @override
  void onAutoAttackHit(Hit hit) {
    hit.addOnHitDamage(new Damage(
      label: name,
      physicalDamage: hit.target.currentHp * 0.07,
    ));
  }
}

enum MonsterType {
  blueSentinal,
  redBrambleback,
  greaterMurkWolf,
  murkWolf,
  crimsonRaptor,
  raptor,
  gromp,
  ancientKrugs,
  krugs,
  miniKrugs,
  cloudDrake,
  infernalDrake,
  mountainDrake,
  oceanDrake,
}

Mob _createDragon(MobDescription description) {
  Mob dragon = new Mob(description, MobType.epicMonster);
  // FIXME: Level should be set from average level of champions with a floor of lvl 6.
  dragon.level = 6;
  dragon.addBuff(new DragonsHitHard(dragon));
  return dragon;
}

Mob createMonster(MonsterType type) {
  switch (type) {
    case MonsterType.blueSentinal:
      Mob blue = new Mob(blueSentinalDescription, MobType.largeMonster);
      blue.addBuff(new CrestOfInsight(blue));
      return blue;
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
    case MonsterType.ancientKrugs:
      Mob krugs = new Mob(ancientKrugsDescription, MobType.largeMonster);
      krugs.addBuff(new AncientKrugsDeath(krugs));
      return krugs;
    case MonsterType.krugs:
      Mob krugs = new Mob(krugsDescription, MobType.smallMonster);
      krugs.addBuff(new KrugsDeath(krugs));
      return krugs;
    case MonsterType.miniKrugs:
      return new Mob(miniKrugsDescription, MobType.smallMonster);
    case MonsterType.cloudDrake:
      return _createDragon(cloudDrakeDescription);
    case MonsterType.mountainDrake:
      return _createDragon(mountainDrakeDescription);
    case MonsterType.oceanDrake:
      return _createDragon(oceanDrakeDescription);
    case MonsterType.infernalDrake:
      return _createDragon(cloudDrakeDescription);
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
  krugs,
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
    case CampType.krugs:
      return <Mob>[
        createMonster(MonsterType.ancientKrugs),
        createMonster(MonsterType.krugs),
      ];
  }
  assert(false);
  return null;
}

class CrestOfInsight extends TimedBuff {
  CrestOfInsight(Mob target)
      : super(
          target: target,
          name: 'Crest of Insight',
          duration: 120.0, // FIXME: Should respect Runic Affinity.
        );

  @override
  String get lastUpdate => VERSION_7_11_1;

  @override
  void onDeath(Mob killer) {
    // FIXME: This should be add or refresh.
    if (killer.isChampion) killer.addBuff(new CrestOfInsight(killer));
  }

  @override
  Map<String, num> get stats => {
        FlatMPRegenMod: 5.0 + 0.01 * target.stats.mp,
        PercentCooldownMod: -0.10,
        // Or 0.5% of energy.
      };
}

class RedBurn extends SimpleDOT {
  Mob source;

  RedBurn({@required this.source, @required Mob target})
      : super(
          name: 'Cinder Burn',
          target: target,
          initialTicks: 2,
          secondsBetweenTicks: 1.5,
        );

  @override
  String get lastUpdate => VERSION_7_11_1;

  double get damagePerTick => 2.0 + 2.0 * source.level;

  @override
  Hit createHitForTick() {
    return source.createHitForTarget(
      label: name,
      trueDamage: damagePerTick,
      target: target,
      targeting: Targeting.dot,
    );
  }
}

class CrestOfCinders extends TimedBuff {
  CrestOfCinders(Mob target)
      : super(
          target: target,
          name: 'Crest of Cinders',
          duration: 120.0,
        );
  @override
  String get lastUpdate => VERSION_7_11_1;

  @override
  void onDeath(Mob killer) {
    // FIXME: This should be add or refresh.
    if (killer.isChampion) killer.addBuff(new CrestOfCinders(killer));
  }

  // FIXME: Needs in-combat to know when to heal.

  static RedBurn applyToOrRefresh(
      {@required Mob source, @required Mob target}) {
    RedBurn debuff =
        target.buffs.firstWhere((buff) => buff is RedBurn, orElse: () => null);
    if (debuff == null) {
      debuff = new RedBurn(target: target, source: source);
      target.addBuff(debuff);
    } else {
      debuff.refresh();
    }
    return debuff;
  }

  @override
  void onAutoAttackHit(Hit hit) {
    RedBurn debuff = applyToOrRefresh(source: hit.source, target: hit.target);
    // Also apply once on-hit.
    hit.addOnHitDamage(new Damage(
      label: name,
      trueDamage: debuff.damagePerTick,
    ));
  }
}
