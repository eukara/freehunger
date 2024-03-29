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

#include "../../../valve/src/shared/skeleton.h"

/* all potential SendFlags bits we can possibly send */
enumflags
{
	PLAYER_TOPFRAME = PLAYER_CUSTOMFIELDSTART,
	PLAYER_BOTTOMFRAME,
	PLAYER_AMMO1,
	PLAYER_AMMO2,
	PLAYER_AMMO3,
	PLAYER_UNUSED5,
	PLAYER_UNUSED6,
	PLAYER_UNUSED7
};

class player:NSClientPlayer
{
	/* animation */
	PREDICTED_INT(anim_top)
	PREDICTED_FLOAT(anim_top_time)
	PREDICTED_FLOAT(anim_top_delay)
	PREDICTED_INT(anim_bottom)
	PREDICTED_FLOAT(anim_bottom_time)

	/* ammo 1 */
	PREDICTED_INT(glock_mag)
	PREDICTED_INT(mp5_mag)
	PREDICTED_INT(python_mag)
	PREDICTED_INT(shotgun_mag)
	PREDICTED_INT(crossbow_mag)
	PREDICTED_INT(rpg_mag)
	PREDICTED_INT(satchel_chg)

	/* ammo 2 */
	PREDICTED_INT(ammo_9mm)
	PREDICTED_INT(ammo_357)
	PREDICTED_INT(ammo_buckshot)
	PREDICTED_INT(ammo_bolt)
	PREDICTED_INT(ammo_rocket)
	PREDICTED_INT(ammo_uranium)
	PREDICTED_INT(ammo_handgrenade)
	PREDICTED_INT(ammo_satchel)
	PREDICTED_INT(ammo_tripmine)
	PREDICTED_INT(ammo_snark)
	PREDICTED_INT(ammo_hornet)

	/* ammo 3 */
	PREDICTED_INT(ammo_m203_grenade)
	PREDICTED_INT(ammo_gauss_volume)
	PREDICTED_INT(ammo_rpg_state)
	PREDICTED_INT(mode_tempstate)

	/* hunger */
	PREDICTED_INT(sniper_mag)
	PREDICTED_INT(chaingun_mag)
	PREDICTED_INT(ap9_mag)
	PREDICTED_INT(taurus_mag)

	PREDICTED_INT(ammo_ap9)
	PREDICTED_INT(ammo_taurus)
	PREDICTED_INT(ammo_sniper)
	PREDICTED_INT(ammo_gas)
	PREDICTED_INT(ammo_medkit)
	PREDICTED_INT(mode_silencer)

	virtual void UpdatePlayerAnimation(float);

#ifdef CLIENT
	virtual void UpdatePlayerAttachments(bool);
	virtual void ReceiveEntity(float,float);
	virtual void PredictPreFrame(void);
	virtual void PredictPostFrame(void);
	virtual void UpdateAliveCam(void);
#else
	virtual void(void) EvaluateEntity;
	virtual float(entity, float) SendEntity;
#endif
};


void Animation_PlayerUpdate(player); 
void Animation_TimerUpdate(player, float); 

void
player::UpdatePlayerAnimation(float timelength)
{
	/* calculate our skeletal progression */
	Animation_PlayerUpdate(this);
	/* advance animation timers */
	Animation_TimerUpdate(this, timelength);
}

#ifdef CLIENT
void Camera_RunPosBob(vector angles, __inout vector camera_pos);
void Camera_StrafeRoll(__inout vector camera_angle);
void Shake_Update(NSClientPlayer);

