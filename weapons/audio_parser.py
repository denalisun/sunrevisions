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

print(all_sounds_used)