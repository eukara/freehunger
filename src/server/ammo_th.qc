/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
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

/*QUAKED ammo_egonclip (0 0 0.8) (-16 -16 0) (16 16 32)

THEY HUNGER (1999) ENTITY

Ammo for the Flamethrower.
A single ammo_egonclip will provide 25, er, gas.

 */
class ammo_egonclip:item_ammo
{
	void(void) ammo_egonclip;
	virtual void(entity) Touch;
};

void
ammo_egonclip::ammo_egonclip(void)
{
	model = "models/w_gas.mdl";
	Sound_Precache("ammo_gas.pickup");
	item_ammo::item_ammo();
}
void
ammo_egonclip::Touch(entity eToucher)
{
	if not (other.flags & FL_CLIENT) {
		return;
	}
	if (other.classname == "player") {
		player pl = (player)other;
		if (pl.ammo_gas < MAX_A_GAS) {
			pl.ammo_gas = bound(0, pl.ammo_gas + 25, MAX_A_GAS);
			item_ammo::Touch(eToucher);
			Sound_Play(other, CHAN_ITEM, "ammo_gas.pickup");
		}
	}
}

/*QUAKED ammo_th_ap9 (0 0 0.8) (-16 -16 0) (16 16 32)

THEY HUNGER (1999) ENTITY

Ammo for the AP9.
A single ammo_th_ap9 will provide 40 bullets.

*/
class ammo_th_ap9:item_ammo
{
	void(void) ammo_th_ap9;
	virtual void(entity) Touch;
};

void
ammo_th_ap9::ammo_th_ap9(void)
{
	model = "models/w_ap9clip.mdl";
	item_ammo::item_ammo();
}
void
ammo_th_ap9::Touch(entity eToucher)
{
	if not (other.flags & FL_CLIENT) {
		return;
	}
	if (other.classname == "player") {
		player pl = (player)other;
		if (pl.ammo_ap9 < MAX_A_AP9) {
			pl.ammo_ap9 = bound(0, pl.ammo_ap9 + 40, MAX_A_AP9);
			item_ammo::Touch(eToucher);
		}
	}
}

/*QUAKED ammo_th_taurus (0 0 0.8) (-16 -16 0) (16 16 32)

THEY HUNGER (1999) ENTITY

Ammo for the Taurus Pistol.
A single ammo_th_taurus will provide 10 bullets.

*/
class ammo_th_taurus:item_ammo
{
	void(void) ammo_th_taurus;
	virtual void(entity) Touch;
};

void
ammo_th_taurus::ammo_th_taurus(void)
{
	model = "models/w_taurusclip.mdl";
	item_ammo::item_ammo();
}
void
ammo_th_taurus::Touch(entity eToucher)
{
	if not (other.flags & FL_CLIENT) {
		return;
	}
	if (other.classname == "player") {
		player pl = (player)other;
		if (pl.ammo_taurus < MAX_A_TAURUS) {
			pl.ammo_taurus = bound(0, pl.ammo_taurus + 10, MAX_A_TAURUS);
			item_ammo::Touch(eToucher);
		}
	}
}

/*QUAKED ammo_einar1 (0 0 0.8) (-16 -16 0) (16 16 32)

THEY HUNGER (1999) ENTITY

Ammo for the Snipers.
A single ammo_th_sniper will provide 5 bullets.

Same as ammo_th_sniper

*/
/*QUAKED ammo_th_sniper (0 0 0.8) (-16 -16 0) (16 16 32)

THEY HUNGER (1999) ENTITY

Ammo for the Snipers.
A single ammo_th_sniper will provide 5 bullets.

Same as ammo_einar1

*/

class ammo_th_sniper:item_ammo
{
	void(void) ammo_th_sniper;
	virtual void(entity) Touch;
};

void
ammo_th_sniper::ammo_th_sniper(void)
{
	model = "models/w_antidote.mdl";
	item_ammo::item_ammo();
}
void
ammo_th_sniper::Touch(entity eToucher)
{
	if not (other.flags & FL_CLIENT) {
		return;
	}
	if (other.classname == "player") {
		player pl = (player)other;
		if (pl.ammo_sniper < MAX_A_SNIPER) {
			pl.ammo_sniper = bound(0, pl.ammo_sniper + 5, MAX_A_SNIPER);
			item_ammo::Touch(eToucher);
		}
	}
}

CLASSEXPORT(ammo_einar1, ammo_th_sniper)
