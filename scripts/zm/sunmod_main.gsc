#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_perks;
#include maps\mp\zombies\_zm_spawner;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_magicbox;

#include maps\mp\zombies\_zm_ffotd;

#include maps\mp\_visionset_mgr;
#include maps\mp\zombies\_zm_devgui;
#include maps\mp\zombies\_zm_zonemgr;
#include maps\mp\zombies\_zm_unitrigger;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\zombies\_zm_blockers;
#include maps\mp\zombies\_zm_bot;
#include maps\mp\zombies\_zm_clone;
#include maps\mp\zombies\_zm_buildables;
#include maps\mp\zombies\_zm_equipment;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\zombies\_zm_playerhealth;
#include maps\mp\zombies\_zm_power;
#include maps\mp\zombies\_zm_powerups;
#include maps\mp\zombies\_zm_score;
#include maps\mp\zombies\_zm_gump;
#include maps\mp\zombies\_zm_timer;
#include maps\mp\zombies\_zm_traps;
#include maps\mp\zombies\_zm_tombstone;
#include maps\mp\zombies\_zm_stats;
#include maps\mp\zombies\_zm_pers_upgrades;
#include maps\mp\gametypes_zm\_zm_gametype;
#include maps\mp\zombies\_zm_pers_upgrades_functions;
#include maps\mp\_demo;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\zombies\_zm_melee_weapon;
#include maps\mp\zombies\_zm_ai_dogs;
#include maps\mp\zombies\_zm_pers_upgrades_system;
#include maps\mp\gametypes_zm\_weapons;
#include maps\mp\zombies\_zm_ai_basic;
#include maps\mp\zombies\_zm_game_module;

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

    replacefunc(::give_perk, ::give_perk_modified);
    replacefunc(::ai_calculate_health, ::ai_calculate_health__override);
    replacefunc(::vending_weapon_upgrade, ::vending_weapon_upgrade__override);
    replacefunc(::can_pack_weapon, ::can_pack_weapon__override);
    replacefunc(::treasure_chest_weapon_spawn, ::treasure_chest_weapon_spawn__override);

    replacefunc(::init_levelvars, ::init_levelvars__override);

    maps\mp\zombies\_zm_spawner::register_zombie_damage_callback(::tier_damage_callback);
    maps\mp\zombies\_zm_spawner::register_zombie_damage_callback(::aspect_bloodlust_damagecallback);

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

    //level thread init_sunmod_vars();

    // Easter eggs
    level thread round_watcher();

    level.local_doors_stay_open = 1;
}

init_levelvars__override()
{
    level.is_zombie_level = 1;
    level.laststandpistol = "m1911_zm";
    level.default_laststandpistol = "m1911_zm";
    level.default_solo_laststandpistol = "m1911_upgraded_zm";
    level.start_weapon = "m1911_zm";
    level.first_round = 1;
    level.start_round = getgametypesetting( "startRound" );
    level.round_number = level.start_round;
    level.enable_magic = getgametypesetting( "magic" );
    level.headshots_only = getgametypesetting( "headshotsonly" );
    level.player_starting_points = level.round_number * 500;
    level.round_start_time = 0;
    level.pro_tips_start_time = 0;
    level.intermission = 0;
    level.dog_intermission = 0;
    level.zombie_total = 0;
    level.total_zombies_killed = 0;
    level.hudelem_count = 0;
    level.zombie_spawn_locations = [];
    level.zombie_rise_spawners = [];
    level.current_zombie_array = [];
    level.current_zombie_count = 0;
    level.zombie_total_subtract = 0;
    level.destructible_callbacks = [];
    level.zombie_vars = [];

    foreach ( team in level.teams )
        level.zombie_vars[team] = [];

    difficulty = 1;
    column = int( difficulty ) + 1;
    set_zombie_var( "zombie_health_increase", 100, 0, column );
    set_zombie_var( "zombie_health_increase_multiplier", 0.1, 1, column );
    set_zombie_var( "zombie_health_start", 150, 0, column );
    set_zombie_var( "zombie_spawn_delay", 2.0, 1, column );
    set_zombie_var( "zombie_new_runner_interval", 10, 0, column );
    set_zombie_var( "zombie_move_speed_multiplier", 8, 0, column );
    set_zombie_var( "zombie_move_speed_multiplier_easy", 2, 0, column );
    set_zombie_var( "zombie_max_ai", 24, 0, column );
    set_zombie_var( "zombie_ai_per_player", 6, 0, column );
    set_zombie_var( "below_world_check", -1000 );
    set_zombie_var( "spectators_respawn", 1 );
    set_zombie_var( "zombie_use_failsafe", 1 );
    set_zombie_var( "zombie_between_round_time", 10 );
    set_zombie_var( "zombie_intermission_time", 15 );
    set_zombie_var( "game_start_delay", 0, 0, column );
    set_zombie_var( "penalty_no_revive", 0.1, 1, column );
    set_zombie_var( "penalty_died", 0.0, 1, column );
    set_zombie_var( "penalty_downed", 0.05, 1, column );
    set_zombie_var( "starting_lives", 1, 0, column );
    set_zombie_var( "zombie_score_kill_4player", 50 );
    set_zombie_var( "zombie_score_kill_3player", 50 );
    set_zombie_var( "zombie_score_kill_2player", 50 );
    set_zombie_var( "zombie_score_kill_1player", 50 );
    set_zombie_var( "zombie_score_kill_4p_team", 30 );
    set_zombie_var( "zombie_score_kill_3p_team", 35 );
    set_zombie_var( "zombie_score_kill_2p_team", 45 );
    set_zombie_var( "zombie_score_kill_1p_team", 0 );
    set_zombie_var( "zombie_score_damage_normal", 10 );
    set_zombie_var( "zombie_score_damage_light", 10 );
    set_zombie_var( "zombie_score_bonus_melee", 80 );
    set_zombie_var( "zombie_score_bonus_head", 50 );
    set_zombie_var( "zombie_score_bonus_neck", 20 );
    set_zombie_var( "zombie_score_bonus_torso", 10 );
    set_zombie_var( "zombie_score_bonus_burn", 10 );
    set_zombie_var( "zombie_flame_dmg_point_delay", 500 );
    set_zombie_var( "zombify_player", 0 );

    if ( issplitscreen() )
        set_zombie_var( "zombie_timer_offset", 280 );

    level thread init_player_levelvars();
    level.gamedifficulty = 1;

    if ( level.gamedifficulty == 0 )
        level.zombie_move_speed = level.round_number * level.zombie_vars["zombie_move_speed_multiplier_easy"];
    else
        level.zombie_move_speed = level.round_number * level.zombie_vars["zombie_move_speed_multiplier"];

    if ( level.round_number == 1 )
        level.zombie_move_speed = 1;
    else
    {
        for ( i = 1; i <= level.round_number; i++ )
        {
            timer = level.zombie_vars["zombie_spawn_delay"];

            if ( timer > 0.08 )
            {
                level.zombie_vars["zombie_spawn_delay"] = timer * 0.95;
                continue;
            }

            if ( timer < 0.08 )
                level.zombie_vars["zombie_spawn_delay"] = 0.08;
        }
    }

    level.speed_change_max = 0;
    level.speed_change_num = 0;
}

on_player_connected() {
    level endon("end_game");
    for (;;) {
        level waittill("connected", player);
        player thread on_player_spawned();
        player thread max_ammo_fix();
        player thread player_downed_watcher();
        player thread weapon_tier_watcher();

        //player thread say_pos();

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
    }
}