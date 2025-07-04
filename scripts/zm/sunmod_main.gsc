#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_perks;
#include maps\mp\zombies\_zm_spawner;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_magicbox;

#include scripts\zm\mechanics\custom_hud;
#include scripts\zm\mechanics\round_salary;
#include scripts\zm\mechanics\no_perk_limit;
#include scripts\zm\mechanics\difficulty;
#include scripts\zm\mechanics\max_ammo;
#include scripts\zm\mechanics\weapons\pack_a_punch;

#include scripts\zm\_sunmod_utils;

#include scripts\zm\mechanics\custom_perks;
#include scripts\zm\mechanics\aspects;

#include scripts\zm\easter_eggs\raygun_round;

main() {
    //precacheshader("sigmasigmaboi"); // this might make me mental
    precacheshader("damage_feedback");
    precacheshader( "zombies_rank_3" );
    precacheshader( "zombies_rank_5" );

    precachemodel( "zombie_vending_tombstone_on" );

    init_sunmod_vars();

    replacefunc(::give_perk, ::give_perk_modified);
    replacefunc(::ai_calculate_health, ::ai_calculate_health__override);
    replacefunc(::vending_weapon_upgrade, ::vending_weapon_upgrade__override);
    replacefunc(::can_pack_weapon, ::can_pack_weapon__override);
    replacefunc(::treasure_chest_weapon_spawn, ::treasure_chest_weapon_spawn__override);

    maps\mp\zombies\_zm_spawner::register_zombie_damage_callback(::tier_damage_callback);

    maps\mp\zombies\_zm_spawner::register_zombie_damage_callback(::do_hitmarker);
    maps\mp\zombies\_zm_spawner::register_zombie_death_event_callback(::do_hitmarker_death);
}

init() {
    level thread remove_perk_limit();
    level thread difficulty_handler();
    level thread round_salary();
    level thread on_player_connected();

    level thread init_perks();
    level thread spawn_aspect_machine((1659.95, -544.765, -42.1959), (0, 180, 0), "mus_perks_sleight_sting", "doubletap_light");

    // Easter eggs
    level thread round_watcher();

    level.local_doors_stay_open = 1;
}

say_pos() {
    level endon("end_game");
    for (;;) {
        self iprintln("Position: " + self.origin + "\nAngle: " + self.angles);
        wait 1;
    }
}

on_player_connected() {
    level endon("end_game");
    for (;;) {
        level waittill("connected", player);
        player thread on_player_spawned();
        player thread max_ammo_fix();
        player thread player_downed_watcher();
        player thread weapon_tier_watcher();

        player thread say_pos();

        if (!isdefined(player.hud_damagefeedback))
            player thread init_player_hitmarkers();

        player setperk("specialty_unlimitedsprint");
    }
}

on_player_spawned() {
    self endon("disconnect");
    level endon("end_game");
    for (;;) {
        self waittill("spawned_player");
        if (level.sunmod_vars["difficulty"] < 2)
            self.score = 1000;
        
        // debug for now
        self.score = 999999;
    }
}