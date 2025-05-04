import os, zipfile, shutil, json

os.ar

LAD = os.getenv("LOCALAPPDATA")
modpath = os.path.join(LAD, "Plutonium\\storage\\t6\\mods\\zm_overhaul")

if os.path.isdir("dist"):
    shutil.rmtree("dist")

if os.path.isdir(modpath):
    shutil.rmtree(modpath)

shutil.copytree("src", "dist\\intermediate")
if os.path.isdir("zm_weapons"):
    with zipfile.ZipFile("zm_weapons\\mod.iwd", 'r') as zip_ref:
        zip_ref.extractall("dist\\intermediate")
    shutil.copy("zm_weapons\\mod.ff", "dist\\mod.ff")
    shutil.copy("zm_weapons\\mod.all.sabl", "dist\\mod.all.sabl")

with zipfile.ZipFile("dist\\mod.iwd", 'w', zipfile.ZIP_DEFLATED) as zipf:
    for root, dirs, files in os.walk("dist\\intermediate"):
        for file in files:
            full_path = os.path.join(root, file)
            relative_path = os.path.relpath(full_path, "dist\\intermediate")
            zipf.write(full_path, arcname=relative_path)

modconfig = {
	"name": "^3 -- Sun's Overhaul --",
	"author": "denalisun",
	"description": "Overhauls Black Ops 2 mechanics.",
	"version": "1.0.0"
}
json.dump(modconfig, open('dist\\mod.json', 'w'))
shutil.rmtree("dist\\intermediate")
shutil.copytree("dist", modpath)