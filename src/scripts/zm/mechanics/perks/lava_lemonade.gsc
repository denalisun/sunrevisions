#include scripts\zm\mechanics\custom_perks;

init_perk() {
    register_new_perk("Lava Lemonade", "specialty_custom_lavadamage", "zombie_vending_doubletap2_on", "doubletap_light", "zombie_perk_bottle_doubletap", 6000, "zombies_rank_3", ::lavalemonade_func, undefined, (1731.77, -802.512, -54.4511), (0, 300, 0));
}

lavalemonade_func() {
    level endon("end_game");
    for (;;) {
        self.ignore_lava_damage = 1;
        self waittill("player_downed");
        self.ignore_lava_damage = 0;
        break;
    }
}