void
player::UpdateAliveCam(void)
{
	vector cam_pos = GetEyePos();
	Camera_RunPosBob(view_angles, cam_pos);

	g_view.SetCameraOrigin(cam_pos);
	Camera_StrafeRoll(view_angles);
	g_view.SetCameraAngle(view_angles);

	if (vehicle) {
		NSVehicle veh = (NSVehicle)vehicle;

		if (veh.UpdateView)
			veh.UpdateView();
	} else if (health) {
		if (autocvar_pm_thirdPerson == TRUE) {
			makevectors(view_angles);
			vector vStart = [pSeat->m_vecPredictedOrigin[0], pSeat->m_vecPredictedOrigin[1], pSeat->m_vecPredictedOrigin[2] + 16] + (v_right * 4);
			vector vEnd = vStart + (v_forward * -48) + [0,0,16] + (v_right * 4);
			traceline(vStart, vEnd, FALSE, this);
			g_view.SetCameraOrigin(trace_endpos + (v_forward * 5));
		}
	}

	Shake_Update(this);
	g_view.AddPunchAngle(punchangle);
}
.string oldmodel;
string Weapons_GetPlayermodel(player, int);

void
player::UpdatePlayerAttachments(bool visible)
{
	/* draw the flashlight */
	if (gflags & GF_FLASHLIGHT) {
		vector src;
		vector ang;
		
		if (entnum != player_localentnum) {
			src = origin + view_ofs;
			ang = v_angle;
		} else {
			src = pSeat->m_vecPredictedOrigin + view_ofs;
			ang = view_angles;
		}

		makevectors(ang);
		traceline(src, src + (v_forward * 8096), MOVE_NORMAL, this);

		if (serverkeyfloat("*bspversion") == BSPVER_HL) {
			dynamiclight_add(trace_endpos + (trace_plane_normal * 4), 128, [1,1,1]);
		} else {
			float p = dynamiclight_add(src, 512, [1,1,1], 0, "textures/flashlight");
			dynamiclight_set(p, LFIELD_ANGLES, ang);
			dynamiclight_set(p, LFIELD_FLAGS, 3);
		}
	}

	/* FIXME: this needs to be incorporated and simplified, now that we can handle it all in-class */
	if (!visible)
		return;

	/* what's the current weapon model supposed to be anyway? */
	p_model.oldmodel = Weapons_GetPlayermodel(this, activeweapon);

	/* we changed weapons, update skeletonindex */
	if (p_model.model != p_model.oldmodel) {
		/* free memory */
		if (p_model.skeletonindex)
			skel_delete(p_model.skeletonindex);

		/* set the new model and mark us updated */
		setmodel(p_model, p_model.oldmodel);
		p_model.model = p_model.oldmodel;
		
		/* set the new skeletonindex */
		p_model.skeletonindex = skel_create(p_model.modelindex);

		/* hack this thing in here FIXME: this should be done when popping in/out of a pvs */
		if (autocvar(cl_himodels, 1, "Use high-quality thisayer models over lower-definition ones"))
			setcustomskin(this, "", "geomset 0 2\n");
		else
			setcustomskin(this, "", "geomset 0 1\n");
	}

	/* follow thisayer at all times */
	setorigin(p_model, origin);
	p_model.angles = angles;
	skel_build(p_model.skeletonindex, p_model, p_model.modelindex,0, 0, -1);

	/* we have to loop through all valid bones of the weapon model and match them
	 * to the thisayer one */
	for (float i = 0; i < g_pbones.length; i++) {
		vector bpos;
		float pbone = gettagindex(this, g_pbones[i]);
		float wbone = gettagindex(p_model, g_pbones[i]);

		/* if the bone doesn't ignore in either skeletal mesh, ignore */
		if (wbone <= 0 || pbone <= 0)
			continue;

		bpos = gettaginfo(this, pbone);
		
		/* the most expensive bit */
		skel_set_bone_world(p_model, wbone, bpos, v_forward, v_right, v_up);
	}
}

