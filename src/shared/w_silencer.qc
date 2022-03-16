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
	GLOCK_IDLE1,
	GLOCK_IDLE2,
	GLOCK_IDLE3,
	GLOCK_SHOOT,
	GLOCK_SHOOT_EMPTY,
	GLOCK_RELOAD_EMPTY,
	GLOCK_RELOAD,
	GLOCK_DRAW,
	GLOCK_HOLSTER,
	GLOCK_SILENCER
};

void
w_silencer_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_glock.fire");
	Sound_Precache("weapon_silencer.fire");
#endif
	precache_model("models/v_9mmhandgun.mdl");
	precache_model("models/w_9mmhandgun.mdl");
	precache_model("models/p_9mmhandgun.mdl");
	Sound_Precache("modelevent_shell.land");
}

void
w_silencer_updateammo(player pl)
{
	w_glock_updateammo(pl);
}

string
w_silencer_wmodel(void)
{
	return "models/w_silencer.mdl";
}

string
w_silencer_pmodel(player pl)
{
	return w_glock_pmodel(pl);
}

string
w_silencer_deathmsg(void)
{
	return "%s was silenced by %s's Beretta.";
}

int
w_silencer_pickup(player pl, int new, int startammo)
{
	return w_glock_pickup(pl, new, startammo);
}

void
w_silencer_draw(player pl)
{
	w_glock_draw(pl);

#ifdef CLIENT
	if (pl.mode_silencer) {
		Weapons_SetGeomset("geomset 2 2\n");
	} else {
		Weapons_SetGeomset("geomset 2 0\n");
	}
#endif
}
void
w_silencer_holster(player pl)
{
	w_glock_holster(pl);
}

void
w_silencer_primary(player pl)
{

	if (pl.w_attack_next > 0.0)
		return;

	/* ammo check */
	if (!pl.glock_mag)
		return;

	pl.glock_mag--;

	/* actual firing */
	Weapons_ViewPunchAngle(pl, [-2,0,0]);

	if (pl.glock_mag) {
		Weapons_ViewAnimation(pl, GLOCK_SHOOT);
	} else {
		Weapons_ViewAnimation(pl, GLOCK_SHOOT_EMPTY);
	}

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTop(pl, ANIM_SHOOT1HAND, 0.45f);
	else
		Animation_PlayerTop(pl, ANIM_CR_SHOOT1HAND, 0.45f);

#ifdef CLIENT
	View_AddEvent(w_glock_ejectshell, 0.0f);
	if (pl.mode_silencer == 1) {
		View_SetMuzzleflash(0);
	} else {
		View_SetMuzzleflash(MUZZLE_SMALL);
	}
#else
	/* Different sound & accuracy without silencer */
	if (pl.mode_silencer == 1) {
		TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, Skill_GetValue("plr_9mm_bullet", 8), [0.01, 0.01], WEAPON_GLOCK);
		Sound_Play(pl, CHAN_WEAPON, "weapon_silencer.fire");

	} else {
		TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, Skill_GetValue("plr_9mm_bullet", 8),  [0.1,0.1], WEAPON_GLOCK);
		Sound_Play(pl, CHAN_WEAPON, "weapon_glock.fire");
	}
#endif

	/* Fires faster without silencer */
	if (pl.mode_silencer == 1) {
		pl.w_attack_next = 0.3f;
	} else {
		pl.w_attack_next = 0.2f;
	}

	pl.w_idle_next = 5.0f;
}

#ifdef CLIENT

void
w_silencer_add(void)
{
	Weapons_SetGeomset("geomset 2 2\n");
}

void
w_silencer_remove(void)
{
	Weapons_SetGeomset("geomset 2 0\n");
}

#endif


void
w_silencer_secondary(player pl)
{

	if (pl.w_attack_next > 0)
		return;

	/* toggle silencer */
	pl.mode_silencer = 1 - pl.mode_silencer;

	if (pl.mode_silencer) {
		pl.w_attack_next = 3.3f;
		pl.w_idle_next = pl.w_attack_next;
		Weapons_ViewAnimation(pl, GLOCK_SILENCER);
		#ifdef CLIENT
		View_AddEvent(w_silencer_add, 1.0f);
		#endif
	} else {
		pl.w_attack_next = 2.0f;
		pl.w_idle_next = 1.0f;
		Weapons_ViewAnimation(pl, GLOCK_HOLSTER);
		pl.mode_tempstate = 1;
		#ifdef CLIENT
		View_AddEvent(w_silencer_remove, 0.9f);
		#endif
	}
}

void
w_silencer_reload(player pl)
{
	w_glock_reload(pl);
}

void
w_silencer_release(player pl)
{
	int r;

	/* auto-reload if need be */
	if (pl.w_attack_next <= 0.0)
	if (pl.glock_mag == 0 && pl.ammo_9mm > 0) {
		Weapons_Reload(pl);
		return;
	}

	if (pl.w_idle_next > 0.0) {
		return;
	}

	if (pl.mode_tempstate == 1)
	{
		Weapons_ViewAnimation(pl, GLOCK_DRAW);
		pl.w_idle_next = 1.0f;
		pl.w_attack_next = pl.w_idle_next;
		pl.mode_tempstate = 0;
		return;
	}

	r = floor(pseudorandom() * 3.0f);
	switch (r) {
	case 1:
		Weapons_ViewAnimation(pl, GLOCK_IDLE2);
		pl.w_idle_next = 2.5f;
		break;
	case 2:
		Weapons_ViewAnimation(pl, GLOCK_IDLE3);
		pl.w_idle_next = 3.5f;
		break;
	default:
		Weapons_ViewAnimation(pl, GLOCK_IDLE1);
		pl.w_idle_next = 3.75f;
		break;
	}
}

float
w_silencer_aimanim(player pl)
{
	return w_glock_aimanim(pl);
}

void
w_silencer_hud(player pl)
{
	w_glock_hud(pl);
}

void
w_silencer_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	vector hud_col;

	if (pl.glock_mag == 0 && pl.ammo_9mm == 0)
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	HUD_DrawAmmoBar(pos, pl.ammo_9mm, MAX_A_9MM, a);

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/tfchud05.spr_0.tga",
			[0,135/256],
			[170/256,45/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			"sprites/tfchud06.spr_0.tga",
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
w_silencer_isempty(player pl)
{

	if (pl.glock_mag <= 0 && pl.ammo_9mm <= 0)
		return 1;

	return 0;
}

weapontype_t
w_silencer_type(player pl)
{
	return WPNTYPE_RANGED;
}

weapon_t w_silencer =
{
	.name		= "silencer",
	.id			= ITEM_GLOCK,
	.slot		= 1,
	.slot_pos	= 0,
	.weight		= WEIGHT_GLOCK,
	.draw		= w_silencer_draw,
	.holster	= w_silencer_holster,
	.primary	= w_silencer_primary,
	.secondary	= w_silencer_secondary,
	.reload		= w_silencer_reload,
	.release	= w_silencer_release,
	.postdraw	= w_silencer_hud,
	.precache	= w_silencer_precache,
	.pickup		= w_silencer_pickup,
	.updateammo	= w_silencer_updateammo,
	.wmodel		= w_silencer_wmodel,
	.pmodel		= w_silencer_pmodel,
	.deathmsg	= w_silencer_deathmsg,
	.aimanim	= w_silencer_aimanim,
	.isempty	= w_silencer_isempty,
	.type		= w_silencer_type,
	.hudpic		= w_silencer_hudpic
};
