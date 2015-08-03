# lolsim
Implementation of League of Legends' rules engine.

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
`pub run lolsim:duel Renekton Yasuo`

`pub run lolsim:duel Annie "Xin Zhao"`

## Limitations
Many.  Including at least:
 - Champion lookup is case sensitive and expects names in Title Case.
 - No support for Runes, Masteries, Levels or Items.
 - No support for buffs.
 - No support for healing.
The only thing the simulation can do so far is auto-attack until death.
