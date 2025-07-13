import os, shutil, json

bo2_path = r"D:\OpenAssetTools\zone_dump\zone_raw"
zones = ["zm_transit", "zm_nuked", "zm_highrise", "zm_buried", "zm_prison", "zm_tomb"]

all_weapons = json.load(open('./weaponlist.json'))
documented = []
for weapon in all_weapons:
    if weapon not in documented:
        for zone in zones:
            zonepath = os.path.join(bo2_path, zone)
            weaponn = os.path.join(zonepath, "weapons", weapon)
            if os.path.isfile(weaponn):
                print(f"weapon: {weapon} // zone: {zone}")
                shutil.copyfile(weaponn, f"./{weapon}")
                documented.append(weapon)
                break