void Weapons_AmmoUpdate(entity);
void HUD_AmmoNotify_Check(player pl);
void HUD_ItemNotify_Check(player pl);
/*
=================
player::ReceiveEntity
=================
*/
void
player::ReceiveEntity(float new, float fl)
{
	NSClientPlayer::ReceiveEntity(new, fl);

	/* animation */
	if (fl & PLAYER_TOPFRAME) {
		anim_top = readbyte();
		anim_top_time = readfloat();
		anim_top_delay = readfloat();
	}
	if (fl & PLAYER_BOTTOMFRAME) {
		anim_bottom = readbyte();
		anim_bottom_time = readfloat();
	}

	if (fl & PLAYER_AMMO1) {
		glock_mag = readbyte();
		mp5_mag = readbyte();
		python_mag = readbyte();
		shotgun_mag = readbyte();
		crossbow_mag = readbyte();
		rpg_mag = readbyte();
		satchel_chg = readbyte();

		/* hunger */
		sniper_mag = readbyte();
		chaingun_mag = readbyte();
		ap9_mag = readbyte();
		taurus_mag = readbyte();
	}
	
	if (fl & PLAYER_AMMO2) {
		ammo_9mm = readbyte();
		ammo_357 = readbyte();
		ammo_buckshot = readbyte();
		ammo_bolt = readbyte();
		ammo_rocket = readbyte();
		ammo_uranium = readbyte();
		ammo_handgrenade = readbyte();
		ammo_satchel = readbyte();
		ammo_tripmine = readbyte();
		ammo_snark = readbyte();
		ammo_hornet = readbyte();

		/* hunger */
		ammo_ap9 = readbyte();
		ammo_taurus = readbyte();
		ammo_sniper = readbyte();
		ammo_gas = readbyte();
		ammo_medkit = readbyte();
	}

	if (fl & PLAYER_AMMO3) {
		ammo_m203_grenade = readbyte();
		ammo_gauss_volume = readbyte();
		ammo_rpg_state = readbyte();
		mode_tempstate = readbyte();
		mode_silencer = readbyte();
	}

	setorigin(this, origin);

	/* these only concern the current player */
	CSQC_UpdateSeat();
	if (this != pSeat->m_ePlayer)
		return;

	/* do not notify us of updates when spawning initially */
	if (fl == UPDATE_ALL)
		PredictPreFrame();

	if (fl & PLAYER_AMMO1 || fl & PLAYER_AMMO2 || fl & PLAYER_AMMO3) {
		Weapons_AmmoUpdate(this);
		HUD_AmmoNotify_Check(this);
	}

	if (fl & PLAYER_ITEMS || fl & PLAYER_HEALTH)
		HUD_ItemNotify_Check(this);
}

/*
=================
player::PredictPostFrame

Save the last valid server values away in the _net variants of each field
so we can roll them back later.
=================
*/
void
player::PredictPreFrame(void)
{
	NSClientPlayer::PredictPreFrame();

	SAVE_STATE(anim_top);
	SAVE_STATE(anim_top_delay);
	SAVE_STATE(anim_top_time);
	SAVE_STATE(anim_bottom);
	SAVE_STATE(anim_bottom_time);

	SAVE_STATE(glock_mag);
	SAVE_STATE(mp5_mag);
	SAVE_STATE(python_mag);
	SAVE_STATE(shotgun_mag);
	SAVE_STATE(crossbow_mag);
	SAVE_STATE(rpg_mag);
	SAVE_STATE(satchel_chg);

	SAVE_STATE(ammo_9mm);
	SAVE_STATE(ammo_357);
	SAVE_STATE(ammo_buckshot);
	SAVE_STATE(ammo_bolt);
	SAVE_STATE(ammo_rocket);
	SAVE_STATE(ammo_uranium);
	SAVE_STATE(ammo_handgrenade);
	SAVE_STATE(ammo_satchel);
	SAVE_STATE(ammo_tripmine);
	SAVE_STATE(ammo_snark);
	SAVE_STATE(ammo_hornet);

	SAVE_STATE(ammo_m203_grenade);
	SAVE_STATE(ammo_gauss_volume);
	SAVE_STATE(ammo_rpg_state);
	SAVE_STATE(mode_tempstate);

	/* hunger */
	SAVE_STATE(sniper_mag);
	SAVE_STATE(chaingun_mag);
	SAVE_STATE(ap9_mag);
	SAVE_STATE(taurus_mag);

	SAVE_STATE(ammo_ap9);
	SAVE_STATE(ammo_taurus);
	SAVE_STATE(ammo_sniper);
	SAVE_STATE(ammo_gas);
	SAVE_STATE(ammo_medkit);
	SAVE_STATE(mode_silencer);
}

