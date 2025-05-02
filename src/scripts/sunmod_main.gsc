#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_perks;
#include maps\mp\zombies\_zm_spawner;

#include scripts\mechanics\custom_hud;
#include scripts\mechanics\round_salary;
#include scripts\mechanics\no_perk_limit;
#include scripts\mechanics\difficulty;
#include scripts\mechanics\max_ammo;
#include scripts\mechanics\pack_a_punch;

#include scripts\_sunmod_utils;

main() {
    init_sunmod_vars();

    replacefunc(::give_perk, ::give_perk_modified);
    replacefunc(::ai_calculate_health, ::ai_calculate_health__override);
    replacefunc(::vending_weapon_upgrade, ::vending_weapon_upgrade__override);

    maps\mp\zombies\_zm_spawner::register_zombie_damage_callback(::tier_damage_callback);
}

init() {
    level thread remove_perk_limit();
    level thread difficulty_handler();
    level thread round_salary();
    level thread on_player_connected();

    level.local_doors_stay_open = 1;
    level.start_weapon = "an94_upgraded_zm";
}

on_player_connected() {
    level endon("end_game");
    for (;;) {
        level waittill("connected", player);
        player thread on_player_spawned();
        player thread max_ammo_fix();
        player thread player_downed_watcher();
        player thread weapon_tier_watcher();
        player setperk("specialty_unlimitedsprint");
    }
}

on_player_spawned() {
    self endon("disconnect");
    level endon("end_game");
    for (;;) {
        self waittill("spawned_player");
        self.score = 999999;
    }
}