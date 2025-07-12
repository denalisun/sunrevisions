import os, shutil, sys, json

weaponfile = "./weaponfile"
if (len(sys.argv) > 1):
    weaponfile = sys.argv[1]

weapon_dictionary = {}
all_sounds_used = []

for file in os.listdir("."):
    if os.path.isfile(file):
        (name, ext) = os.path.splitext(file)
        if not ext:
            with open(os.path.join(".", file)) as f:
                read = f.read().replace("WEAPONFILE\\", "")
                
                currentProperty = ""
                propValue = ""
                isInProperty = False
                
                for char in read:
                    if char == "\\":
                        if isInProperty:
                            weapon_dictionary[currentProperty.strip("\\")] = propValue.strip("\\")
                            currentProperty, propValue = "", ""
                            isInProperty = False
                        elif not isInProperty:
                            isInProperty = True

                    if isInProperty:
                        propValue += char
                    elif not isInProperty:
                        currentProperty += char

                for prop in weapon_dictionary:
                    if f"{prop}".lower().find("sound") > 0:
                        if weapon_dictionary[prop] not in all_sounds_used:
                            all_sounds_used.append(weapon_dictionary[prop])

#print(all_sounds_used)

all_soundbanks = []
bo2_path = r"D:\OpenAssetTools\zone_dump\zone_raw"
zones = ["zm_transit_dr", "zm_nuked", "zm_prison", "zm_buried", "zm_highrise", "zm_tomb"]
for zone in zones:
    zone_path = os.path.join(bo2_path, zone)
    if os.path.isdir(zone_path):
        soundbanks_path = os.path.join(zone_path, "soundbank")
        if os.path.isdir(soundbanks_path):
            for bank in os.listdir(soundbanks_path):
                if bank.endswith(".all.aliases.csv"):
                    all_soundbanks.append(os.path.join(soundbanks_path, bank))

sounds_documented = []
soundbank_lines = []
for soundbank in all_soundbanks:
    with open(soundbank, 'r') as bank:
        for line in bank.readlines():
            sound_entry = line.split(',')[0]
            if sound_entry in all_sounds_used and sound_entry not in sounds_documented:
                sounds_documented.append(sound_entry)
                soundbank_lines.append(line)

with open("../soundbank/mod.all.aliases.csv", 'w') as mod_bank:
    for line in soundbank_lines:
        mod_bank.write(line)