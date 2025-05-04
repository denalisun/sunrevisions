#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_magicbox;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\zombies\_zm_power;
#include maps\mp\zombies\_zm_pers_upgrades_functions;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\_demo;
#include maps\mp\zombies\_zm_stats;
#include maps\mp\zombies\_zm_score;
#include maps\mp\zombies\_zm_chugabud;
#include maps\mp\_visionset_mgr;
#include maps\mp\zombies\_zm_perks;
#include maps\mp\zombies\_zm;
#include scripts\zm\mechanics\custom_hud;
#include scripts\zm\_sunmod_utils;
#include scripts\zm\mechanics\weapons\pack_a_punch;

danger_closest() {
    level endon("end_game");
    for (;;) {

    }
}
electric_shock() {
    level endon("end_game");
    for (;;) {

    }
}

thunder_strike() {
    level endon("end_game");
    for (;;) {

    }
}

stock_option() {
    level endon("end_game");
    for (;;) {

    }
}

ammo_matic() {
    level endon("end_game");
    for (;;) {
        wait 1;
        current_weapon = self GetCurrentWeapon();
        current_stock = self GetWeaponAmmoStock(current_weapon);
        self SetWeaponAmmoStock(current_weapon, current_stock + 5);
    }
}