/*
=================
player::PredictPostFrame

Where we roll back our values to the ones last sent/verified by the server.
=================
*/
void
player::PredictPostFrame(void)
{
	NSClientPlayer::PredictPostFrame();

	ROLL_BACK(anim_top);
	ROLL_BACK(anim_top_delay);
	ROLL_BACK(anim_top_time);
	ROLL_BACK(anim_bottom);
	ROLL_BACK(anim_bottom_time);

	ROLL_BACK(glock_mag);
	ROLL_BACK(mp5_mag);
	ROLL_BACK(python_mag);
	ROLL_BACK(shotgun_mag);
	ROLL_BACK(crossbow_mag);
	ROLL_BACK(rpg_mag);
	ROLL_BACK(satchel_chg);

	ROLL_BACK(ammo_9mm);
	ROLL_BACK(ammo_357);
	ROLL_BACK(ammo_buckshot);
	ROLL_BACK(ammo_m203_grenade);
	ROLL_BACK(ammo_bolt);
	ROLL_BACK(ammo_rocket);
	ROLL_BACK(ammo_uranium);
	ROLL_BACK(ammo_handgrenade);
	ROLL_BACK(ammo_satchel);
	ROLL_BACK(ammo_tripmine);
	ROLL_BACK(ammo_snark);
	ROLL_BACK(ammo_hornet);

	ROLL_BACK(ammo_m203_grenade);
	ROLL_BACK(ammo_gauss_volume);
	ROLL_BACK(ammo_rpg_state);
	ROLL_BACK(mode_tempstate);

	/* hunger */
	ROLL_BACK(sniper_mag);
	ROLL_BACK(chaingun_mag);
	ROLL_BACK(ap9_mag);
	ROLL_BACK(taurus_mag);

	ROLL_BACK(ammo_ap9);
	ROLL_BACK(ammo_taurus);
	ROLL_BACK(ammo_sniper);
	ROLL_BACK(ammo_gas);
	ROLL_BACK(ammo_medkit);
	ROLL_BACK(mode_silencer);
}

