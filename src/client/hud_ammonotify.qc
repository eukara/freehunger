#define AMMO_COUNT 17

string g_ammo_spr;
string g_item_spr;

typedef struct
{
	float alpha;
	int count;
} ammonote_t;
ammonote_t g_ammonotify[AMMO_COUNT];

vector g_ammotype[AMMO_COUNT] = {
	[0/256, 72/128], // pistol
	[24/256, 72/128], // revolver
	[48/256, 72/128], // grenade
	[72/256, 72/128], // shell
	[96/256, 72/128], //  arrow
	[120/256, 72/128], // rocket
	[0/256, 96/128], // uranium
	[24/256, 96/128], // hornet
	[48/256, 96/128], // grenade
	[72/256, 96/128], // satchel
	[96/256, 96/128], //  snark
	[120/256, 96/128], // tripmine

	// Hunger
	[0/256, 72/128], // ap9
	[0/256, 72/128], // taurus
	[24/256, 72/128], // sniper
	[0/256, 96/128], // gas
	[176/256, 48/256], // medkit
};

void
HUD_AmmoNotify_Init(void)
{
	g_ammo_spr = spriteframe("sprites/640hud7.spr", 0, 0.0f);
}

void
HUD_AmmoNotify_Draw(__inout vector pos)
{
	pos[0] = g_hudmins[0] + g_hudres[0] - 40;

	for (int i = 0; i < AMMO_COUNT; i++) {
		vector srcpos;
		float a;

		/* make sure we skip any faded entries, and also null them */
		if (g_ammonotify[i].alpha <= 0.0f) {
			g_ammonotify[i].count = 0;
			continue;
		}

		/* let's get the src img pos for our type */
		srcpos = g_ammotype[i];
		a = bound(0, g_ammonotify[i].alpha, 1.0);
		
		string spr;
		vector scale;
		vector sz;

		if (i == 8)
			sz = [16,24];
		else
			sz = [24,24];

		if (i == 16)
			scale = [44/256, 44/256];
		else
			scale = [24/256, 24/128];

		if (i == 16)
			spr = g_item_spr;
		else
			spr = g_ammo_spr;

		/* we'll use the alpha to control the offset so it gently glides down when fading out */
		pos -= [0, 32 * a]; /* go up a notch */
		drawsubpic(pos,
			sz,
			spr,
			srcpos,
			scale,
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);

		drawfont = Font_GetID(FONT_20);
		string txt = sprintf("%i", g_ammonotify[i].count);
		float offs = stringwidth(txt, FALSE, [20,20]);
		drawstring(pos + [-offs - 8,4], sprintf("%i", g_ammonotify[i].count), [20,20], g_hud_color, a, DRAWFLAG_ADDITIVE);

		g_ammonotify[i].alpha -= (clframetime * 0.5);
	}
}

void
HUD_AmmoNotify_Insert(int type, int count)
{
	if (count <= 0)
		return;

	if (type == 7 && count < 8) // hornet hack!
		return;

	g_ammonotify[type].count += count;
	g_ammonotify[type].alpha = 2.5f;

}

/* called whenever we should check for pickup updates */
void
HUD_AmmoNotify_Check(player pl)
{
	HUD_AmmoNotify_Insert(0, pl.ammo_9mm - pl.ammo_9mm_net);
	HUD_AmmoNotify_Insert(1, pl.ammo_357 - pl.ammo_357_net);
	HUD_AmmoNotify_Insert(2, pl.ammo_m203_grenade - pl.ammo_m203_grenade_net);
	HUD_AmmoNotify_Insert(3, pl.ammo_buckshot - pl.ammo_buckshot_net);
	HUD_AmmoNotify_Insert(4, pl.ammo_bolt - pl.ammo_bolt_net);
	HUD_AmmoNotify_Insert(5, pl.ammo_rocket - pl.ammo_rocket_net);
	HUD_AmmoNotify_Insert(6, pl.ammo_uranium - pl.ammo_uranium_net);
	HUD_AmmoNotify_Insert(7, pl.ammo_hornet - pl.ammo_hornet_net);
	HUD_AmmoNotify_Insert(8, pl.ammo_handgrenade - pl.ammo_handgrenade_net);
	HUD_AmmoNotify_Insert(9, pl.ammo_satchel - pl.ammo_satchel_net);
	HUD_AmmoNotify_Insert(10, pl.ammo_snark - pl.ammo_snark_net);
	HUD_AmmoNotify_Insert(11, pl.ammo_tripmine - pl.ammo_tripmine_net);

	// Hunger
	HUD_AmmoNotify_Insert(12, pl.ammo_ap9 - pl.ammo_ap9_net);
	HUD_AmmoNotify_Insert(13, pl.ammo_taurus - pl.ammo_taurus_net);
	HUD_AmmoNotify_Insert(14, pl.ammo_sniper - pl.ammo_sniper_net);
	HUD_AmmoNotify_Insert(15, pl.ammo_gas - pl.ammo_gas_net);
	HUD_AmmoNotify_Insert(16, pl.ammo_medkit - pl.ammo_medkit_net);
}
