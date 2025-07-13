import os, shutil, sys

weapons_path = os.path.realpath(os.path.join(os.getcwd(), "..\\weapons"))
all_weapons = os.listdir(weapons_path)

with open('weapons.gsc', 'w') as f:
    for weapon in all_weapons:
        is_upgraded = weapon.find("_upgraded_") != -1
        
        if is_upgraded:
            f.write(f'include_weapon("{weapon}", 0);\n')
        else:
            f.write(f'include_weapon("{weapon}");\n');