#else
void
player::EvaluateEntity(void)
{
	NSClientPlayer::EvaluateEntity();

	/* animation */
	if (ATTR_CHANGED(anim_bottom) || ATTR_CHANGED(anim_bottom_time))
		SendFlags |= PLAYER_BOTTOMFRAME;
	if (ATTR_CHANGED(anim_top) || ATTR_CHANGED(anim_top_time) || ATTR_CHANGED(anim_top_delay))
		SendFlags |= PLAYER_TOPFRAME;

	/* ammo 1 type updates */
	if (ATTR_CHANGED(glock_mag))
		SendFlags |= PLAYER_AMMO1;
	else if (ATTR_CHANGED(mp5_mag))
		SendFlags |= PLAYER_AMMO1;
	else if (ATTR_CHANGED(python_mag))
		SendFlags |= PLAYER_AMMO1;
	else if (ATTR_CHANGED(shotgun_mag))
		SendFlags |= PLAYER_AMMO1;
	else if (ATTR_CHANGED(crossbow_mag))
		SendFlags |= PLAYER_AMMO1;
	else if (ATTR_CHANGED(rpg_mag))
		SendFlags |= PLAYER_AMMO1;
	else if (ATTR_CHANGED(satchel_chg))
		SendFlags |= PLAYER_AMMO1;
	else if (ATTR_CHANGED(sniper_mag))
		SendFlags |= PLAYER_AMMO1;
	else if (ATTR_CHANGED(chaingun_mag))
		SendFlags |= PLAYER_AMMO1;
	else if (ATTR_CHANGED(ap9_mag))
		SendFlags |= PLAYER_AMMO1;
	else if (ATTR_CHANGED(taurus_mag))
		SendFlags |= PLAYER_AMMO1;

	/* ammo 2 type updates */
	if (ATTR_CHANGED(ammo_9mm))
		SendFlags |= PLAYER_AMMO2;
	else if (ATTR_CHANGED(ammo_357))
		SendFlags |= PLAYER_AMMO2;
	else if (ATTR_CHANGED(ammo_buckshot))
		SendFlags |= PLAYER_AMMO2;
	else if (ATTR_CHANGED(ammo_bolt))
		SendFlags |= PLAYER_AMMO2;
	else if (ATTR_CHANGED(ammo_rocket))
		SendFlags |= PLAYER_AMMO2;
	else if (ATTR_CHANGED(ammo_uranium))
		SendFlags |= PLAYER_AMMO2;
	else if (ATTR_CHANGED(ammo_handgrenade))
		SendFlags |= PLAYER_AMMO2;
	else if (ATTR_CHANGED(ammo_satchel))
		SendFlags |= PLAYER_AMMO2;
	else if (ATTR_CHANGED(ammo_tripmine))
		SendFlags |= PLAYER_AMMO2;
	else if (ATTR_CHANGED(ammo_snark))
		SendFlags |= PLAYER_AMMO2;
	else if (ATTR_CHANGED(ammo_hornet))
		SendFlags |= PLAYER_AMMO2;
	else if (ATTR_CHANGED(ammo_ap9))
		SendFlags |= PLAYER_AMMO2;
	else if (ATTR_CHANGED(ammo_taurus))
		SendFlags |= PLAYER_AMMO2;
	else if (ATTR_CHANGED(ammo_sniper))
		SendFlags |= PLAYER_AMMO2;
	else if (ATTR_CHANGED(ammo_gas))
		SendFlags |= PLAYER_AMMO2;
	else if (ATTR_CHANGED(ammo_medkit))
		SendFlags |= PLAYER_AMMO2;

	if (ATTR_CHANGED(ammo_m203_grenade))
		SendFlags |= PLAYER_AMMO3;
	else if (ATTR_CHANGED(ammo_gauss_volume))
		SendFlags |= PLAYER_AMMO3;
	else if (ATTR_CHANGED(ammo_rpg_state))
		SendFlags |= PLAYER_AMMO3;
	else if (ATTR_CHANGED(mode_tempstate))
		SendFlags |= PLAYER_AMMO3;
	else if (ATTR_CHANGED(mode_silencer)) /* hunger */
		SendFlags |= PLAYER_AMMO3;

	SAVE_STATE(anim_top);
	SAVE_STATE(anim_top_delay);
	SAVE_STATE(anim_top_time);
	SAVE_STATE(anim_bottom);
	SAVE_STATE(anim_bottom_time);

	SAVE_STATE(glock_mag);
	SAVE_STATE(mp5_mag);
	SAVE_STATE(python_mag);
	SAVE_STATE(shotgun_mag);
	SAVE_STATE(crossbow_mag);
	SAVE_STATE(rpg_mag);
	SAVE_STATE(satchel_chg);

	SAVE_STATE(ammo_9mm);
	SAVE_STATE(ammo_357);
	SAVE_STATE(ammo_buckshot);
	SAVE_STATE(ammo_bolt);
	SAVE_STATE(ammo_rocket);
	SAVE_STATE(ammo_uranium);
	SAVE_STATE(ammo_handgrenade);
	SAVE_STATE(ammo_satchel);
	SAVE_STATE(ammo_tripmine);
	SAVE_STATE(ammo_snark);
	SAVE_STATE(ammo_hornet);

	SAVE_STATE(ammo_m203_grenade);
	SAVE_STATE(ammo_gauss_volume);
	SAVE_STATE(ammo_rpg_state);
	SAVE_STATE(mode_tempstate);

	/* hunger */
	SAVE_STATE(sniper_mag);
	SAVE_STATE(chaingun_mag);
	SAVE_STATE(ap9_mag);
	SAVE_STATE(taurus_mag);

	SAVE_STATE(ammo_ap9);
	SAVE_STATE(ammo_taurus);
	SAVE_STATE(ammo_sniper);
	SAVE_STATE(ammo_gas);
	SAVE_STATE(ammo_medkit);
	SAVE_STATE(mode_silencer);
}

