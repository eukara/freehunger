/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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

/* weapon Indices for the weapon table */
enum
{
	WEAPON_NONE,
	WEAPON_CROWBAR,
	WEAPON_SHOVEL,
	WEAPON_SPANNER,
	WEAPON_GLOCK,
	WEAPON_PYTHON,
	WEAPON_AP9,
	WEAPON_TAURUS,
	WEAPON_MP5,
	WEAPON_SHOTGUN,
	WEAPON_CROSSBOW,
	WEAPON_SNIPER,
	WEAPON_SNIPER2,
	WEAPON_RPG,
	WEAPON_GAUSS,
	WEAPON_EGON,
	WEAPON_CHAINGUN,
	WEAPON_HANDGRENADE,
	WEAPON_SATCHEL,
	WEAPON_TRIPMINE,
	WEAPON_SNARK,
	WEAPON_MEDKIT
};

/* Medkit ammo is 12 in stock, changed for multiplayer */
#define MAX_A_9MM		250
#define MAX_A_357		36
#define MAX_A_AP9		200
#define MAX_A_TAURUS		80
#define MAX_A_BUCKSHOT		125
#define MAX_A_M203_GRENADE	10
#define MAX_A_BOLT		50
#define MAX_A_SNIPER		50
#define MAX_A_ROCKET		5
#define MAX_A_URANIUM		100
#define MAX_A_GAS		100
#define MAX_A_HANDGRENADE	10
#define MAX_A_SATCHEL		5
#define MAX_A_TRIPMINE		10
#define MAX_A_SNARK		10
#define MAX_A_HORNET		8
#define MAX_A_MEDKIT		8
