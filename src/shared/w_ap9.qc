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
	AP9_IDLE,
	AP9_RELOAD,
	AP9_DRAW,
	AP9_SHOOT1,
	AP9_SHOOT2,
	AP9_SHOOT3
};

#ifdef CLIENT
void w_pistol_ejectshell(void)
{
	static void w_pistol_ejectshell_death(void) {
		remove(self);
	}
	static void w_pistol_ejectshell_touch(void) {
		if (other == world)
			Sound_Play(self, CHAN_BODY, "modelevent_shell.land");
	}
	entity eShell = spawn();
	setmodel(eShell, "models/shell.mdl");
	eShell.solid = SOLID_BBOX;
	eShell.movetype = MOVETYPE_BOUNCE;
	eShell.drawmask = MASK_ENGINE;
	eShell.angles = [pSeat->m_eViewModel.angles[0], pSeat->m_eViewModel.angles[1], 0];
	eShell.velocity = pSeat->m_vecPredictedVelocity;

	makevectors(pSeat->m_eViewModel.angles);
	eShell.velocity += (v_forward * 0);
	eShell.velocity += (v_right * -60);
	eShell.velocity += (v_up * 120);
	eShell.touch = w_pistol_ejectshell_touch;

	eShell.avelocity = [0,45,900];
	eShell.think = w_pistol_ejectshell_death;
	eShell.nextthink = time + 2.5f;
	setsize(eShell, [0,0,0], [0,0,0]);
	setorigin(eShell, pSeat->m_eViewModel.origin + (v_forward * 26) + (v_right * 10) + (v_up * -10));
}
#endif

void
w_ap9_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_ap9.fire");
	precache_model("models/w_ap9.mdl");
#else
	precache_model("models/v_ap9.mdl");
	precache_model("models/p_ap9.mdl");
	
#endif
}

void
w_ap9_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.ap9_mag, pl.ammo_ap9, -1);
}

string
w_ap9_wmodel(void)
{
	return "models/w_ap9.mdl";
}

string
w_ap9_pmodel(player pl)
{
	return "models/p_ap9.mdl";
}

string
w_ap9_deathmsg(void)
{
	return "%s was unloaded into from %s's AP9.";
}

int
w_ap9_pickup(player pl, int new, int startammo)
{
#ifdef SERVER

	if (new) {
		pl.ap9_mag = 40;
		return (1);
	}

	if (pl.ammo_ap9 < MAX_A_AP9) {
		pl.ammo_ap9 = bound(0, pl.ammo_ap9 + 40, MAX_A_AP9);
	} else {
		if (!new)
			return (0);
	}
#endif
	return (1);
}

void
w_ap9_draw(player pl)
{
	Weapons_SetModel("models/v_ap9.mdl");
	Weapons_ViewAnimation(pl, AP9_DRAW);
}

void
w_ap9_holster(player pl)
{

}

void
w_ap9_primary(player pl)
{

	if (pl.w_attack_next > 0.0)
		return;
	if (!pl.ap9_mag)
		return;

	pl.ap9_mag--;
	Weapons_ViewPunchAngle(pl, [-2,0,0]);

	int r = (float)input_sequence % 3;
	switch (r) {
	case 0:
		Weapons_ViewAnimation(pl, AP9_SHOOT1);
		break;
	case 1:
		Weapons_ViewAnimation(pl, AP9_SHOOT2);
		break;
	case 2:
		Weapons_ViewAnimation(pl, AP9_SHOOT3);
		break;
	}

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTop(pl, ANIM_SHOOT1HAND, 0.45f);
	else
		Animation_PlayerTop(pl, ANIM_CR_SHOOT1HAND, 0.45f);

#ifdef CLIENT
	View_AddEvent(w_pistol_ejectshell, 0.0f);
	View_SetMuzzleflash(MUZZLE_SMALL);
#else
	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 8, [0.1,0.1], WEAPON_AP9);
	Sound_Play(pl, CHAN_WEAPON, "weapon_ap9.fire");
#endif

	pl.w_attack_next = 0.15f;
	pl.w_idle_next = 5.0f;
}

