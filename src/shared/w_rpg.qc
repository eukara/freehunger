/*
 * Copyright (c) 2016-2021 Marco Cawthorne <marco@icculus.org>
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

/*QUAKED weapon_rpg (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_rpg.mdl"

HALF-LIFE (1998) ENTITY

RPG Weapon

*/

enum
{
	RPG_IDLE,
	RPG_FIDGET,
	RPG_RELOAD,
	RPG_FIRE2,
	RPG_HOLSTER1,
	RPG_DRAW1,
	RPG_HOLSTER2,
	RPG_DRAW_UL,
	RPG_IDLE_UL,
	RPG_FIDGET_UL,
};

void
w_rpg2_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_rpg.shoot");
	precache_model("models/w_rpg.mdl");
	precache_model("models/rpgrocket.mdl");
#else
	precache_model("models/v_rpg.mdl");
	precache_model("models/p_rpg.mdl");
	precache_model("sprites/laserdot.spr");
#endif
}

void
w_rpg2_updateammo(player pl)
{
	w_rpg_updateammo(pl);
}

string
w_rpg2_wmodel(void)
{
	return w_rpg_wmodel();
}

string
w_rpg2_pmodel(player pl)
{
	return w_rpg_pmodel(pl);
}

string
w_rpg2_deathmsg(void)
{
	return w_rpg_deathmsg();
}

int
w_rpg2_pickup(player pl, int new, int startammo)
{
	return w_rpg_pickup(pl, new, startammo);
}

void
w_rpg2_draw(player pl)
{
	w_rpg_draw(pl);
}

void
w_rpg2_holster(player pl)
{
	
}

void
w_rpg2_primary(player pl)
{
	w_rpg_primary(pl);
}

void
w_rpg2_reload(player pl)
{
	w_rpg_reload(pl);
}

void
w_rpg2_release(player pl)
{
	w_rpg_release(pl);
}

void
w_rpg2_secondary(player pl)
{

	/* Another change to spice things up */
	if (serverkeyfloat("th_rpgstyle") != 1) {

		if (pl.w_attack_next > 0.0) {
			return;
		}

		/* toggle laser */
		pl.ammo_rpg_state = 1 - pl.ammo_rpg_state;

		pl.w_attack_next = 0.25f;
		w_rpg2_release(pl);
	}
}

float
w_rpg2_aimanim(player pl)
{
	return w_rpg_aimanim(pl);
}

void
w_rpg2_hudpic(player pl, int selected, vector pos, float a)
{
	w_rpg_hudpic(pl, selected, pos, a);
}

void
w_rpg2_hud(player pl)
{
	w_rpg_hud(pl);
}

int
w_rpg2_isempty(player pl)
{
	return w_rpg_isempty(pl);
}

weapontype_t
w_rpg2_type(player pl)
{
	return w_rpg_type(pl);
}

weapon_t w_rpg2 =
{
	.name		= "rpg_rocket",
	.id			= ITEM_RPG,
	.slot		= 3,
	.slot_pos	= 0,
	.weight		= WEIGHT_RPG,
	.draw		= w_rpg2_draw,
	.holster	= w_rpg2_holster,
	.primary	= w_rpg2_primary,
	.secondary	= w_rpg2_secondary,
	.reload		= w_rpg2_reload,
	.release	= w_rpg2_release,
	.postdraw	= w_rpg2_hud,
	.precache	= w_rpg2_precache,
	.pickup		= w_rpg2_pickup,
	.updateammo	= w_rpg2_updateammo,
	.wmodel		= w_rpg2_wmodel,
	.pmodel		= w_rpg2_pmodel,
	.deathmsg	= w_rpg2_deathmsg,
	.aimanim	= w_rpg2_aimanim,
	.isempty	= w_snark_isempty,
	.type		= w_snark_type,
	.hudpic		= w_rpg2_hudpic
};
