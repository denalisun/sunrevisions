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
#include scripts\zm\custom_perks;
#include scripts\zm\_sunmod_utils;
#include scripts\zm\mechanics\custom_hud;

spawn_aspect_machine(pos, angles, sound, fx) {
    perkmachine = spawn( "script_model", pos);
	perkmachine setmodel( "zombie_vending_tombstone_on" );
	perkmachine.angles = angles;
	perkmachine.script_noteworthy = "sun_aspectmachine";
	collision= spawn( "script_model", pos );
	collision setmodel( "collision_geo_32x32x128_standard" );
	collision.angles = angles;
    level.aspect_machine_trigger = spawn_trigger(pos, 32, 32, "HINT_ACTIVATE", "PLACEHOLDER");
    perkmachine thread play_fx( fx );
    level.aspect_machine_trigger thread aspect_machine_trigger("sun_aspectmachine", sound, 10000);
}

get_aspect_name() {
    if (!isdefined(self.selected_aspect_in_machine))
        self.selected_aspect_in_machine = "ws_siphon";
    
    if (self.selected_aspect_in_machine == "ws_siphon")
        return "Bloodlust";
    else if (self.selected_aspect_in_machine == "ws_firerate")
        return "Double Tap Frenzy";
    else if (self.selected_aspect_in_machine == "ws_reload")
        return "Speed Cola Frenzy";
    else if (self.selected_aspect_in_machine == "ws_stockammo")
        return "Stock Option";
    else if (self.selected_aspect_in_machine == "ws_ammoregen")
        return "Amm-o-Matic";

    return "Bloodlust";
}

switch_aspect() {
    if (!isdefined(self.selected_aspect_in_machine))
        self.selected_aspect_in_machine = "ws_siphon";

    if (self.selected_aspect_in_machine == "ws_siphon")
        self.selected_aspect_in_machine = "ws_firerate";
    else if (self.selected_aspect_in_machine == "ws_firerate")
        self.selected_aspect_in_machine = "ws_reload";
    else if (self.selected_aspect_in_machine == "ws_reload")
        self.selected_aspect_in_machine = "ws_stockammo";
    else if (self.selected_aspect_in_machine == "ws_stockammo")
        self.selected_aspect_in_machine = "ws_ammoregen";
    else if (self.selected_aspect_in_machine == "ws_ammoregen")
        self.selected_aspect_in_machine = "ws_siphon";

    self iprintln(self.selected_aspect_in_machine);
}

aspect_machine_trigger(perkId, sound, cost) {
    level endon("end_game");
    for (;;) {
        //TODO: Perk stuff
        self waittill("trigger", player);

        aspect_name = player get_aspect_name();
        level.aspect_machine_trigger sethintstring("Hold ^3&&1^7 for " + aspect_name + " [Cost: 10000]");
        
        if (player MeleeButtonPressed() && player.aspect_scroll == 0)
            player thread aspect_machine_scroll_thread();

        if (player UseButtonPressed() && player.aspect_used != player.selected_aspect_in_machine && player.score >= cost && !player maps\mp\zombies\_zm_laststand::player_is_in_laststand()) {
            player.aspect_used = player.selected_aspect_in_machine;
            player iprintln(player.aspect_used);
            player.score -= cost;
            player playsound(sound);
            
            player aspect_functionality();
        }
        
        if (player UseButtonPressed() && player.score < cost)
            player maps\mp\zombies\_zm_audio::create_and_play_dialog("general", "perk_deny", undefined, 0);
    }
}

aspect_machine_scroll_thread() {
    self.aspect_scroll = 1;
    self switch_aspect();
    wait 1.2;
    self.aspect_scroll = 0;
}

play_fx( fx )
{
	playfxontag( level._effect[ fx ], self, "tag_origin" );
}

// Functionality

reset_all_dvar_aspects() {
    self setclientdvar("perk_weapRateMultiplier", 0.75);
    self setclientdvar("perk_weapReloadMultiplier", 0.5);
}

aspect_functionality() {
    self reset_all_dvar_aspects();
    switch (self.aspect_used) {
    case "ws_firerate":
        self setclientdvar("perk_weapRateMultiplier", 0.55);
        break;
    case "ws_reload":
        self setclientdvar("perk_weapReloadMultiplier", 0.33);
        break;
    case "ws_ammoregen":
        self thread aspect_ammomatic();
        break;
    };
}

aspect_ammomatic() {
    self endon("disconnect");
    level endon("end_game");
    for (;;) {
        if (self.aspect_used != "ws_ammoregen")
            break;
        
        current_weapon = self GetCurrentWeapon();
        weapons_list = self GetWeaponsList();
        foreach (weapon in weapons_list) {
            if (weapon != current_weapon) {
                stock = self GetWeaponAmmoStock(weapon);
                self SetWeaponAmmoStock(weapon, stock + 1);
            }
        }

        wait 1;
    }
}

aspect_bloodlust_damagecallback(mod, hit_location, hit_origin, attacker, amount) {
    if (isdefined(self.damageweapon)) {
        if (isdefined(attacker) && isplayer(attacker)) {
            if (attacker.aspect_used == "ws_siphon") {
                attacker.health += 5;
            }
        }
    }
    return 0;
}