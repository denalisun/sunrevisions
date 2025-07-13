import os, shutil, sys, json

weaponfile = "./weaponfile"
if (len(sys.argv) > 1):
    weaponfile = sys.argv[1]

weapon_dictionary = {}
all_sounds_used = []

all_weapons = []
weapon_codenames = []
chud = []
for file in os.listdir("."):
    if os.path.isfile(file):
        (name, ext) = os.path.splitext(file)
        if not ext:
            stripped_name = name.replace("_zm", "").replace("_upgraded", "")
            if stripped_name not in all_weapons:
                all_weapons.append(stripped_name)
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

                codename_prefix = '_'.join(weapon_dictionary["fireSound"].split('_')[1:2])
                if codename_prefix not in weapon_codenames and codename_prefix != "":
                    weapon_codenames.append(codename_prefix)

                for prop in weapon_dictionary:
                    if f"{prop}".lower().find("sound") > 0:
                        if weapon_dictionary[prop] not in all_sounds_used:
                            all_sounds_used.append(weapon_dictionary[prop])

all_soundbanks = []
bo2_path = r"C:\OpenAssetTools\zone_dump\zone_raw"
zones = os.listdir(bo2_path)
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
            
            for codename in weapon_codenames:
                if sound_entry.startswith(f"wpn_{codename}") or sound_entry.startswith(f"fly_{codename}"):
                    sounds_documented.append(sound_entry)
                    soundbank_lines.append(line)
            

sound_paths = []
with open("../soundbank/mod.all.aliases.csv", 'w') as mod_bank:
    mod_bank.write("Name,FileSource,Secondary,Storage,Bus,VolumeGroup,DuckGroup,Duck,ReverbSend,CenterSend,VolMin,VolMax,DistMin,DistMaxDry,DistMaxWet,DryMinCurve,DryMaxCurve,WetMinCurve,WetMaxCurve,LimitCount,EntityLimitCount,LimitType,EntityLimitType,PitchMin,PitchMax,PriorityMin,PriorityMax,PriorityThresholdMin,PriorityThresholdMax,PanType,Pan,Looping,RandomizeType,Probability,StartDelay,EnvelopMin,EnvelopMax,EnvelopPercent,OcclusionLevel,IsBig,DistanceLpf,FluxType,FluxTime,Subtitle,Doppler,ContextType,ContextValue,Timescale,IsMusic,IsCinematic,FadeIn,FadeOut,Pauseable,StopOnEntDeath,StopOnPlay,DopplerScale,FutzPatch,VoiceLimit,IgnoreMaxDist,NeverPlayTwice\n")
    for line in soundbank_lines:
        mod_bank.write(line.replace(".LN65.pc.snd.wav", ".wav").replace(".LN65.pc.snd", ".wav"))
        split = line.split(',')[1]
        if split not in sound_paths:
            sound_paths.append(split)

sound_dump_path = r"C:\Greyhound\exported_files\black_ops_2\sounds"
new_path = r"C:\Users\Aurora\Programming\GSC\PlutoServer\sounds"
for path in sound_paths:
    split = path.split('.')[0]
    wav = split + ".wav"
    new_sound = os.path.join(new_path, wav)
    sound_path = os.path.join(sound_dump_path, wav)
    if os.path.exists(sound_path):
        os.makedirs(os.path.dirname(new_sound), exist_ok=True)
        shutil.copy(sound_path, new_sound)