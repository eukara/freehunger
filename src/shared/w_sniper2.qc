/*
 * Copyright (c) 2016-2021 Marco Cawthorne <marco@icculus.org>
 * Copyright (c) 2019-2020 Gethyn ThomasQuail <xylemon@posteo.net>
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

enum
{
	SNIPER_IDLE,
	SNIPER_RELOAD,
	SNIPER_DRAW,
	SNIPER_FIRE
};

void
w_sniper2_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_sniper.fire");
#endif
	precache_model("models/v_hkg36.mdl");
	precache_model("models/w_hkg36.mdl");
	precache_model("models/p_hkg36.mdl");
}

int
w_sniper2_pickup(player pl, int new, int startammo)
{
	return w_sniper_pickup(pl, new, startammo);
}

void
w_sniper2_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.sniper_mag, pl.ammo_sniper, -1);
}

string
w_sniper2_wmodel(void)
{
	return "models/w_hkg36.mdl";
}

string
w_sniper2_pmodel(player pl)
{
	return "models/p_hkg36.mdl";
}

string
w_sniper2_deathmsg(void)
{
	return "%s was taken out by %s's Sniper.";
}

void
w_sniper2_draw(player pl)
{
	Weapons_SetModel("models/v_hkg36.mdl");
	Weapons_ViewAnimation(pl, SNIPER_DRAW);
}

void
w_sniper2_holster(player pl)
{
}

void
w_sniper2_release(player pl)
{

	/* auto-reload if need be */
	if (pl.w_attack_next <= 0.0)
	if (pl.sniper_mag == 0 && pl.ammo_sniper > 0) {
		Weapons_Reload(pl);
		return;
	}

	if (pl.w_idle_next > 0.0)
		return;

	int r = floor(random(0,2));
	switch (r) {
	case 0:
		Weapons_ViewAnimation(pl, SNIPER_IDLE1);
		pl.w_idle_next = 3.0f;
		break;
	case 1:
		Weapons_ViewAnimation(pl, SNIPER_IDLE2);
		pl.w_idle_next = 2.0f;
		break;
	}

	pl.w_idle_next = 15.0f;
}

void
w_sniper2_primary(player pl)
{

	if (pl.w_attack_next > 0.0)
		return;

	/* Ammo check */
	if (pl.sniper_mag <= 0)
		return;

	pl.sniper_mag--;

	Weapons_ViewPunchAngle(pl, [-20,0,0]);
	Weapons_ViewAnimation(pl, SNIPER_FIRE);

#ifdef CLIENT
	View_AddEvent(w_pistol_ejectshell, 0.0f);
	View_SetMuzzleflash(MUZZLE_SMALL);
#else
	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 40, [0.008, 0.008], WEAPON_SNIPER);
	Sound_Play(pl, CHAN_WEAPON, "weapon_sniper.fire");
#endif

	/* Simple toggle of fovs */
	if (pl.viewzoom == 1.0f) {
		pl.w_attack_next = 0.1f;
	} else {
		pl.w_attack_next = 1.0f;
	}

	pl.w_idle_next = 10.0f;
}

void
w_sniper2_secondary(player pl)
{
	w_sniper_secondary(pl);
}

void
w_sniper2_reload(player pl)
{

	if (pl.w_attack_next > 0.0)
		return;
	if (pl.sniper_mag >= 5)
		return;
	if (pl.ammo_sniper <= 0)
		return;

	Weapons_ViewAnimation(pl, SNIPER_RELOAD);

#ifdef SERVER
	Weapons_ReloadWeapon(pl, player::sniper_mag, player::ammo_sniper, 5);
#endif

	pl.w_attack_next = 3.82f;
	pl.w_idle_next = 5.0f;
}

void
w_sniper2_crosshair(player pl)
{
#ifdef CLIENT
	w_sniper_crosshair(pl);
#endif
}

float
w_sniper2_aimanim(player pl)
{
	return w_crossbow_aimanim(pl);
}

void
w_sniper2_hudpic(player pl, int selected, vector pos, float a)
{
	w_sniper_hudpic(pl, selected, pos, a);
}

int
w_sniper2_isempty(player pl)
{
	return w_sniper_isempty(pl);
}

weapontype_t
w_sniper2_type(player pl)
{
	return WPNTYPE_RANGED;
}

weapon_t w_sniper2 =
{
	.name		= "sniper2",
	.id			= ITEM_SNIPER2,
	.slot		= 2,
	.slot_pos	= 4,
	.weight		= WEIGHT_SNIPER2,
	.draw		= w_sniper2_draw,
	.holster	= w_sniper2_holster,
	.primary	= w_sniper2_primary,
	.secondary	= w_sniper2_secondary,
	.reload		= w_sniper2_reload,
	.release	= w_sniper2_release,
	.postdraw	= w_sniper2_crosshair,
	.precache	= w_sniper2_precache,
	.pickup		= w_sniper2_pickup,
	.updateammo	= w_sniper2_updateammo,
	.wmodel		= w_sniper2_wmodel,
	.pmodel		= w_sniper2_pmodel,
	.deathmsg	= w_sniper2_deathmsg,
	.aimanim	= w_sniper2_aimanim,
	.isempty	= w_sniper2_isempty,
	.type		= w_sniper2_type,
	.hudpic		= w_sniper2_hudpic
};

/* pickups */
#ifdef SERVER
void
weapon_th_sniper(void)
{
	Weapons_InitItem(WEAPON_SNIPER2);
}
#endif
