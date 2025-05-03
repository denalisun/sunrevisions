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
    //trig thread perk_machine_trigger(perk, sound, bottle, cost);
    return trig;
}

perk_machine_trigger(perkId, sound, bottle, cost) {
    level endon("end_game");
    for (;;) {
        //TODO: Perk stuff
    }
}

register_new_perk(name, perkId, model, fx, bottle, cost, origin, angles) {
    spawn_perk_machine(origin, model, angles, "custom", "mus_perks_sleight_sting", name, cost, fx, perkId, bottle);
}

play_fx( fx )
{
	playfxontag( level._effect[ fx ], self, "tag_origin" );
}

init_perks() {
    register_new_perk("Lava Lemonade", "specialty_custom_lavadamage", "zombie_vending_doubletap2_on", "doubletap_light", "zombie_perk_bottle_doubletap", 6000, (1731.77, -802.512, -54.4511), (0, 300, 0));
}