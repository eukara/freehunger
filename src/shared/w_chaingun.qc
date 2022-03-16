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

/* Animations */
enum
{
	CHAINGUN_IDLE1,
	CHAINGUN_IDLE2,
	CHAINGUN_SPINUP,
	CHAINGUN_SPINDOWN,
	CHAINGUN_FIRE,
	CHAINGUN_DRAW,
	CHAINGUN_HOLSTER
};

#ifdef CLIENT
void w_chaingun_ejectshell(void)
{
	static void w_chaingun_ejectshell_death(void) {
		remove(self);
	}
	static void w_chaingun_ejectshell_touch(void) {
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
	eShell.velocity += (v_right * -80);
	eShell.velocity += (v_up * 100);
	eShell.touch = w_chaingun_ejectshell_touch;

	eShell.avelocity = [0,45,900];
	eShell.think = w_chaingun_ejectshell_death;
	eShell.nextthink = time + 2.5f;
	setsize(eShell, [0,0,0], [0,0,0]);
	setorigin(eShell, pSeat->m_eViewModel.origin + (v_forward * 26) + (v_up * -15));
}
#endif

void
w_chaingun_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_chaingun.fire");
	Sound_Precache("weapon_chaingun.reload");
	Sound_Precache("weapon_chaingun.spindown");
	Sound_Precache("weapon_chaingun.spinup");
#endif
	precache_model("models/v_tfac.mdl");
	precache_model("models/w_tfac.mdl");
	precache_model("models/p_tfac.mdl");
}

int
w_chaingun_pickup(player pl, int new, int startammo)
{
#ifdef SERVER

	if (new) {
		pl.chaingun_mag = 100;
		return (1);
	}

	if (pl.ammo_9mm < MAX_A_9MM) {
		pl.ammo_9mm = bound(0, pl.ammo_9mm + 100, MAX_A_9MM);
	} else {
		if (!new)
			return (0);
	}
#endif
	return (1);
}

void
w_chaingun_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.chaingun_mag, pl.ammo_9mm, -1);
}

string
w_chaingun_wmodel(void)
{
	return "models/w_tfac.mdl";
}

string
w_chaingun_pmodel(player pl)
{
	return "models/p_tfac.mdl";
}

string
w_chaingun_deathmsg(void)
{
	return "%s was rolled over by %s' Chaingun.";
}

void
w_chaingun_draw(player pl)
{
	pl.mode_tempstate = 0;
	Weapons_SetModel("models/v_tfac.mdl");
	Weapons_ViewAnimation(pl, CHAINGUN_DRAW);
}

void
w_chaingun_holster(player pl)
{
	Weapons_ViewAnimation(pl, CHAINGUN_HOLSTER);
}

void
w_chaingun_release(player pl)
{

	/* auto-reload if need be */
	if (pl.w_attack_next <= 0.0)
	if (pl.chaingun_mag == 0 && pl.ammo_9mm > 0) {
		Weapons_Reload(pl);
		return;
	}

	if (pl.w_idle_next > 0.0)
		return;

	/* end firing */
	if (pl.mode_tempstate == 1) {
		pl.mode_tempstate = 0;
#ifdef SERVER
		Sound_Play(pl, CHAN_WEAPON, "weapon_chaingun.spindown");
#endif
		Weapons_ViewAnimation(pl, CHAINGUN_SPINDOWN);
		pl.w_attack_next = 1.0f;
		pl.w_idle_next = pl.w_attack_next;
		return;
	}

	/* end reload */
	if (pl.mode_tempstate == 2) {
		pl.mode_tempstate = 0;
		Weapons_ViewAnimation(pl, CHAINGUN_DRAW);
		pl.w_attack_next = 1.0f;
		pl.w_idle_next = pl.w_attack_next;
		return;
	}

	int r = (float)input_sequence % 2;
	if (r) {
		Weapons_ViewAnimation(pl, CHAINGUN_IDLE1);
	} else {
		Weapons_ViewAnimation(pl, CHAINGUN_IDLE2);
	}

	pl.w_idle_next = 15.0f;
}

