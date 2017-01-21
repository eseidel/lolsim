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
 - No CC.
 - No AOE or support for location or proximity.
 - No monsters.

Mostly what the simulation supports is having groups of champs/mobs auto-attack until death.

## TODO
- Fix stat-relative buffs to include all stats (not just base).
- Percent armor mods (for xin and kayle).
- Split out dragon.dart into package:data_dragon instead of lol_duel.
- Split lolsim.dart into smaller files.
- Add more passives, abilities, masteries, runes, etc.
- Convert to integer math (ticks, etc.) to avoid double precision errors.
- Implement in-combat/out-of-combat (more champs would die to darius and twitch dots).
- Make round_robin spit out json and be able to compare lists.

## Passives missing affecting the lvl 1 round_robin sort.
- Aatrox passive (complicated, likely requires bloodthirst to be useful)
- Akali passive (CDR interaction? Second hit on a static 4s cooldown?)
- Ashe passive (semi-complicated crit replacement) and Q
- Braum passive (needs stuns)
- Diana passive (how do stacks work? do they fall off?)
- Ekko passive (when does the per-target cooldown start?)
- Fizz passive (unclear how to implement this kind of dmg reduction)
- Graves AA modifier and passive (sounds hard to implement)
- Gangplank passive (small effect, needs bonus ad split)
- Kayle passive (needs percent armor mod)
- Kled passive (non-trivial to implement, needs non-targetable)
- Malphite passive (needs shields)
- Master Yi Double Strike passive (non-trivial, same as shivana twin bite)
- Nautalis passive (needs stun)
- Nocturn passive (aoe, unclear how best to do dmg-modified autos)
- Pantheon passive (needs blocked)
- Taric passive (needs an ability to be useful)
- Wukong passive (needs proximity)
- Xin Zhao passive (needs percent armor mod)

## Abilities affecting round_robin
- Alistar Trample (needs stuns)
- Amumu Tantrum
- Ivern W brushmaker passive
- Jinx Q passive
- Rammus ball curl
- Teemo E passive
- Tryndamere Q passive
- Vayne W passive
- Volibear W Frenzy

## Questions to answer:
- Jungle clear-time approximations.
- Amumu Dispair or Tantrum first?
