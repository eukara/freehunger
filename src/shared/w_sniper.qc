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
	SNIPER_IDLE1,
	SNIPER_UNUSED1,
	SNIPER_FIRE1,
	SNIPER_DRAW,
	SNIPER_HOLSTER,
	SNIPER_IDLE2
};

void
w_sniper_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_sniper.fire");
	Sound_Precache("weapon_sniper.reload");
#endif
	precache_model("models/v_tfc_sniper.mdl");
	precache_model("models/w_isotopebox.mdl");
	precache_model("models/p_sniper.mdl");
}

int
w_sniper_pickup(player pl, int new, int startammo)
{
#ifdef SERVER

	if (new) {
		pl.sniper_mag = 5;
		return (1);
	}

	if (pl.ammo_sniper < MAX_A_SNIPER) {
		pl.ammo_sniper = bound(0, pl.ammo_sniper + 5, MAX_A_SNIPER);
	} else {
		if (!new)
			return (0);
	}
#endif
	return (1);
}

void
w_sniper_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.sniper_mag, pl.ammo_sniper, -1);
}

string
w_sniper_wmodel(void)
{
	return "models/w_isotopebox.mdl";
}

string
w_sniper_pmodel(player pl)
{
	return "models/p_sniper.mdl";
}

string
w_sniper_deathmsg(void)
{
	return "%s was taken out by %s's Sniper.";
}

void
w_sniper_draw(player pl)
{
	pl.mode_tempstate = 0;

	Weapons_SetModel("models/v_tfc_sniper.mdl");
	Weapons_ViewAnimation(pl, SNIPER_DRAW);
}

void
w_sniper_holster(player pl)
{
	Weapons_ViewAnimation(pl, SNIPER_HOLSTER);
}

void
w_sniper_release(player pl)
{

	/* auto-reload if need be */
	if (pl.w_attack_next <= 0.0)
	if (pl.sniper_mag == 0 && pl.ammo_sniper > 0) {
		Weapons_Reload(pl);
		return;
	}

	if (pl.w_idle_next > 0.0)
		return;

	if (pl.mode_tempstate == 1) {
		Weapons_ViewAnimation(pl, SNIPER_DRAW);
		pl.mode_tempstate = 0;
		pl.w_attack_next = 0.0f;
		pl.w_idle_next = 15.0f;
		return;
	}

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
w_sniper_primary(player pl)
{

	if (pl.w_attack_next > 0.0)
		return;

	/* Ammo check */
	if (pl.sniper_mag <= 0)
		return;

	pl.sniper_mag--;

	Weapons_ViewPunchAngle(pl, [-20,0,0]);
	Weapons_ViewAnimation(pl, SNIPER_FIRE1);

#ifdef CLIENT
	View_AddEvent(w_chaingun_ejectshell, 0.0f);
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
w_sniper_secondary(player pl)
{

	if (pl.w_attack_next > 0.0)
		return;

	/* Simple toggle of fovs */
	if (pl.viewzoom == 1.0f) {
		pl.viewzoom = 0.25f;
	} else {
		pl.viewzoom = 1.0f;
	}

	pl.w_attack_next = 0.5f;
}

void
w_sniper_reload(player pl)
{
	if (pl.w_attack_next) {
		w_sniper_release(pl);
		return;
	}
	if (pl.sniper_mag >= 5)
		return;
	if (pl.ammo_sniper <= 0)
		return;

	Weapons_ViewAnimation(pl, SNIPER_HOLSTER);

#ifdef SERVER
	Sound_Play(pl, CHAN_WEAPON, "weapon_sniper.reload");
	Weapons_ReloadWeapon(pl, player::sniper_mag, player::ammo_sniper, 5);
#endif

	pl.mode_tempstate = 1;
	pl.w_attack_next = 2.5f;
	pl.w_idle_next = 2.0f;
}

void
w_sniper_crosshair(player pl)
{
#ifdef CLIENT
	static vector cross_pos;
	vector aicon_pos;

	if (pl.viewzoom < 1.0f) {
		vector col;

		// although no accurate, gives the second sniper more character
		if (pl.activeweapon == WEAPON_SNIPER)
			col = [0,0.2,0];
		else
			col = [0.2,0,0];

		drawfill(
			video_mins,
			video_res,
			col,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
		cross_pos = g_hudmins + (g_hudres / 2) + [-128,-104];
		drawpic(
			cross_pos,
			"sprites/nmxhair2.spr_0.tga",
			[256,208],
			[1,1,1],
			1.0f,
			DRAWFLAG_NORMAL
		);
	} else {

		cross_pos = g_hudmins + (g_hudres / 2) + [-12,-12];
		drawsubpic(
			cross_pos,
			[24,24],
			"sprites/crosshairs.spr_0.tga",
			[48/128,0],
			[24/128,24/128],
			[1,1,1],
			1.0f,
			DRAWFLAG_NORMAL
		);
	}

	HUD_DrawAmmo1();
	HUD_DrawAmmo2();

	aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(
		aicon_pos,
		[24,24],
		"sprites/640hud7.spr_0.tga",
		[24/256,72/128],
		[24/256, 24/128],
		g_hud_color,
		pSeatLocal->m_flAmmo2Alpha,
		DRAWFLAG_ADDITIVE
	);
#endif
}

float
w_sniper_aimanim(player pl)
{
	return w_crossbow_aimanim(pl);
}

void
w_sniper_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	vector hud_col;

	if (pl.sniper_mag == 0 && pl.ammo_sniper == 0)
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	HUD_DrawAmmoBar(pos, pl.ammo_sniper, MAX_A_SNIPER, a);

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/tfchud02.spr_0.tga",
			[0,45/256],
			[170/256,45/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			"sprites/tfchud01.spr_0.tga",
			[0,45/256],
			[170/256,45/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

int
w_sniper_isempty(player pl)
{

	if (pl.sniper_mag <= 0 && pl.ammo_sniper <= 0)
		return 1;

	return 0;
}

weapontype_t
w_sniper_type(player pl)
{
	return WPNTYPE_RANGED;
}

weapon_t w_sniper =
{
	.name		= "sniper",
	.id			= ITEM_SNIPER,
	.slot		= 2,
	.slot_pos	= 3,
	.weight		= WEIGHT_SNIPER,
	.draw		= w_sniper_draw,
	.holster	= w_sniper_holster,
	.primary	= w_sniper_primary,
	.secondary	= w_sniper_secondary,
	.reload		= w_sniper_reload,
	.release	= w_sniper_release,
	.postdraw	= w_sniper_crosshair,
	.precache	= w_sniper_precache,
	.pickup		= w_sniper_pickup,
	.updateammo	= w_sniper_updateammo,
	.wmodel		= w_sniper_wmodel,
	.pmodel		= w_sniper_pmodel,
	.deathmsg	= w_sniper_deathmsg,
	.aimanim	= w_sniper_aimanim,
	.isempty	= w_sniper_isempty,
	.type		= w_sniper_type,
	.hudpic		= w_sniper_hudpic
};

/* pickups */
#ifdef SERVER
void
weapon_einar1(void)
{
	Weapons_InitItem(WEAPON_SNIPER);
}
#endif
