#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_net;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\zombies\_zm_ai_basic;
#include maps\mp\animscripts\zm_utility;
#include maps\mp\animscripts\zm_shared;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\zombies\_zm_blockers;
#include maps\mp\animscripts\zm_death;
#include maps\mp\animscripts\zm_run;
#include maps\mp\zombies\_zm_powerups;
#include maps\mp\zombies\_zm_score;
#include maps\mp\zombies\_zm_pers_upgrades;
#include maps\mp\zombies\_zm_stats;
#include maps\mp\zombies\_zm_pers_upgrades_functions;
#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_spawner;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_ai_faller;

difficulty_handler() {
    level endon("end_game");

    difficulty = level.sunmod_vars["difficulty"];
    if (difficulty > 3)
        difficulty = 3; // This should never happen but im making sure it doesn't

    for (;;) {
        level waittill("start_of_round");
        if (difficulty == 0) {
            if (level.zombie_total > 35)
                level.zombie_total = 35;
        } else if (difficulty == 1) {
            if (level.zombie_total > 59)
                level.zombie_total = 59;    
        }
        
        if (difficulty == 3)
            level.zombie_move_speed = 71;
    }
}

ai_calculate_health__override( round_number )
{
    level.zombie_health = level.zombie_vars["zombie_health_start"];

    for ( i = 2; i <= round_number; i++ )
    {
        if ( i >= 10 )
        {
            old_health = level.zombie_health;
            level.zombie_health = level.zombie_health + int( level.zombie_health * level.zombie_vars["zombie_health_increase_multiplier"] );

            if ( level.zombie_health < old_health )
            {
                level.zombie_health = old_health;
                return;
            }
        }
        else
            level.zombie_health = int( level.zombie_health + level.zombie_vars["zombie_health_increase"] );
    }

    if (level.sunmod_vars["difficulty"] == 0)
    {
        level.zombie_health = int(level.zombie_health * 0.75);
        if (level.zombie_health > 8454)
            level.zombie_health = 8454; // round 35 health cap
    }
    else if (level.sunmod_vars["difficulty"] == 1)
        if (level.zombie_health > 11272)
            level.zombie_health = 11272; // round 35 health cap
    else if (level.sunmod_vars["difficulty"] == 2)
        level.zombie_health += int(level.zombie_health * 0.25);
    else if (level.sunmod_vars["difficulty"] == 3)
        level.zombie_health += int(level.zombie_health * 0.5);
}