// TODO::
// - Change perk limit [D]
// - Change start points [D]
// - Disable lava damage for zombies []
// - Change HUD layout (Perks to center-middle) []

init() {
    thread remove_perk_limit();
    for (;;) {
        level waittill("connected", player);
        player thread onPlayerConnected();
    }
}

remove_perk_limit() {
    level waittill("start_of_round");
    level.perk_purchase_limit = 9;
}

onPlayerConnected() {
    self endon("disconnect");
    self.score = 1000; // spawn with 1k points

    self waittill("spawned_player");
}