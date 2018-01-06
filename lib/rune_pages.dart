import 'dragon/dragon.dart';
import 'effects.dart';
import 'mob.dart';
import 'runes_reforged.dart';

import 'package:meta/meta.dart';

class RuneDescriptionPage {
  List<RuneDescription> runes;
  RunePath primary;
  RunePath secondary;

  RuneDescriptionPage({
    @required this.runes,
    @required this.primary,
    @required this.secondary,
  }) {
    this.runes.forEach((RuneDescription rune) {
      assert(rune.path == primary || rune.path == secondary);
    });
  }

  // FIXME: This should describe the page.
  String get summaryString => 'rune page';
}

class RunePage {
  String name;
  Mob owner;
  RuneDescriptionPage description;
  List<Rune> runes;
  RuneEffects traitEffects;

  RunePage(
    this.owner,
    this.description,
  ) {
    runes = description.runes
        .map((description) => new Rune(owner, description))
        .toList();
    runes.forEach((rune) => rune.logIfMissingEffects());
    traitEffects = constructTraitRuneEffects(
        description.primary, description.secondary, owner);
  }

  // FIXME: This should describe the page.
  String get summaryString => 'rune page';

  Iterable<RuneEffects> get effects sync* {
    for (Rune rune in runes) {
      if (rune.effects != null) yield rune.effects;
    }
    if (traitEffects != null) yield traitEffects;
  }

  @override
  String toString() => name;

  Rune get keystone {
    assert(runes[0].description.slot == RuneSlot.keystone);
    return runes[0];
  }
}
