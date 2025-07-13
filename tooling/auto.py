import os, shutil, json

bo2_path = r"D:\OpenAssetTools\zone_dump\zone_raw"
zones = ["zm_transit", "zm_nuked", "zm_highrise", "zm_buried", "zm_prison", "zm_tomb"]

all_weapons = []
for zone in zones:
    weapon_folder = os.path.join(bo2_path, zone, "weapons")
    for weapon in os.listdir(weapon_folder):
        if weapon not in all_weapons:
            all_weapons.append(weapon)

with open('weaponlist.json', 'w') as f:
    json.dump(all_weapons, f, indent=4)
    f.close()