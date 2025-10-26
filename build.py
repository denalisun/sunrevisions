import os
import subprocess
import shutil
from zipfile import ZipFile

# define paths
GAME_FOLDER = r"/mnt/windows/Plutonium/bo2"
OAT_BASE = r"/home/amelia/OpenAssetTools/"
MOD_BASE = os.getcwd()
MOD_NAME = "zm_sunrevisions"

# if not os.path.exists("build"):
#     os.mkdir("build")

# if os.path.exists("./addon_mods"):
#     for f in os.listdir("./addon_mods"):
#         pth = os.path.join(os.getcwd(), "addon_mods", f)

# command for linker
linker_cmd = [
    os.path.join(OAT_BASE, "Linker"),
    "-v",
    "--load", os.path.join(GAME_FOLDER, "zone", "all", "zm_transit.ff"),
    "--load", os.path.join(GAME_FOLDER, "zone", "all", "zm_prison.ff"),
    "--load", os.path.join(GAME_FOLDER, "zone", "all", "zm_highrise.ff"),
    "--load", os.path.join(GAME_FOLDER, "zone", "all", "zm_buried.ff"),
    "--load", os.path.join(GAME_FOLDER, "zone", "all", "zm_tomb.ff"),
    "--load", os.path.join(GAME_FOLDER, "zone", "all", "zm_nuked.ff"),
    "--base-folder", OAT_BASE,
    "--asset-search-path", MOD_BASE,
    "--source-search-path", os.path.join(MOD_BASE, "zone_source"),
    "--output-folder", os.path.join(MOD_BASE, "zone"),
    "mod"
]

# run linker
result = subprocess.run(linker_cmd)
err = result.returncode

# zip files
if os.path.exists("mod.iwd"):
    os.remove("mod.iwd")

with ZipFile("mod.iwd", 'w') as zipf:
    for folder in ["scripts", "ui_mp", "weapons", "xanim", "clientscripts", "sound"]:
        if os.path.isdir(folder):
            for root, _, files in os.walk(folder):
                for file in files:
                    full_path = os.path.join(root, file)
                    arcname = os.path.relpath(full_path, MOD_BASE)
                    zipf.write(full_path, arcname)

# copy output if linker succeeded
if err == 0:
    print("Linking succeeded. Copying files...")
    MOD_FOLDER = os.path.join("/home/amelia/Games/plutonium_prefix/drive_c/users/amelia/AppData/Local", "Plutonium", "storage", "t6", "mods", MOD_NAME)
    os.makedirs(MOD_FOLDER, exist_ok=True)

    shutil.copy(os.path.join(MOD_BASE, "zone", "mod.ff"), os.path.join(MOD_FOLDER, "mod.ff"))
    shutil.copy(os.path.join(MOD_BASE, "mod.iwd"), os.path.join(MOD_FOLDER, "mod.iwd"))
    shutil.copy(os.path.join(MOD_BASE, "zone", "mod.all.sabl"), os.path.join(MOD_FOLDER, "mod.all.sabl"))
    shutil.copy(os.path.join(MOD_BASE, "mod.json"), os.path.join(MOD_FOLDER, "mod.json"))
else:
    print("FAIL!")
