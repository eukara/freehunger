# FreeHunger (AKA Still Hungry)
Clean-room reimplementation of They Hunger in entityDef / QuakeC.

![Preview 1](img/preview1.jpg)
![Preview 2](img/preview2.jpg)
![Preview 3](img/preview3.jpg)
![Preview 4](img/preview4.jpg)

## Building / Installation

Since this mod is entirely entityDef, no compiling is necessary! Just make sure
you have FreeHL installed, and place this content into your `hunger` folder.

## Status / Changes

So far all the weapons are re-implemented, and all custom NPCs are spawning.

Currently a decent amount of unique NPC behavior/effects are missing at the moment.

Some changes:

- Changed weapon placement for THDM
  Included are .ent files that have changed the weapons placed in the default
  DM maps for They Hunger. Replacing most Half-Life weapons with TH counter-parts.

- All medkit pickups turn into the medkit weapon in DM, and each pickup is one
  ammo (or shot) that needs to be administered for health. Can be turned off in
  `scripts/maptweaks.cfg`

- Shovel has enhanced visual first person effects, and slowed down buff'd attack.

- Wrench has lower hit points and slightly new sounds.

- Recreated the cut Chainsaw weapon.

- Removes the homing secondary toggle for the RPG similar to the actual
  historic weapon.

## Community

### Matrix
If you're a fellow Matrix user, join the Nuclide Space to see live-updates and more!
https://matrix.to/#/#nuclide:matrix.org

### IRC
Join us on #freecs via irc.libera.chat and talk/lurk or discuss bugs, issues
and other such things. It's bridged with the Matrix room of the same name!

### Others
We've had people ask in the oddest of places for help, please don't do that.

## License
ISC License

Copyright (c) 2016-2025 Marco Cawthorne <marco@icculus.org>

Copyright (c) 2019-2025 Gethyn ThomasQuail <gethyn@vera-visions.com>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
