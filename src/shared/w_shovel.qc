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
	CBAR_IDLE,
	CBAR_DRAW,
	CBAR_HOLSTER,
	CBAR_ATTACK1HIT,
	CBAR_ATTACK1MISS,
	CBAR_ATTACK2MISS,
	CBAR_ATTACK2HIT,
	CBAR_ATTACK3MISS,
	CBAR_ATTACK3HIT
};

void
w_shovel_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_crowbar.hit");
	Sound_Precache("weapon_crowbar.miss");
	Sound_Precache("weapon_crowbar.hitbody");
#endif
	precache_model("models/v_shovel.mdl");
	precache_model("models/w_shovel.mdl");
	precache_model("models/p_shovel.mdl");
}

void
w_shovel_updateammo(player pl)
{
	w_crowbar_updateammo(pl);
}

string
w_shovel_wmodel(void)
{
	return "models/w_shovel.mdl";
}
string
w_shovel_pmodel(player pl)
{
	return "models/p_shovel.mdl";
}

string
w_shovel_deathmsg(void)
{
	return "%s was buried by %s's Shovel.";
}

void
w_shovel_draw(player pl)
{
	Weapons_SetModel("models/v_shovel.mdl");
	Weapons_ViewAnimation(pl, CBAR_DRAW);
}

void
w_shovel_holster(player pl)
{
	w_crowbar_holster(pl);
}

void
w_shovel_primary(player pl)
{
	int anim = 0;
	vector src;

	if (pl.w_attack_next)
		return;

	Weapons_MakeVectors(pl);
	src = pl.origin + pl.view_ofs;

	/* make sure we can gib corpses */
	int oldhitcontents = self.hitcontentsmaski;
	self.hitcontentsmaski = CONTENTBITS_POINTSOLID | CONTENTBIT_CORPSE;
	traceline(src, src + (v_forward * 32), FALSE, pl);
	self.hitcontentsmaski = oldhitcontents;

	/* Stock shovel is exactly like umbrella
	 * this cvar will spice things up a bit */
	if (serverkeyfloat("th_shovelstyle") == 1) {
	
		if (trace_fraction >= 1.0) {
			Weapons_ViewPunchAngle(pl, [5,0,0]);
			pl.w_attack_next = 0.85f;
		} else {
			Weapons_ViewPunchAngle(pl, [-20,0,0]);
			pl.w_attack_next = 1.2f;
		}
	} else {
		if (trace_fraction >= 1.0) {
			pl.w_attack_next = 0.5f;
		} else {
			pl.w_attack_next = 0.25f;
		}
	}
	pl.w_idle_next = 2.5f;

	int r = (float)input_sequence % 3;
	switch (r) {
	case 0:
		Weapons_ViewAnimation(pl, trace_fraction >= 1 ? CBAR_ATTACK1MISS:CBAR_ATTACK1HIT);
		break;
	case 1:
		Weapons_ViewAnimation(pl, trace_fraction >= 1 ? CBAR_ATTACK2MISS:CBAR_ATTACK2HIT);
		break;
	default:
		Weapons_ViewAnimation(pl, trace_fraction >= 1 ? CBAR_ATTACK3MISS:CBAR_ATTACK3HIT);
	}

	if (pl.flags & FL_CROUCHING) {
		Animation_PlayerTop(pl, ANIM_SHOOTCROWBAR, 0.5f);
	} else {
		Animation_PlayerTop(pl, ANIM_CR_SHOOTCROWBAR, 0.42f);
	}

#ifdef SERVER
	Sound_Play(self, CHAN_WEAPON, "weapon_crowbar.miss");

	if (trace_fraction >= 1.0)
		return;

	/* don't bother with decals, we got squibs */
	if (trace_ent.iBleeds) {
		FX_Blood(trace_endpos, [1,0,0]);
	} else {
		SurfData_Impact(trace_ent, trace_endpos, trace_plane_normal);
	}

	if (trace_ent.takedamage) {
		if (serverkeyfloat("th_shovelstyle") == 1) {
			Damage_Apply(trace_ent, pl, Skill_GetValue("plr_crowbar", 10) * 2.0, WEAPON_CROWBAR, DMG_BLUNT);
		} else {
			Damage_Apply(trace_ent, pl, Skill_GetValue("plr_crowbar", 10), WEAPON_CROWBAR, DMG_BLUNT);
		}
		if (trace_ent.iBleeds) {
			Sound_Play(self, CHAN_WEAPON, "weapon_crowbar.hitbody");
		}
	} else {
		Sound_Play(self, CHAN_WEAPON, "weapon_crowbar.hit");
	}
#endif
}

void
w_shovel_release(player pl)
{
	w_crowbar_release(pl);
}

float
w_shovel_aimanim(player pl)
{
	return w_crowbar_aimanim(pl);
}

void
w_shovel_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/tfchud04.spr_0.tga",
			[0,135/256],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			"sprites/tfchud03.spr_0.tga",
			[0,90/256],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

int
w_shovel_isempty(player pl)
{
	return 0;
}

weapontype_t
w_shovel_type(player pl)
{
	return WPNTYPE_CLOSE;
}

weapon_t w_shovel =
{
	.name		= "shovel",
	.id			= ITEM_SHOVEL,
	.slot		= 0,
	.slot_pos	= 1,
	.weight		= WEIGHT_SHOVEL,
	.draw		= w_shovel_draw,
	.holster	= w_shovel_holster,
	.primary	= w_shovel_primary,
	.secondary	= __NULL__,
	.reload		= __NULL__,
	.release	= w_shovel_release,
	.postdraw	= __NULL__,
	.precache	= w_shovel_precache,
	.pickup		= __NULL__,
	.updateammo	= w_shovel_updateammo,
	.wmodel		= w_shovel_wmodel,
	.pmodel		= w_shovel_pmodel,
	.deathmsg	= w_shovel_deathmsg,
	.aimanim	= w_shovel_aimanim,
	.isempty	= w_shovel_isempty,
	.type		= w_shovel_type,
	.hudpic		= w_shovel_hudpic
};

/* entity definitions for pickups */
#ifdef SERVER
void
weapon_th_shovel(void)
{
	Weapons_InitItem(WEAPON_SHOVEL);
}
#endif