void
w_chaingun_primary(player pl)
{

	/* in case we're spamming primary while reloading */
	if (pl.mode_tempstate == 2) {
		w_chaingun_release(pl);
		return;
	}

	if (pl.w_attack_next > 0.0)
		return;

	/* ammo check */
	if (pl.chaingun_mag <= 0)
		return;

	/* spin up first */
	if (pl.mode_tempstate == 0) {
		pl.mode_tempstate = 1;
		Weapons_ViewAnimation(pl, CHAINGUN_SPINUP);
#ifdef SERVER
		Sound_Play(pl, CHAN_WEAPON, "weapon_chaingun.spinup");
#endif
		pl.w_attack_next = 0.5f;
		pl.w_idle_next = pl.w_attack_next;
		return;
	}
	pl.chaingun_mag--;

	Weapons_ViewAnimation(pl, CHAINGUN_FIRE);
	Weapons_ViewPunchAngle(pl, [random(-2, 2),0,0]);

#ifdef CLIENT
	View_AddEvent(w_chaingun_ejectshell, 0.0f);
	View_SetMuzzleflash(MUZZLE_RIFLE);
#else
	TraceAttack_FireBullets(1, Weapons_GetCameraPos(pl), 8, [0.15,0.15], WEAPON_CHAINGUN);
	Sound_Play(pl, CHAN_WEAPON, "weapon_chaingun.fire");
#endif

	pl.w_attack_next = 0.1f;
	pl.w_idle_next = 0.0f;
}

void
w_chaingun_reload(player pl)
{
	if (pl.w_attack_next) {
		w_chaingun_release(pl);
		return;
	}

	/* ammo check */
	if (pl.chaingun_mag >= 100)
		return;
	if (pl.ammo_9mm <= 0)
		return;

	Weapons_ViewAnimation(pl, CHAINGUN_HOLSTER);

#ifdef SERVER
	Sound_Play(pl, CHAN_WEAPON, "weapon_chaingun.reload");
	Weapons_ReloadWeapon(pl, player::chaingun_mag, player::ammo_9mm, 100);
#endif

	pl.mode_tempstate = 2;
	pl.w_attack_next = 10.0f;
	pl.w_idle_next = 1.5f;
}

void
w_chaingun_hud(player pl)
{
	w_glock_hud(pl);
}

float
w_chaingun_aimanim(player pl)
{
	return w_mp5_aimanim(pl);
}

void
w_chaingun_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	vector hud_col;

	if (pl.chaingun_mag == 0 && pl.ammo_9mm == 0)
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	HUD_DrawAmmoBar(pos, pl.ammo_9mm, MAX_A_9MM, a);

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/tfchud04.spr_0.tga",
			[0,90/256],
			[170/256,45/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			"sprites/tfchud03.spr_0.tga",
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
w_chaingun_isempty(player pl)
{

	if (pl.chaingun_mag <= 0 && pl.ammo_9mm <= 0)
		return 1;

	return 0;
}

weapontype_t
w_chaingun_type(player pl)
{
	return WPNTYPE_RANGED;
}

weapon_t w_chaingun =
{
	.name		= "chaingun",
	.id			= ITEM_CHAINGUN,
	.slot		= 3,
	.slot_pos	= 3,
	.weight		= WEIGHT_CHAINGUN,
	.draw		= w_chaingun_draw,
	.holster	= w_chaingun_holster,
	.primary	= w_chaingun_primary,
	.secondary	= w_chaingun_release,
	.reload		= w_chaingun_reload,
	.release	= w_chaingun_release,
	.postdraw	= w_chaingun_hud,
	.precache	= w_chaingun_precache,
	.pickup		= w_chaingun_pickup,
	.updateammo	= w_chaingun_updateammo,
	.wmodel		= w_chaingun_wmodel,
	.pmodel		= w_chaingun_pmodel,
	.deathmsg	= w_chaingun_deathmsg,
	.aimanim	= w_chaingun_aimanim,
	.isempty	= w_chaingun_isempty,
	.type		= w_chaingun_type,
	.hudpic		= w_chaingun_hudpic
};

/* pickups */
#ifdef SERVER
void
weapon_th_chaingun(void)
{
	Weapons_InitItem(WEAPON_CHAINGUN);
}
#endif