void
w_ap9_secondary(player pl)
{

	if (pl.w_attack_next > 0)
		return;
	if ((pl.ap9_mag - 3) < 0)
		return;

	pl.ap9_mag -= 3;

	Weapons_ViewPunchAngle(pl, [-2,0,0]);

	int r = floor(random(0,2));
	switch (r) {
	case 0:
		Weapons_ViewAnimation(pl, AP9_SHOOT1);
		break;
	case 1:
		Weapons_ViewAnimation(pl, AP9_SHOOT2);
		break;
	case 2:
		Weapons_ViewAnimation(pl, AP9_SHOOT3);
		break;
	}

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTop(pl, ANIM_SHOOT1HAND, 0.45f);
	else
		Animation_PlayerTop(pl, ANIM_CR_SHOOT1HAND, 0.45f);

#ifdef CLIENT
	View_AddEvent(w_glock_ejectshell, 0.0f);
	View_SetMuzzleflash(MUZZLE_SMALL);
#else
	TraceAttack_FireBullets(3, pl.origin + pl.view_ofs, 8, [0.02,0.02], WEAPON_AP9);
	Sound_Play(pl, CHAN_WEAPON, "weapon_ap9.fire");
#endif

	pl.w_attack_next = 1.0f;
	pl.w_idle_next = 5.0f;
}

void
w_ap9_reload(player pl)
{

	if (pl.w_attack_next > 0.0)
		return;
	if (pl.ap9_mag >= 40)
		return;
	if (pl.a_ammo2 <= 0)
		return;

#ifdef CLIENT
	Weapons_ViewAnimation(pl, AP9_RELOAD);
#else
	Weapons_ReloadWeapon(pl, player::ap9_mag, player::ammo_ap9, 40);
#endif

	pl.w_attack_next = 2.0f;
	pl.w_idle_next = 10.0f;
}

void
w_ap9_release(player pl)
{

	/* auto-reload if need be */
	if (pl.w_attack_next <= 0.0)
	if (pl.ap9_mag == 0 && pl.ammo_ap9 > 0) {
		Weapons_Reload(pl);
		return;
	}

	if (pl.w_idle_next > 0.0)
		return;

	Weapons_ViewAnimation(pl, AP9_IDLE);
}

float
w_ap9_aimanim(player pl)
{
	return w_glock_aimanim(pl);
}

void
w_ap9_hud(player pl)
{
	w_glock_hud(pl);
}

void
w_ap9_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	vector hud_col;

	if (pl.ap9_mag == 0 && pl.ammo_ap9 == 0)
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	HUD_DrawAmmoBar(pos, pl.ammo_ap9, MAX_A_AP9, a);

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/tfchud05.spr_0.tga",
			[0,0],
			[170/256,45/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			"sprites/tfchud05.spr_0.tga",
			[0,0],
			[170/256,45/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

int
w_ap9_isempty(player pl)
{

	if (pl.ap9_mag <= 0 && pl.ammo_ap9 <= 0)
		return 1;

	return 0;
}

weapontype_t
w_ap9_type(player pl)
{
	return WPNTYPE_RANGED;
}

weapon_t w_ap9 =
{
	.name		= "ap9",
	.id			= ITEM_AP9,
	.slot		= 1,
	.slot_pos	= 2,
	.weight		= WEIGHT_AP9,
	.draw		= w_ap9_draw,
	.holster	= w_ap9_holster,
	.primary	= w_ap9_primary,
	.secondary	= w_ap9_secondary,
	.reload		= w_ap9_reload,
	.release	= w_ap9_release,
	.postdraw	= w_ap9_hud,
	.precache	= w_ap9_precache,
	.pickup		= w_ap9_pickup,
	.updateammo	= w_ap9_updateammo,
	.wmodel		= w_ap9_wmodel,
	.pmodel		= w_ap9_pmodel,
	.deathmsg	= w_ap9_deathmsg,
	.aimanim	= w_ap9_aimanim,
	.isempty	= w_ap9_isempty,
	.type		= w_ap9_type,
	.hudpic		= w_ap9_hudpic
};

/* pickups */
#ifdef SERVER
void
weapon_th_ap9(void)
{
	Weapons_InitItem(WEAPON_AP9);
}
#endif
