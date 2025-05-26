#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_stats;
#include maps\mp\gametypes_zm\_spawnlogic;
#include maps\mp\animscripts\traverse\shared;
#include maps\mp\animscripts\utility;
#include maps\mp\zombies\_load;
#include maps\mp\_createfx;
#include maps\mp\_music;
#include maps\mp\_busing;
#include maps\mp\_script_gen;
#include maps\mp\gametypes_zm\_globallogic_audio;
#include maps\mp\gametypes_zm\_tweakables;
#include maps\mp\_challenges;
#include maps\mp\gametypes_zm\_weapons;
#include maps\mp\_demo;
#include maps\mp\gametypes_zm\_spawning;
#include maps\mp\gametypes_zm\_globallogic_utils;
#include maps\mp\gametypes_zm\_spectating;
#include maps\mp\gametypes_zm\_globallogic_spawn;
#include maps\mp\gametypes_zm\_globallogic_ui;
#include maps\mp\gametypes_zm\_hostmigration;
#include maps\mp\gametypes_zm\_globallogic_score;
#include maps\mp\gametypes_zm\_globallogic;
#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_ai_faller;
#include maps\mp\zombies\_zm_spawner;
#include maps\mp\zombies\_zm_pers_upgrades_functions;
#include maps\mp\zombies\_zm_pers_upgrades;
#include maps\mp\zombies\_zm_score;
#include maps\mp\animscripts\zm_run;
#include maps\mp\animscripts\zm_death;
#include maps\mp\zombies\_zm_blockers;
#include maps\mp\animscripts\zm_shared;
#include maps\mp\animscripts\zm_utility;
#include maps\mp\zombies\_zm_ai_basic;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\zombies\_zm_net;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\gametypes_zm\_zm_gametype;
#include maps\mp\_visionset_mgr;
#include maps\mp\zombies\_zm_equipment;
#include maps\mp\zombies\_zm_power;
#include maps\mp\zombies\_zm_server_throttle;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\zombies\_zm_unitrigger;
#include maps\mp\zombies\_zm_zonemgr;
#include maps\mp\zombies\_zm_perks;
#include maps\mp\zombies\_zm_melee_weapon;
#include maps\mp\zombies\_zm_audio_announcer;
#include maps\mp\zombies\_zm_magicbox;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_ai_dogs;
#include maps\mp\gametypes_zm\_hud_message;
#include maps\mp\zombies\_zm_game_module;
#include maps\mp\zombies\_zm_buildables;
#include codescripts\character;
#include maps\mp\zombies\_zm_weap_riotshield;
#include maps\mp\zombies\_zm_ai_sloth;
#include maps\mp\zombies\_zm_ai_sloth_ffotd;
#include maps\mp\zombies\_zm_ai_sloth_utility;
#include maps\mp\zombies\_zm_ai_sloth_magicbox;
#include maps\mp\zombies\_zm_ai_sloth_crawler;
#include maps\mp\zombies\_zm_ai_sloth_buildables;

#include scripts\zm\_sunmod_utils;
#include scripts\zm\mechanics\custom_hud;

spawn_perk_machine(pos, model, angles, type, sound, name, cost, fx, perk, bottle) {
    perkmachine = spawn( "script_model", pos);
	perkmachine setmodel( model );
	perkmachine.angles = angles;
	perkmachine.script_noteworthy = perk;
	collision= spawn( "script_model", pos );
	collision setmodel( "collision_geo_32x32x128_standard" );
	collision.angles = angles;
    trig = spawn_trigger(pos, 32, 32, "HINT_ACTIVATE", "Hold ^3&&1^7 for " + name + " [Cost: " + cost + "]");
    perkmachine thread play_fx(fx);
    trig thread perk_machine_trigger(perk, sound, bottle, cost);
    return trig;
}

hascustomperk(perkId) {    
    if (!isdefined(self.custom_perk_list))
        return false;
    
    foreach(perk in self.custom_perk_list)
        if (perk == perkId)
            return true;
    
    return false;
}

get_perk_by_id(perk_id) {
    if (!isdefined(level.custom_perks))
        return undefined;

    foreach(perk in level.custom_perks) {
        if (perk.perkId == perk_id)
            return perk;
    }

    return undefined;
}

perk_machine_trigger(perkId, sound, bottle, cost) {
    level endon("end_game");
    for (;;) {
        //TODO: Perk stuff
        self waittill("trigger", player);
        if (player UseButtonPressed()) {
            if (!isdefined(player.custom_perk_list))
                player.custom_perk_list = [];

            if (player.score >= cost && !player maps\mp\zombies\_zm_laststand::player_is_in_laststand() && !player hascustomperk(perkId)) {
                player.machine_is_in_use = 1;
                player playsound("zmb_cha_ching");
                player.score -= cost;
                player playsound(sound);
                player thread doallthestuff(perkId, bottle);
                player.custom_perk_list[player.custom_perk_list.size] = perkId;
                wait 4;
                player.machine_is_in_use = 0;

                perka = get_perk_by_id(perkId);
                player thread [[ perka.perkCallback ]] ();
                player thread [[ perka.perkEndCallback ]] ();
            }
        }
        
        if (player UseButtonPressed() && player.score < cost)
            player maps\mp\zombies\_zm_audio::create_and_play_dialog("general", "perk_deny", undefined, 0);
    }
}

doallthestuff(perkId, bottle) {
    self allowProne(false);
    self allowSprint(false);
    self disableoffhandweapons();
    self disableweaponcycling();
    weapona = self getcurrentweapon();
    weaponb = bottle;
    self giveweapon( weaponb );
    self switchtoweapon( weaponb );
    self waittill( "weapon_change_complete" );
    self enableoffhandweapons();
    self enableweaponcycling();
    self takeweapon( weaponb );
    self switchtoweapon( weapona );
    self maps\mp\zombies\_zm_audio::playerexert( "burp" );
    self setblur( 4, 0.1 );
    wait 0.1;
    self setblur( 0, 0.1 );
    self allowProne(true);
    self allowSprint(true);

    // Make hud
    perk_hud(perkId);
}

register_new_perk(name, perkId, model, fx, bottle, cost, shader, callback, end_callback, origin, angles) {
    if (!isdefined(level.custom_perks))
        level.custom_perks = [];

    str = spawnstruct();
    str.perkName = name;
    str.perkId = perkId;
    str.perkShader = shader;
    str.perkCallback = callback;
    str.perkEndCallback = end_callback;
    level.custom_perks[level.custom_perks.size] = str;

    spawn_perk_machine(origin, model, angles, "custom", "mus_perks_sleight_sting", name, cost, fx, perkId, bottle);
}

is_perk_registered(perkId) {
    if (!isdefined(level.custom_perks))
        return false;
    
    foreach(perk in level.custom_perks)
        if (perk == perkId)
            return true;

    return false;
}

remove_custom_perk(perkId) {
    perka = get_perk_by_id(perkId);
    if (!isdefined(perka)) return;


}

player_downed_watcher() {
	level endon("end_game");
	while(1) {
		self waittill("player_downed");
		foreach(hud in self.perk_hud) {
            self.perk_hud = [];
            self.perk_hud_array = [];
            hud destroy();
        }
        self.custom_perk_list = [];
		self notify( "stop_electric_cherry_reload_attack" );
	}
}

play_fx( fx )
{
	playfxontag( level._effect[ fx ], self, "tag_origin" );
}

init_perks() {
    scripts\zm\mechanics\perks\lava_lemonade::init_perk();
}