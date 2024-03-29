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
	CBAR_ATTACK1,
	CBAR_ATTACK2,
	CBAR_UNUSED,
	CBAR_DRAW,
	CBAR_HOLSTER
};

void
w_spanner_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_crowbar.hit");
	Sound_Precache("weapon_crowbar.miss");
	Sound_Precache("weapon_crowbar.hitbody");
#endif
	precache_model("models/v_tfc_spanner.mdl");
	precache_model("models/backpack.mdl");
	precache_model("models/p_spanner.mdl");
}

void
w_spanner_updateammo(player pl)
{
	w_crowbar_updateammo(pl);
}

string
w_spanner_wmodel(void)
{
	return "models/backpack.mdl";
}
string
w_spanner_pmodel(player pl)
{
	return "models/p_spanner.mdl";
}

string
w_spanner_deathmsg(void)
{
	return "%s was retooled by %'s Wrench.";
}

void
w_spanner_draw(player pl)
{
	Weapons_SetModel("models/v_tfc_spanner.mdl");
	Weapons_ViewAnimation(pl, CBAR_DRAW);
}

void
w_spanner_holster(player pl)
{
	w_crowbar_holster(pl);
}

void
w_spanner_primary(player pl)
{
	int anim = 0;
	vector src;

	if (pl.w_attack_next)
		return;

	Weapons_MakeVectors(pl);
	src = pl.origin + pl.view_ofs;
	traceline(src, src + (v_forward * 32), FALSE, pl);

	if (trace_fraction >= 1.0) {
		pl.w_attack_next = 0.375f;
	} else {
		pl.w_attack_next = 0.20f;
	}
	pl.w_idle_next = 2.5f;

	if (random() < 0.5) {
		Weapons_ViewAnimation(pl, CBAR_ATTACK1);
	} else {
		Weapons_ViewAnimation(pl, CBAR_ATTACK2);
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
		Damage_Apply(trace_ent, pl, Skill_GetValue("plr_crowbar", 10), WEAPON_CROWBAR, DMG_BLUNT);

		if (!trace_ent.iBleeds) {
			return;
		}

		Sound_Play(self, CHAN_WEAPON, "weapon_crowbar.hitbody");
	} else {
		Sound_Play(self, CHAN_WEAPON, "weapon_crowbar.hit");
	}
#endif
}

void
w_spanner_release(player pl)
{
	w_crowbar_release(pl);
}

float
w_spanner_aimanim(player pl)
{
	return w_crowbar_aimanim(pl);
}

void
w_spanner_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/tfchud04.spr_0.tga",
			[0,180/256],
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
			[0,135/256],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

int
w_spanner_isempty(player pl)
{
	return 0;
}

weapontype_t
w_spanner_type(player pl)
{
	return WPNTYPE_CLOSE;
}

weapon_t w_spanner =
{
	.name		= "spanner",
	.id			= ITEM_SPANNER,
	.slot		= 0,
	.slot_pos	= 2,
	.weight		= WEIGHT_SPANNER,
	.draw		= w_spanner_draw,
	.holster	= w_spanner_holster,
	.primary	= w_spanner_primary,
	.secondary	= __NULL__,
	.reload		= __NULL__,
	.release	= w_spanner_release,
	.postdraw	= __NULL__,
	.precache	= w_spanner_precache,
	.pickup		= __NULL__,
	.updateammo	= w_spanner_updateammo,
	.wmodel		= w_spanner_wmodel,
	.pmodel		= w_spanner_pmodel,
	.deathmsg	= w_spanner_deathmsg,
	.aimanim	= w_spanner_aimanim,
	.isempty	= w_spanner_isempty,
	.type		= w_spanner_type,
	.hudpic		= w_spanner_hudpic
};

/* entity definitions for pickups */
#ifdef SERVER
void
weapon_th_spanner(void)
{
	Weapons_InitItem(WEAPON_SPANNER);
}
#endif
