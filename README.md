# Cooldowns

Track cooldowns of various sets and synergies.

<p align="center">
    <img src="https://github.com/inimicus/Cooldowns/blob/master/art/Cooldowns.png?raw=true"><br>
</p>

<p align="center">
    <img src="https://github.com/inimicus/Cooldowns/blob/master/art/Synergies.png?raw=true"><br>
</p>

## Purpose
Counting to five is hard enough. Counting to 30 is next to impossible. Counting
anything more than 30 requires powerful computers or elite console players to
be even remotely within the realm of possibility.

But fret no longer! There is an addon to count your long cooldowns for you.

## Features
- Only enables tracking/display when an included set is equipped or synergy is toggled on
- Reposition to any place on your screen
- Resize display from really small to comically large
- Optionally hide when out of combat
- Play sound on proc (enabled by default)
- Play sound when off cooldown (enabled by default)
- Includes around 100 different sounds to choose from

## Implemented Cooldowns
Sets:
- Caluurion's Legacy
- Crest of Cyrodiil
- Curse Eater
- Earthgore
- Icy Conjuror
- Magicka Furnace
- Mechanical Acuity - For more robust tracking, check out [Acuity by Wheels](https://www.esoui.com/downloads/info1950-Acuity.html)
- Ravager
- Shroud of the Lich
- Steadfast Hero
- Trappings of Invigoration
- Vestment of Olorime
- Vykosa
- Vestments of the Warlock
- Werewolf Hide
- Wyrd Tree's Blessing
- Zaan

Synergies:
- Blood Altar (Undaunted)
- Boner Shield (Undaunted)
- Conduit (Sorcerer)
- Harvest (Warden)
- Purify (Templar)
- Orbs/Shards (Undaunted/Templar)

## FAQ
_What about Alkosh?_

Alkosh's 5-item proc condition is "When you activate a synergy..." and, as such, here isn't a cooldown for Alkosh beyond those for activating synergies. Tracking cooldowns for synergies and using them at the right moment is your best bet at maximizing your Alkosh uptime. If you'd like to track the Alkosh debuff applied to targets, configure your buff/debuff tracker or check out Wheels' awesome [RaidBuffs](https://www.esoui.com/downloads/info1939-RaidBuffs.html) addon.

_What about Powerful Assault?_

Similar to Alkosh, the 5-item proc condition is "When you cast an Assault ability..." and has no cooldown in the traditional sense. Tracking your Powerful Assault uptime is better suited to a buff tracker as it will help you identify group members that have not yet received the buff.

_How hard would it be to add [this] set?_

Barring any special conditions not already accounted for in the code, it's not too difficult at all. The code to add and manage tracked sets and synergies (Data.lua) is very straight-forward, it's just a matter of testing and making sure everything works as intended. Testing new sets, now that the code has been established, is what takes the longest. So don't hesitate to reach out with anything you'd like to see included!

## Planned Updates / Known Issues
- Multilanguage support - Hard-coded values means Cooldowns doesn't work for non-English clients. This will be fixed in the future. Big thanks to Baertram for assisting with this.
- Menu Optimization - Loading the addon settings menu bogs down the system as it generates all of the options (and sounds). This will be streamlined and improved so that it loads instantly without taxing any system.

## Addtional Sets
If you'd like to see a specific set added, please let me know. I would prefer to
limit the sets to ones with long cooldowns and those not already covered by other
more well-done addons, but this is not a hard rule.

# Enjoy!
