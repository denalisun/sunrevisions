#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_magicbox_lock;
#include maps\mp\zombies\_zm_magicbox;
#include maps\mp\zombies\_zm_unitrigger;
#include maps\mp\zombies\_zm_audio_announcer;
#include maps\mp\zombies\_zm_pers_upgrades_functions;
#include maps\mp\zombies\_zm_score;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\_demo;
#include maps\mp\zombies\_zm_stats;

round_watcher() {
    level endon("end_game");

    if (!isdefined(level.raygun_ee))
        level.raygun_ee = false;

    for (;;) {
        level waittill("end_of_round");
        if (level.round_number == 16) {
            level thread raygun_watcher();
        }
    }
}

raygun_watcher() {
    level.raygun_ee = true;
    level waittill("start_of_round");
    level.raygun_ee = false;
}