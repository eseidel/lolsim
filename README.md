lolsim
======

[![Build Status -](https://travis-ci.org/eseidel/lolsim.svg?branch=master)](https://travis-ci.org/eseidel/lolsim)

Toy implementation of League of Legends' combat engine.

Current patch: 7.10.1.

My goal here is to familiarize myself with the finer details of LOL's rules as
well as have a chance to play around with Dart.

It's difficult to imagine this ever being perfect simulation, in part because
Riot does not make all of their rule values public (e.g. attack-windup,
ability-durations, etc.) but also because keeping up with LOL would be a huge
task.

## Setup
Need a copy of [Dart](https://www.dartlang.org/install).
Run `dart bin/precache_dragondata.dart` to download the necessary files from [Riot's static data](https://developer.riotgames.com/docs/static-data).

## Usage
There are many entry points into the simulation used to answer different questions.
Examples incude:
 - `dart bin/duel.dart -v examples/duel.yaml` -- Used for testing groups of champs/mobs/items against one another.
 - `dart bin/round_robin.dart` -- Used for testing all champ pairs against one another.
 - `dart bin/dps.dart` -- Show various champs ranked by lvl 1 dps.
 - `dart bin/burst.dart` -- Show various champs ranked by lvl 3 burst.

There are several other dart files in bin/, most of them are for testing.

## Limitations
Many.  Including at least:
 - Chamion/Item/Mastery/Rune lookups are case sensitive and expect names in Title Case.
 - Incomplete (and partially outdated) support for Runes and Masteries.
 - Very limited item support.
 - Very limited abilities support.
 - Limited support for Buffs.
 - No CC.
 - No AOE or support for location or proximity.
 - No monsters.

## Questions to answer:
- Jungle clear-time approximations.
- Amumu Dispair or Tantrum first?
- Range catagories for each stats (high, med, low)
- Guestimate as to power ranges of various champs
- When are various items (liandries, BOTRK, etc.) worth it?
- How Burst scales?
- DPS and burst for each champ.

## TODO / Bugs
- Figure out how to do ability passives.
- Handle stat modifying buffs first, before other buffs.
- pub run test dies w/o message when no precache.
- Coverage & coveralls.io
- Split lolsim.dart into smaller files.
- Add more passives, abilities, masteries, runes, etc.
- Convert to integer math (ticks, etc.) to avoid double precision errors.
- Implement in-combat/out-of-combat (more champs would die to darius and twitch dots).
- Use round_robin json to compare lists.
- Auto-attack windup.
- Missle system & proximity.
- Neutral teams logic (do not attack until attacked).

## Passives missing affecting the lvl 1 round_robin sort.
- Aatrox passive (complicated, likely requires bloodthirst to be useful)
- Akali passive (CDR interaction? Second hit on a static 4s cooldown?)
- Ashe passive (semi-complicated crit replacement) and Q
- Blitzcrank passive (needs mana and shields)
- Braum passive (needs stuns)
- Caitlyn passive (crit modifier)
- Camille passive (requires shields)
- Elise passive (ai to really use it)
- Fizz passive (unclear how to implement this kind of dmg reduction)
- Graves AA modifier and passive (impactful, hard to implement)
- Gangplank passive (small effect, needs bonus ad split)
- Kayle passive (needs percent armor mod)
- Kha'Zix passive (on-hit, small effect, with abilities bigger)
- Kled passive (very complicated, needs non-targetable)
- Malphite passive (needs shields)
- Miss Fortune passive (on hit, small effect)
- Nautalis passive (needs stun)
- Nocturn passive (aoe, unclear how best to do dmg-modified autos)
- Pantheon passive (needs blocked)
- Taric passive (needs an ability to be useful)
- Wukong passive (needs proximity)
- Sejuani passive (easy)

Plan for stuns?
- Stuns should cancel AA windups, but not AA missiles?
- Stuns prevent new AA windups during duration.

## Abilities affecting round_robin
- Alistar Trample (needs stuns)
- Amumu Tantrum
- Ivern W brushmaker passive
- Jinx Q passive
- Rammus ball curl
- Teemo E passive
- Tryndamere Q passive
- Udyr all of his abilities
- Vayne W passive
- Volibear W Frenzy

## Potential champion.gg integrations
- Common Roles
- Common masteries
- Common skill orders.

## Disclaimer
This isn't endorsed by Riot Games and doesn't reflect the views
or opinions of Riot Games or anyone officially involved in producing
or managing League of Legends. League of Legends and Riot Games are
trademarks or registered trademarks of Riot Games, Inc. League of
Legends © Riot Games, Inc.
