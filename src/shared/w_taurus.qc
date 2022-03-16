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
	TAURUS_IDLE1,
	TAURUS_IDLE2,
	TAURUS_IDLE3,
	TAURUS_SHOOT,
	TAURUS_SHOOT2,
	TAURUS_SHOOT3,
	TAURUS_SHOOT_EMPTY,
	TAURUS_RELOAD,
	TAURUS_RELOAD2,
	TAURUS_DRAW,
	TAURUS_HOLSTER
};

void
w_taurus_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_taurus.fire");
#endif
	precache_model("models/v_taurus.mdl");
	precache_model("models/w_taurus.mdl");
	precache_model("models/p_taurus.mdl");
}

void
w_taurus_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.taurus_mag, pl.ammo_taurus, -1);
}

string
w_taurus_wmodel(void)
{
	return "models/w_taurus.mdl";
}

string
w_taurus_pmodel(player pl)
{
	return "models/p_taurus.mdl";
}

string
w_taurus_deathmsg(void)
{
	return "%s is seeing blue from %s's Taurus.";
}

int
w_taurus_pickup(player pl, int new, int startammo)
{
#ifdef SERVER

	if (new) {
		pl.taurus_mag = 10;
		return (1);
	}

	if (pl.ammo_taurus < MAX_A_TAURUS) {
		pl.ammo_taurus = bound(0, pl.ammo_taurus + 10, MAX_A_TAURUS);
	} else {
		if (!new)
			return (0);
	}
#endif
	return (1);
}

void
w_taurus_draw(player pl)
{
	Weapons_SetModel("models/v_taurus.mdl");
	Weapons_ViewAnimation(pl, TAURUS_DRAW);
}

void
w_taurus_holster(player pl)
{
	Weapons_ViewAnimation(pl, TAURUS_HOLSTER);
}

void
w_taurus_primary(player pl)
{

	if (pl.w_attack_next > 0.0)
		return;

	/* ammo check */
	if (!pl.taurus_mag)
		return;

	pl.taurus_mag--;

	Weapons_ViewPunchAngle(pl, [-2,0,0]);

	if (pl.taurus_mag) {
		Weapons_ViewAnimation(pl, TAURUS_SHOOT);
	} else {
		Weapons_ViewAnimation(pl, TAURUS_SHOOT_EMPTY);
	}

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTop(pl, ANIM_SHOOT1HAND, 0.45f);
	else
		Animation_PlayerTop(pl, ANIM_CR_SHOOT1HAND, 0.45f);

	/* actual firing */
#ifdef CLIENT
	View_AddEvent(w_pistol_ejectshell, 0.0f);
	View_SetMuzzleflash(MUZZLE_SMALL);
#else
	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 12, [0.01,0.01], WEAPON_TAURUS);
	Sound_Play(pl, CHAN_WEAPON, "weapon_taurus.fire");
#endif

	pl.w_attack_next = 0.25f;
	pl.w_idle_next = 5.0f;
}

void
w_taurus_secondary(player pl)
{

}

void
w_taurus_reload(player pl)
{

	if (pl.w_attack_next > 0.0)
		return;
	if (pl.taurus_mag >= 10)
		return;
	if (pl.ammo_taurus <= 0)
		return;

	if (pl.taurus_mag) {
		Weapons_ViewAnimation(pl, TAURUS_RELOAD);
	} else {
		Weapons_ViewAnimation(pl, TAURUS_RELOAD2);
	}

#ifdef SERVER
	Weapons_ReloadWeapon(pl, player::taurus_mag, player::ammo_taurus, 10);
#endif

	pl.w_attack_next = 2.0f;
	pl.w_idle_next = 10.0f;
}

void
w_taurus_release(player pl)
{
	int r;

	/* auto-reload if need be */
	if (pl.w_attack_next <= 0.0)
	if (pl.taurus_mag == 0 && pl.ammo_taurus > 0) {
		Weapons_Reload(pl);
		return;
	}

	if (pl.w_idle_next > 0.0)
		return;

	r = floor(random(0,3));
	switch (r) {
	case 1:
		Weapons_ViewAnimation(pl, TAURUS_IDLE2);
		pl.w_idle_next = 2.25f;
		break;
	case 2:
		Weapons_ViewAnimation(pl, TAURUS_IDLE3);
		pl.w_idle_next = 2.5f;
		break;
	default:
		Weapons_ViewAnimation(pl, TAURUS_IDLE1);
		pl.w_idle_next = 2.81f;
		break;
	}
}

float
w_taurus_aimanim(player pl)
{
	return w_glock_aimanim(pl);
}

void
w_taurus_hud(player pl)
{
	w_glock_hud(pl);
}

void
w_taurus_hudpic(player pl, int selected, vector pos, float a)
{
	w_glock_hudpic(pl, selected, pos, a);
}

int
w_taurus_isempty(player pl)
{

	if (pl.taurus_mag <= 0 && pl.ammo_taurus <= 0)
		return 1;

	return 0;
}

weapontype_t
w_taurus_type(player pl)
{
	return WPNTYPE_RANGED;
}

weapon_t w_taurus =
{
	.name		= "taurus",
	.id			= ITEM_TAURUS,
	.slot		= 1,
	.slot_pos	= 3,
	.weight		= WEIGHT_TAURUS,
	.draw		= w_taurus_draw,
	.holster	= w_taurus_holster,
	.primary	= w_taurus_primary,
	.secondary	= w_taurus_secondary,
	.reload		= w_taurus_reload,
	.release	= w_taurus_release,
	.postdraw	= w_taurus_hud,
	.precache	= w_taurus_precache,
	.pickup		= w_taurus_pickup,
	.updateammo	= w_taurus_updateammo,
	.wmodel		= w_taurus_wmodel,
	.pmodel		= w_taurus_pmodel,
	.deathmsg	= w_taurus_deathmsg,
	.aimanim	= w_taurus_aimanim,
	.isempty	= w_taurus_isempty,
	.type		= w_taurus_type,
	.hudpic		= w_taurus_hudpic
};


/* pickups */
#ifdef SERVER
void
weapon_th_taurus(void)
{
	Weapons_InitItem(WEAPON_TAURUS);
}
#endif
