/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
 * Copyright (c) 2019-2021 Gethyn ThomasQuail <xylemon@posteo.net>
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

/*QUAKED item_healthkit (0 0 0.8) (-16 -16 0) (16 16 36)

THEY HUNGER (1999) ENTITY

Healthkit item/ammo.
Adds 20 of health to the player, unless th_medkitstyle is set to 1,
then it becomes ammo for the Medkit weapon which provides 15 health
per shot.

*/
class item_healthkit:CBaseEntity
{
	void(void) item_healthkit;
	virtual void(void) Respawn;
	virtual void(void) touch;
};

void item_healthkit::touch(void)
{
	if (other.classname != "player") {
		return;
	}

	if (cvar("th_medkitstyle") == 1) {
		player pl = (player)other;

		/* If pl does not have WEAPON_MEDKIT, give it to them */
		if (!Weapons_IsPresent(pl, WEAPON_MEDKIT)) {
			Sound_Play(other, CHAN_ITEM, "weapon.pickup");
			Weapons_AddItem(pl, WEAPON_MEDKIT, -1);
		} else {
			/* don't remove item if we're already fully */
			if (pl.ammo_medkit >= MAX_A_MEDKIT)
				return;

			/* otherwise, just give us ammo */
			pl.ammo_medkit = bound(0, pl.ammo_medkit + 1, MAX_A_MEDKIT);
			Sound_Play(other, CHAN_ITEM, "ammo.pickup");
			Weapons_RefreshAmmo(pl);
			Logging_Pickup(other, this, __NULL__);
		}
	} else {
		if (other.health >= other.max_health) {
			return;
		}

		Damage_Apply(other, this, -20, 0, DMG_GENERIC);
		Sound_Play(this, CHAN_ITEM, "item.healthkit");
		Logging_Pickup(other, this, __NULL__);
	}

	if (real_owner || cvar("sv_playerslots") == 1) {
		remove(self);
	} else {
		Hide();
		think = Respawn;
		nextthink = time + 20.0f;
	}
}

void item_healthkit::Respawn(void)
{
	SetSolid(SOLID_TRIGGER);
	SetMovetype(MOVETYPE_TOSS);
	SetOrigin(m_oldOrigin);
	SetModel(m_oldModel);
	SetSize([-16,-16,0],[16,16,16]);
	//botinfo = BOTINFO_HEALTH;

	think = __NULL__;
	nextthink = -1;

	if (!real_owner)
		Sound_Play(this, CHAN_ITEM, "item.respawn");

	droptofloor();
}

void item_healthkit::item_healthkit(void)
{
	Sound_Precache("ammo.pickup");
	Sound_Precache("item.healthkit");
	Sound_Precache("item.respawn");
	Sound_Precache("weapon.pickup");
	model = "models/w_medkit.mdl";
	CBaseEntity::CBaseEntity();
	item_healthkit::Respawn();
}