/*
=================
player::SendEntity
=================
*/
float
player::SendEntity(entity ePEnt, float flChanged)
{
	/* don't broadcast invisible players */
	if (IsFakeSpectator() && ePEnt != this)
		return (0);
	if (!GetModelindex() && ePEnt != this)
		return (0);

	flChanged = OptimiseChangedFlags(ePEnt, flChanged);

	WriteByte(MSG_ENTITY, ENT_PLAYER);
	WriteFloat(MSG_ENTITY, flChanged);

	NSClientPlayer::SendEntity(ePEnt, flChanged);

	if (flChanged & PLAYER_TOPFRAME) {
		WriteByte(MSG_ENTITY, anim_top);
		WriteFloat(MSG_ENTITY, anim_top_time);
		WriteFloat(MSG_ENTITY, anim_top_delay);
	}
	if (flChanged & PLAYER_BOTTOMFRAME) {
		WriteByte(MSG_ENTITY, anim_bottom);
		WriteFloat(MSG_ENTITY, anim_bottom_time);
	}

	if (flChanged & PLAYER_AMMO1) {
		WriteByte(MSG_ENTITY, glock_mag);
		WriteByte(MSG_ENTITY, mp5_mag);
		WriteByte(MSG_ENTITY, python_mag);
		WriteByte(MSG_ENTITY, shotgun_mag);
		WriteByte(MSG_ENTITY, crossbow_mag);
		WriteByte(MSG_ENTITY, rpg_mag);
		WriteByte(MSG_ENTITY, satchel_chg);

		/* hunger */
		WriteByte(MSG_ENTITY, sniper_mag);
		WriteByte(MSG_ENTITY, chaingun_mag);
		WriteByte(MSG_ENTITY, ap9_mag);
		WriteByte(MSG_ENTITY, taurus_mag);
	}

	if (flChanged & PLAYER_AMMO2) {
		WriteByte(MSG_ENTITY, ammo_9mm);
		WriteByte(MSG_ENTITY, ammo_357);
		WriteByte(MSG_ENTITY, ammo_buckshot);
		WriteByte(MSG_ENTITY, ammo_bolt);
		WriteByte(MSG_ENTITY, ammo_rocket);
		WriteByte(MSG_ENTITY, ammo_uranium);
		WriteByte(MSG_ENTITY, ammo_handgrenade);
		WriteByte(MSG_ENTITY, ammo_satchel);
		WriteByte(MSG_ENTITY, ammo_tripmine);
		WriteByte(MSG_ENTITY, ammo_snark);
		WriteByte(MSG_ENTITY, ammo_hornet);

		/* hunger */
		WriteByte(MSG_ENTITY, ammo_ap9);
		WriteByte(MSG_ENTITY, ammo_taurus);
		WriteByte(MSG_ENTITY, ammo_sniper);
		WriteByte(MSG_ENTITY, ammo_gas);
		WriteByte(MSG_ENTITY, ammo_medkit);
	}

	if (flChanged & PLAYER_AMMO3) {
		WriteByte(MSG_ENTITY, ammo_m203_grenade);
		WriteByte(MSG_ENTITY, ammo_gauss_volume);
		WriteByte(MSG_ENTITY, ammo_rpg_state);
		WriteByte(MSG_ENTITY, mode_tempstate);
		WriteByte(MSG_ENTITY, mode_silencer);
	}

	return (1);
}
#endif
