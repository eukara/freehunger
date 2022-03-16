/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

void
Game_Input(player pl)
{
#ifdef SERVER
	CGameRules rules = (CGameRules)g_grMode;

	if (rules.m_iIntermission) {
		rules.IntermissionEnd();
		return;
	}

	if (input_buttons & INPUT_BUTTON5)
		Player_UseDown(); 
	else
		Player_UseUp();

	if (pl.impulse == 100)
		Flashlight_Toggle();

	if (cvar("sv_cheats") == 1) {
		if (pl.impulse == 101) {
			pl.health = 100;
			pl.armor = 100;
			pl.g_items |= ITEM_SUIT;
			Weapons_AddItem(pl, WEAPON_CROWBAR, -1);
			Weapons_AddItem(pl, WEAPON_SHOVEL, -1);
			Weapons_AddItem(pl, WEAPON_SPANNER, -1);
			Weapons_AddItem(pl, WEAPON_GLOCK, -1);
			Weapons_AddItem(pl, WEAPON_PYTHON, -1);
			Weapons_AddItem(pl, WEAPON_AP9, -1);
			Weapons_AddItem(pl, WEAPON_TAURUS, -1);
			Weapons_AddItem(pl, WEAPON_MP5, -1);
			Weapons_AddItem(pl, WEAPON_SHOTGUN, -1);
			Weapons_AddItem(pl, WEAPON_CROSSBOW, -1);
			Weapons_AddItem(pl, WEAPON_SNIPER, -1);
			Weapons_AddItem(pl, WEAPON_SNIPER2, -1);
			Weapons_AddItem(pl, WEAPON_RPG, -1);
			Weapons_AddItem(pl, WEAPON_GAUSS, -1);
			Weapons_AddItem(pl, WEAPON_EGON, -1);
			Weapons_AddItem(pl, WEAPON_CHAINGUN, -1);
			Weapons_AddItem(pl, WEAPON_HANDGRENADE, -1);
			Weapons_AddItem(pl, WEAPON_SATCHEL, -1);
			Weapons_AddItem(pl, WEAPON_TRIPMINE, -1);
			Weapons_AddItem(pl, WEAPON_SNARK, -1);
			Weapons_AddItem(pl, WEAPON_MEDKIT, -1);
		}
	}

	pl.impulse = 0;
#endif

	if (input_buttons & INPUT_BUTTON0)
		Weapons_Primary(pl);
	else if (input_buttons & INPUT_BUTTON4)
		Weapons_Reload(pl);
	else if (input_buttons & INPUT_BUTTON3)
		Weapons_Secondary(pl);
	else
		Weapons_Release(pl);
}
