#!/usr/local/bin/dart
import 'package:lol_duel/common_args.dart';
import 'package:lol_duel/dragon.dart';
import 'package:lol_duel/stat_constants.dart';
import 'package:lol_duel/cli_table.dart';

class _Result {
  ItemDescription item;
  double statGoldValue;
  int tooltipPassivesCount;
  int tooltipActivesCount;

  static final RegExp _passivePattern =
      new RegExp('passive', caseSensitive: false);
  static final RegExp _activePattern =
      new RegExp('active', caseSensitive: false);

  _Result(this.item, _StatCosts statCosts) {
    statGoldValue = statCosts.goldValueOfStats(item);
    tooltipPassivesCount = _passivePattern.allMatches(item.tooltip).length;
    tooltipActivesCount = _activePattern.allMatches(item.tooltip).length;
  }

  int get statCount => item.stats.length;
  int get cost => item.gold['total'];
  double get efficiency => statGoldValue / cost;
}

class _StatCosts {
  static final Map<String, String> _baseItems = {
    PercentAttackSpeedMod: 'Dagger',
    FlatPhysicalDamageMod: 'Long Sword',
    FlatHPPoolMod: 'Ruby Crystal',
    FlatMagicDamageMod: 'Amplifying Tome',
    FlatSpellBlockMod: 'Null-Magic Mantle',
    FlatMPPoolMod: 'Sapphire Crystal',
    FlatCritChanceMod: "Brawler's Gloves",
    FlatMovementSpeedMod: 'Boots of Speed',
    FlatArmorMod: 'Cloth Armor',
  };

  static final Map<String, String> _secondTierBaseItems = {
    PercentLifeStealMod: 'Vampiric Scepter',
    PercentMovementSpeedMod: 'Aether Wisp',
  };

  final Map<String, double> _perUnitCost = {};
  _StatCosts(ItemLibrary items) {
    void computePerUnitCost(statName, baseItemName) {
      ItemDescription baseItem = items.itemByName(baseItemName);
      double valueOfOtherStats = goldValueOfStats(baseItem, except: statName);
      num statValue = baseItem.stats[statName];
      assert(
          statValue != null, '$baseItemName missing stat value for $statName.');
      double goldValue = baseItem.gold['total'] - valueOfOtherStats;
      _perUnitCost[statName] = goldValue / statValue;
    }

    _StatCosts._baseItems.forEach(computePerUnitCost);
    _StatCosts._secondTierBaseItems.forEach(computePerUnitCost);
  }

  double perUnitCostFor(String statName) {
    // FIXME: Hack, should not lookup base items.
    if (statName == FlatHPRegenMod) return 0.0;
    assert(_perUnitCost.containsKey(statName), "Missing cost for $statName.");
    return _perUnitCost[statName];
  }

  double goldValueOfStats(ItemDescription item, {String except}) {
    double value = 0.0;
    item.stats.forEach((statName, statValue) {
      if (statName == except) return;
      value += goldValueOf(statName, statValue);
    });
    return value;
  }

  double goldValueOf(String statName, num statValue) {
    return perUnitCostFor(statName) * statValue;
  }
}

String _toPercentString(double value) {
  return "${(100 * value).toStringAsFixed(1)}%";
}

dynamic main(List<String> args) async {
  handleCommonArgs(args);

  DragonData dragon = await DragonData.loadLatest();
  List<ItemDescription> items = dragon.items
      .all()
      .where((item) =>
          item.isAvailableOn(Maps.CURRENT_SUMMONERS_RIFT) &&
          item.generallyAvailable &&
          !item.isTrinket &&
          !item.consumable)
      .toList();

  _StatCosts statCosts = new _StatCosts(dragon.items);

  List<_Result> results =
      items.map((item) => new _Result(item, statCosts)).toList();
  results.sort((a, b) => a.efficiency.compareTo(b.efficiency));

  TableLayout layout = new TableLayout([35, 6, 10, 5, 8, 7]);
  layout
      .printRow(['Item', 'Cost', 'Efficiency', 'Stats', 'Passives', 'Actives']);
  layout.printDivider();

  String emptyIfZero(int value) {
    return value == 0 ? '' : value.toString();
  }

  for (var result in results) {
    layout.printRow([
      result.item.name,
      result.cost.toString(),
      // result.value.toStringAsFixed(1),
      _toPercentString(result.efficiency),
      emptyIfZero(result.statCount),
      emptyIfZero(result.tooltipPassivesCount),
      emptyIfZero(result.tooltipActivesCount),
    ]);
  }
}
