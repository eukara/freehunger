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
	EGON_IDLE1,
	EGON_FIDGET1,
	EGON_ALTFIREON,
	EGON_ALTFIRECYCLE,
	EGON_ALTFIREOFF,
	EGON_FIRE1,
	EGON_FIRE2,
	EGON_FIRE3,
	EGON_FIRE4,
	EGON_DRAW,
	EGON_HOLSTER
};

void
w_flame_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_flame.fire");
#endif
	precache_model("sprites/fthrow.spr");
	precache_model("models/v_egon.mdl");
	precache_model("models/w_egon.mdl");
	precache_model("models/p_egon.mdl");
}

void
w_flame_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, -1, pl.ammo_gas, -1);
}

string
w_flame_wmodel(void)
{
	return w_egon_wmodel();
}

string
w_flame_pmodel(player pl)
{
	return w_egon_pmodel(pl);
}

string
w_flame_deathmsg(void)
{
	return "%s burned to a crisp by %s's Flamethrower.";
}

int
w_flame_pickup(player pl, int new, int startammo)
{
#ifdef SERVER

	if (pl.ammo_gas < MAX_A_GAS) {
		pl.ammo_gas = bound(0, pl.ammo_gas + 20, MAX_A_GAS);
	} else {
		if (!new)
			return (0);
	}
#endif
	return (1);
}

void
w_flame_draw(player pl)
{
	w_egon_draw(pl);
}

void
w_flame_holster(player pl)
{
	w_egon_holster(pl);
}

void
w_flame_primary(player pl)
{
	if (pl.w_attack_next > 0.0)
		return;

	/* Ammo check */
	if (pl.ammo_gas <= 0)
		return;

	pl.ammo_gas--;

#ifdef CLIENT
	if (Weapons_GetAnimation(pl) == EGON_IDLE1)
		Weapons_ViewAnimation(pl, EGON_ALTFIREON);
	else if (Weapons_GetAnimation(pl) == EGON_ALTFIREON)
		Weapons_ViewAnimation(pl, EGON_ALTFIRECYCLE);
#else

	static void w_flame_die(void) {
		remove(self);
		}

	static void w_flame_touch(entity target, entity source) {
		if (target.takedamage == DAMAGE_YES) {
			NSSurfacePropEntity m = (NSSurfacePropEntity)target;
			m.Ignite(source, 5.0f, WEAPON_EGON);
		}
// To be added to spec
//		Damage_Apply(target, source.owner, Skill_GetValue("sk_flame", 13), WEAPON_EGON, DMG_BURN);
	}

	Sound_Play(pl, CHAN_WEAPON, "weapon_flame.fire");
	NSProjectile ball = spawn(NSProjectile);
	ball.SetModel("sprites/fthrow.spr");
	ball.SetRenderMode(RM_ADDITIVE);
	ball.SetOwner(pl);
	ball.SetImpact(w_flame_touch);
	ball.think = w_flame_die;
	ball.nextthink = time + 1.75f;
// To be added to spec
//	ball.Animate(0,15);
//	ball.effects |= EF_BRIGHTLIGHT;

// Also will need check for water contents (so projectile will die underwater)

	Weapons_MakeVectors(pl);
	ball.SetOrigin(Weapons_GetCameraPos(pl) + (v_forward * 16));
	ball.SetVelocity(v_forward * 300);
	setsize(ball, [0,0,0], [0,0,0]);

#endif

	pl.w_attack_next = 0.2f;
	pl.w_idle_next = 2.5f;
}

void
w_flame_reload(player pl)
{
}

void
w_flame_release(player pl)
{
	w_egon_release(pl);
}

void
w_flame_crosshair(player pl)
{
#ifdef CLIENT
	static vector cross_pos;
	cross_pos = g_hudmins + (g_hudres / 2) + [-12,-12];
	drawsubpic(cross_pos, [24,24], "sprites/crosshairs.spr_0.tga", [72/128,48/128], [0.1875, 0.1875], [1,1,1], 1, DRAWFLAG_NORMAL);
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], "sprites/640hud7.spr_0.tga", [0,96/128], [24/256, 24/128], g_hud_color, pSeatLocal->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

float
w_flame_aimanim(player pl)
{
	return w_egon_aimanim(pl);
}

void
w_flame_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	vector hud_col;

	if (pl.ammo_gas == 0)
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	HUD_DrawAmmoBar(pos, pl.ammo_gas, MAX_A_GAS, a);

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/tfchud04.spr_0.tga",
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
			"sprites/tfchud03.spr_0.tga",
			[0,0/256],
			[170/256,45/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

int
w_flame_isempty(player pl)
{

	if (pl.ammo_gas <= 0)
		return 1;

	return 0;
}

weapontype_t
w_flame_type(player pl)
{
	return WPNTYPE_RANGED;
}

weapon_t w_flame =
{
	.name		= "flame",
	.id			= ITEM_EGON,
	.slot		= 3,
	.slot_pos	= 2,
	.weight		= WEIGHT_EGON,
	.draw		= w_flame_draw,
	.holster	= w_egon_holster,
	.primary	= w_flame_primary,
	.secondary	= w_flame_release,
	.reload		= __NULL__,
	.release	= w_flame_release,
	.postdraw	= w_flame_crosshair,
	.precache	= w_flame_precache,
	.pickup		= w_flame_pickup,
	.updateammo	= w_flame_updateammo,
	.wmodel		= w_flame_wmodel,
	.pmodel		= w_flame_pmodel,
	.deathmsg	= w_flame_deathmsg,
	.aimanim	= w_flame_aimanim,
	.isempty	= w_flame_isempty,
	.type		= w_flame_type,
	.hudpic		= w_flame_hudpic
};
