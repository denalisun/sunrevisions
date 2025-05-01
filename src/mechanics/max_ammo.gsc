max_ammo_fix() {
    level endon("end_game");
    for (;;) {
        self waittill("zmb_max_ammo");

        primary_weapons = self getweaponslist(1);
        foreach (weapon in primary_weapons) {
            if (self hasweapon(weapon))
                self SetWeaponAmmoClip(weapon, 150);
        }
    }
}