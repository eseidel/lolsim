#!/usr/local/bin/dart
import 'package:lol_duel/common_args.dart';
import 'package:lol_duel/creator.dart';
import 'package:lol_duel/lolsim.dart';
import 'package:lol_duel/stat_constants.dart';
import 'package:lol_duel/cli_table.dart';

class _GoldEfficiency {
  Item item;
  double value;

  _GoldEfficiency(this.item, _StatCosts statCosts) {
    value = statCosts.goldValueOfStats(item);
  }

  int get cost => item.description.gold['total'];
  double get efficiency => value / cost;
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
  _StatCosts(ItemFactory items) {
    void computePerUnitCost(statName, baseItemName) {
      Item baseItem = items.itemByName(baseItemName);
      double valueOfOtherStats = goldValueOfStats(baseItem, except: statName);
      num statValue = baseItem.description.stats[statName];
      assert(
          statValue != null, '$baseItemName missing stat value for $statName.');
      double goldValue = baseItem.description.gold['total'] - valueOfOtherStats;
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

  double goldValueOfStats(Item item, {String except}) {
    double value = 0.0;
    item.description.stats.forEach((statName, statValue) {
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

  Creator creator = await Creator.loadLatest();
  List<Item> items = creator.items
      .allItems()
      .where((item) =>
          item.isAvailableOn(Maps.CURRENT_SUMMONERS_RIFT) &&
          item.generallyAvailable &&
          !item.description.consumable)
      .toList();

  _StatCosts statCosts = new _StatCosts(creator.items);

  List<_GoldEfficiency> results =
      items.map((item) => new _GoldEfficiency(item, statCosts)).toList();
  results.sort((a, b) => a.efficiency.compareTo(b.efficiency));

  TableLayout layout = new TableLayout([35, 6, 15]);
  layout.printRow(['Item', 'Cost', 'Efficiency']);
  layout.printDivider();

  for (var result in results) {
    layout.printRow([
      result.item.name,
      result.cost.toString(),
      // result.value.toStringAsFixed(1),
      _toPercentString(result.efficiency),
    ]);
  }
}
