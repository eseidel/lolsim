# lolsim
Toy implementation of League of Legends' combat engine.

My goal here is to familiarize myself with the finer details of LOL's rules as
well as have a chance to play around with Dart.

It's difficult to imagine this ever being perfect simulation, in part because
Riot does not make all of their rule values public (e.g. attack-windup,
ability-durations, etc.) but also because keeping up with LOL would be a huge
task and would be largely obsoleted by any successful LOL sandbox mode (there
have been many attempts).

## Requirements
Need a copy of `champion.json` and `item.json` from [Riot's static data](https://developer.riotgames.com/docs/static-data).

## Usage
There are many entry points into the simulation used to answer different questions.
Examples incude:
 - `dart bin/duel.dart -v examples/duel.yaml` -- Used for testing groups of champs/mobs/items against one another.
 - `dart bin/round_robin.dart` -- Used for testing all champ pairs against one another.

There are several other dart files in bin/, most of them are for testing.

## Limitations
Many.  Including at least:
 - Chamion/Item/Mastery/Rune lookups are case sensitive and expect names in Title Case.
 - Incomplete support for Runes and Masteries.
 - Very limited item support.
 - No support for abilities.
 - Limited support for Buffs.
 - Buffs (like spiked shell) use base stats instead of total.
 - No support for on-hit effects.
 - No CC.
 - No AOE or support for location or proximity.
 - No monsters.

Mostly what the simulation supports is having groups of champs/mobs auto-attack until death.

## TODO
- Split out dragon.dart into package:data_dragon instead of lol_duel.
- Split lolsim.dart into smaller files.
- Add more passives, abilities, masteries, runes, etc.
- Confirm that Jax passive is working (didn't move him in rankings).

## Abilities missing affecting the lvl 1 round_robin sort.
- Aatrox passive and bloodthirst
- Akali passive
- Alistar Trample
- Amumu Tantrum
- Braum passive
- Diana passive
- Ekko passive
- Fizz passive
- Graves AA modifier and passive.
- Ivern brushmaker(w) passive
- Jarvan passive (small effect)
- Jinx Q passive
- Kayle passive
- Kled passive
- Malphite passive (small effect)
- Master Yi Double Strike passive.
- Nautalis passive
- Nocturn Passive
- Oriana Clockwork Winding
- Pantheon passive
- Rammus ball curl
- Singed (small effect)
- Tahm Kench passive
- Taric passive + ability
- Teemo E passive
- Urgot passive
- Vayne W passive
- Volibear Frenzy
- Wukong passive (small effect)
- Xin Zhao passive (small effect)
- Zed passive

## Questions to answer:
- Jungle clear-time approximations.
- Amumu Dispair or Tantrum first?
