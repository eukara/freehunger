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

enum
{
	HANDGRENADE_IDLE,
	HANDGRENADE_FIDGET,
	HANDGRENADE_PULLPIN,
	HANDGRENADE_THROW1,
	HANDGRENADE_THROW2,
	HANDGRENADE_THROW3,
	HANDGRENADE_HOLSTER,
	HANDGRENADE_DRAW
};

void
w_tnt_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_handgrenade.bounce");
#endif

	precache_model("models/v_tnt.mdl");
	precache_model("models/w_tnt.mdl");
	precache_model("models/p_tnt.mdl");
}

void
w_tnt_updateammo(player pl)
{
	w_handgrenade_updateammo(pl);
}

string
w_tnt_wmodel(void)
{
	return "models/w_tnt.mdl";
}

string
w_tnt_pmodel(player pl)
{
	return "models/p_tnt.mdl";
}

string
w_tnt_deathmsg(void)
{
	return w_handgrenade_deathmsg();
}

int
w_tnt_pickup(player pl, int new, int startammo)
{
	return w_handgrenade_pickup(pl, new, startammo);
}

#ifdef SERVER
void
w_tnt_throw(player pl)
{
	static void WeaponFrag_Throw_Explode(void) {
		float dmg = Skill_GetValue("plr_hand_grenade", 100);
		pointparticles(particleeffectnum("fx_explosion.main"), self.origin, [0,0,0], 1);
		Damage_Radius(self.origin, self.owner, dmg, dmg * 2.5f, TRUE, WEAPON_HANDGRENADE);
		sound(self, CHAN_WEAPON, sprintf("weapons/explode%d.wav", floor(random() * 2) + 3), 1, ATTN_NORM);
		remove(self);
	}
	
	static void WeaponFrag_Throw_Touch(void) {
		if (other.takedamage == DAMAGE_YES)
			Damage_Apply(other, self.owner, 15, WEAPON_HANDGRENADE, DMG_BLUNT);
		else
			Sound_Play(self, CHAN_BODY, "weapon_handgrenade.bounce");

		self.frame = 0;
	}

	vector vPLAngle = pl.v_angle;

	if (vPLAngle[0] < 0)
		vPLAngle[0] = -10 + vPLAngle[0] * ((90 - 10) / 90.0);
	else
		vPLAngle[0] = -10 + vPLAngle[0] * ((90 + 10) / 90.0);

	float flVel = (90 - vPLAngle[0]) * 5;
	if (flVel > 1000)
		flVel = 1000;

	makevectors(vPLAngle);
	vector vecSrc = pl.origin + pl.view_ofs + v_forward * 16;
	vector vecThrow = v_forward * flVel + pl.velocity;

	entity eGrenade = spawn();
	eGrenade.owner = pl;
	eGrenade.classname = "remove_me";
	eGrenade.solid = SOLID_BBOX;
	eGrenade.frame = 1;
	eGrenade.velocity = vecThrow;
	eGrenade.movetype = MOVETYPE_BOUNCE;
	eGrenade.think = WeaponFrag_Throw_Explode;
	eGrenade.touch = WeaponFrag_Throw_Touch;
	eGrenade.nextthink = time + 4.0f;
	setmodel(eGrenade, "models/w_tnt.mdl");
	setsize(eGrenade, [0,0,0], [0,0,0]);
	setorigin(eGrenade, vecSrc);
}
#endif

void
w_tnt_draw(player pl)
{
	pl.mode_tempstate = 0;

	Weapons_SetModel("models/v_tnt.mdl");
	Weapons_ViewAnimation(pl, HANDGRENADE_DRAW);
}

void
w_tnt_holster(player pl)
{
	
}
void
w_tnt_primary(player pl)
{
	w_handgrenade_primary(pl);
}

void
w_tnt_hud(player pl)
{
#ifdef CLIENT
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [16,24], "sprites/640hud7.spr_0.tga", [48/256,96/128], [24/256, 24/128], g_hud_color, pSeatLocal->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}


void
w_tnt_release(player pl)
{
	
	if (pl.w_idle_next > 0.0)
		return;

	if (pl.mode_tempstate == 1) {
#ifdef SERVER
		w_tnt_throw(pl);
#endif
		Weapons_ViewAnimation(pl, HANDGRENADE_THROW1);
		pl.ammo_handgrenade--;
		pl.mode_tempstate = 2;
		pl.w_attack_next = 1.0f;
		pl.w_idle_next = 0.5f;
	} else if (pl.mode_tempstate == 2) {
#ifdef SERVER
		if (!pl.ammo_handgrenade)
			Weapons_RemoveItem(pl, WEAPON_HANDGRENADE);
#endif
		Weapons_ViewAnimation(pl, HANDGRENADE_DRAW);
		pl.w_attack_next = 0.5f;
		pl.w_idle_next = 0.5f;
		pl.mode_tempstate = 0;
	} else {
		int r = (float)input_sequence % 8;
		if (r == 1) {
			Weapons_ViewAnimation(pl, HANDGRENADE_FIDGET);
			pl.w_idle_next = 2.5f;
		} else {
			Weapons_ViewAnimation(pl, HANDGRENADE_IDLE);
			pl.w_idle_next = 3.0f;
		}
	}
}

float
w_tnt_aimanim(player pl)
{
	return w_handgrenade_aimanim(pl);
}

void
w_tnt_hudpic(player pl, int selected, vector pos, float a)
{
	w_handgrenade_hudpic(pl, selected, pos, a);
}

int
w_tnt_isempty(player pl)
{

	if (pl.ammo_handgrenade <= 0)
		return 1;

	return 0;
}

weapontype_t
w_tnt_type(player pl)
{
	return WPNTYPE_RANGED;
}

weapon_t w_tnt =
{
	.name		= "tnt",
	.id			= ITEM_HANDGRENADE,
	.slot		= 4,
	.slot_pos	= 0,
	.weight		= WEIGHT_HANDGRENADE,
	.draw		= w_tnt_draw,
	.holster	= w_tnt_holster,
	.primary	= w_tnt_primary,
	.secondary	= w_tnt_release,
	.reload		= w_tnt_release,
	.release	= w_tnt_release,
	.postdraw	= w_tnt_hud,
	.precache	= w_tnt_precache,
	.pickup		= w_tnt_pickup,
	.updateammo	= w_tnt_updateammo,
	.wmodel		= w_tnt_wmodel,
	.pmodel		= w_tnt_pmodel,
	.deathmsg	= w_tnt_deathmsg,
	.aimanim	= w_tnt_aimanim,
	.isempty	= w_snark_isempty,
	.type		= w_snark_type,
	.hudpic		= w_tnt_hudpic
};
