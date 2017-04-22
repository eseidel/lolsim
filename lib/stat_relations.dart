import 'dart:async';
import 'package:lol_duel/stat_constants.dart';
import 'package:lol_duel/dragon.dart';
import 'package:lol_duel/creator.dart';

// Inspired by https://www.reddit.com/r/leagueoflegends/comments/2bay6z/should_you_buy_armor_or_health_graph_inside/
// Similarly http://imgur.com/a/3qUe8
Future relateArmorToHp(ItemFactory items) async {
  ItemDescription armorItem = items.itemByName('Cloth Armor').description;
  ItemDescription hpItem = items.itemByName('Ruby Crystal').description;

  double goldToArmor = armorItem.stats[FlatArmorMod] / armorItem.gold['total'];
  double armorToGold = 1 / goldToArmor;
  double goldToHp = hpItem.stats[FlatHPPoolMod] / hpItem.gold['total'];

  // Solving for a point on the line:
  // EPH = effective health points
  // EHP = HP * (100 + AR) / 100
  // Where EPH delta (dEHP) of spending gold on armor
  // dEHP(G) = HP * 0.01 * (G * gold_to_armor)
  // is equal to dEHP of spending gold on hp
  // dEHP(G) = G * gold_to_hp * ((100 + AR) / 100)
  // Equating at a convenient value e.g. armor zero (AR = 0)
  // G * gold_to_hp = HP * 0.01 * (G * gold_to_armor)
  // and solving for HP:
  double hpAtArmorZero = 100 * goldToHp / goldToArmor;
  print('Point: AR=0, HP=$hpAtArmorZero');

  // Slope
  double marginalHpCostOfArmorThroughGold = armorToGold * goldToHp;
  print('Slope: $marginalHpCostOfArmorThroughGold');
}

typedef double ConvertApsToAd(double aps);

Future<ConvertApsToAd> relateAttacksPerSecondToAttackDamage(
    ItemFactory items, double baseAttackSpeed) async {
  // ad = attack damage, pas = percent attack speed
  ItemDescription pasItem = items.itemByName('Dagger').description;
  ItemDescription adItem = items.itemByName('Long Sword').description;

  double goldToPas =
      pasItem.stats[PercentAttackSpeedMod] / pasItem.gold['total'];
  double goldToAps = goldToPas * baseAttackSpeed;
  double apsToGold = 1 / goldToAps;
  double goldToAd = adItem.stats[FlatPhysicalDamageMod] / adItem.gold['total'];

  // Solving for a point on the line:
  // DPS = Damage Per Second, AD = Attack Damage, APS = Attacks Per Second
  // DPS = AD * APS
  // BAS = Base attack speed (per-champion), PAS = Bonus (percent) Attack Speed
  // APS = (1 + PAS) * BAS
  // Where dps delta (dDPS) of spending gold on APS
  // dDPS(G) = AD * G * goldToAps
  // is equal to dDPS of spending gold on AD
  // dEHP(G) = G * goldToAd * APS
  // Equating at a convenient value e.g. 1.0 attacks per second (APS = 1)
  // G * goldToAd = AD * G * goldToAps
  // And solving for AD:
  double adAtOneAps = goldToAd / goldToAps; // Assumes APS = 1.0

  // Slope aka "marginalAdCostOfAttacksPerSecondThroughGold"
  double slope = apsToGold * goldToAd;

  // point slope form
  return (double aps) => slope * (aps - 1.0) + adAtOneAps;
}
