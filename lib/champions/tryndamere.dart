import 'package:lol_duel/lolsim.dart';
import 'package:lol_duel/dragon.dart';
import 'package:lol_duel/buffs.dart';
import 'package:lol_duel/stat_constants.dart';
import 'package:lol_duel/champions.dart';
import 'dart:math';

class Tryndamere extends ChampionEffects {
  Mob tryndamere;
  BattleFury battleFury;
  Tryndamere(this.tryndamere);

  // Should this move onto the buff?
  @override
  void onHit(Hit hit) {
    if (hit.target.type == MobType.structure) return;
    if (hit.isCrit)
      battleFury.addFury(10);
    else
      battleFury.addFury(5);
  }

  @override
  void onChampionCreate() {
    battleFury = new BattleFury(tryndamere);
    tryndamere.addBuff(battleFury);
  }
}

class BattleFury extends PermanentBuff {
  int fury = 0; // Should move to Mob?

  BattleFury(Mob target) : super(name: "Battle Fury", target: target);

  void addFury(int newFury) {
    fury = min(100, fury + newFury);
  }

  @override
  Map<String, num> get stats => {
        FlatCritChanceMod: 0.0035 * fury,
      };
}
