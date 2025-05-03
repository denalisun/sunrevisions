#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_magicbox;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\zombies\_zm_power;
#include maps\mp\zombies\_zm_pers_upgrades_functions;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\_demo;
#include maps\mp\zombies\_zm_stats;
#include maps\mp\zombies\_zm_score;
#include maps\mp\zombies\_zm_chugabud;
#include maps\mp\_visionset_mgr;
#include maps\mp\zombies\_zm_perks;
#include maps\mp\zombies\_zm;
#include scripts\zm\mechanics\custom_hud;
#include scripts\zm\_sunmod_utils;

get_current_base_weapon() {
    current_weapon = self GetCurrentWeapon();
    current_weapon = tolower(current_weapon);
    current_weapon = get_base_name(current_weapon);
    return current_weapon;
}

can_upgrade_weapon__custom( weaponname )
{
    if ( !isdefined( weaponname ) || weaponname == "" || weaponname == "zombie_fists_zm" )
        return 0;

    weaponname = tolower( weaponname );
    weaponname = get_base_name( weaponname );

    if ( !is_weapon_upgraded( weaponname ) )
        return isdefined( level.zombie_weapons[weaponname].upgrade_name );

    if ( is_weapon_upgraded( weaponname ) )
        return 1;

    if ( isdefined( level.zombiemode_reusing_pack_a_punch ) && level.zombiemode_reusing_pack_a_punch && weapon_supports_attachments( weaponname ) )
        return 1;

    return 0;
}

weapon_tier_watcher() {
    self endon("disconnect");
    level endon("end_game");
    self waittill("spawned_player");

    if (!isDefined(self.weapon_tiers))
        self.weapon_tiers = [];

    for (;;) {
        self waittill("weapon_change");

        wt_keys = GetArrayKeys(self.weapon_tiers);
        foreach(key in wt_keys) {
            if (!self HasWeapon(key))
                self.weapon_tiers[key] = undefined;
        }

        current_weapon = self GetCurrentWeapon();
        if (self HasWeapon(current_weapon)) {
            if (is_weapon_upgraded(current_weapon)) {
                if (!isdefined(self.weapon_tiers[current_weapon])) {
                    self.weapon_tiers[current_weapon] = 1;
                }
            }
            self iprintln(self.weapon_tiers[current_weapon]);
            self pap_tier_hud(self.weapon_tiers[current_weapon]);
        }
    }
}

pap_tier_hud(tier)
{
	self endon("disconnect");

    if(isdefined(self.pap_tier_hud))
		self.pap_tier_hud destroy();

	if(isDefined(tier))
	{
        self.pap_tier_hud = newClientHudElem(self);
        self.pap_tier_hud.alignx = "right";
        self.pap_tier_hud.aligny = "bottom";
        self.pap_tier_hud.horzalign = "user_right";
        self.pap_tier_hud.vertalign = "user_bottom";
        if( getdvar( "mapname" ) == "zm_transit" || getdvar( "mapname" ) == "zm_highrise" || getdvar( "mapname" ) == "zm_nuked")
        {
            self.pap_tier_hud.x = -85;
            self.pap_tier_hud.y = -22;
        }
		else if( getdvar( "mapname" ) == "zm_tomb" )
        {
            self.pap_tier_hud.x = -110;
            self.pap_tier_hud.y = -80;
        }
        else
        {
            self.pap_tier_hud.x = -160;
            self.pap_tier_hud.y = -40;
        }
        self.pap_tier_hud.archived = 1;
        self.pap_tier_hud.fontscale = 1;
        self.pap_tier_hud.alpha = 1;
        self.pap_tier_hud.color = (0.54, 0, 0);
        self.pap_tier_hud.hidewheninmenu = 1;
        self.pap_tier_hud SetText(convert_to_roman(tier));
    }
}

can_pack_weapon__override( weaponname )
{
    if ( "riotshield_zm" == weaponname )
        return false;

    if ( flag( "pack_machine_in_use" ) )
        return true;

    weaponname = self get_nonalternate_weapon( weaponname );

    if ( !maps\mp\zombies\_zm_weapons::is_weapon_or_base_included( weaponname ) )
        return false;

    return true;
}

vending_weapon_upgrade__override()
{
    level endon( "Pack_A_Punch_off" );
    wait 0.01;
    perk_machine = getent( self.target, "targetname" );
    self.perk_machine = perk_machine;
    perk_machine_sound = getentarray( "perksacola", "targetname" );
    packa_rollers = spawn( "script_origin", self.origin );
    packa_timer = spawn( "script_origin", self.origin );
    packa_rollers linkto( self );
    packa_timer linkto( self );

    if ( isdefined( perk_machine.target ) )
        perk_machine.wait_flag = getent( perk_machine.target, "targetname" );

    pap_is_buildable = self is_buildable();

    if ( pap_is_buildable )
    {
        self trigger_off();
        perk_machine hide();

        if ( isdefined( perk_machine.wait_flag ) )
            perk_machine.wait_flag hide();

        wait_for_buildable( "pap" );
        self trigger_on();
        perk_machine show();

        if ( isdefined( perk_machine.wait_flag ) )
            perk_machine.wait_flag show();
    }

    self usetriggerrequirelookat();
    self sethintstring( &"ZOMBIE_NEED_POWER" );
    self setcursorhint( "HINT_NOICON" );
    power_off = !self maps\mp\zombies\_zm_power::pap_is_on();

    if ( power_off )
    {
        pap_array = [];
        pap_array[0] = perk_machine;
        level thread do_initial_power_off_callback( pap_array, "packapunch" );
        level waittill( "Pack_A_Punch_on" );
    }

    self enable_trigger();

    if ( isdefined( level.machine_assets["packapunch"].power_on_callback ) )
        perk_machine thread [[ level.machine_assets["packapunch"].power_on_callback ]]();

    self thread vending_machine_trigger_think();
    perk_machine playloopsound( "zmb_perks_packa_loop" );
    self thread shutoffpapsounds( perk_machine, packa_rollers, packa_timer );
    self thread vending_weapon_upgrade_cost();

    for (;;)
    {
        self.pack_player = undefined;
        self.pack_tier = undefined;
        self waittill( "trigger", player );
        index = maps\mp\zombies\_zm_weapons::get_player_index( player );
        current_weapon = player getcurrentweapon();

        if ( "microwavegun_zm" == current_weapon )
            current_weapon = "microwavegundw_zm";

        current_weapon = player maps\mp\zombies\_zm_weapons::switch_from_alt_weapon( current_weapon );

        if ( isdefined( level.custom_pap_validation ) )
        {
            players = getplayers();
            foreach(plaayer in players)
                plaayer iprintln("Wtaf bro");

            valid = self [[ level.custom_pap_validation ]]( player );

            if ( !valid )
                continue;
        }

        if ( !player maps\mp\zombies\_zm_magicbox::can_buy_weapon() || player maps\mp\zombies\_zm_laststand::player_is_in_laststand() || isdefined( player.intermission ) && player.intermission || player isthrowinggrenade() )
        {
            wait 0.1;
            continue;
        }
        // if ( !player maps\mp\zombies\_zm_magicbox::can_buy_weapon() || player maps\mp\zombies\_zm_laststand::player_is_in_laststand() || isdefined( player.intermission ) && player.intermission || player isthrowinggrenade() || !player can_upgrade_weapon__custom( current_weapon ) )
        // {
        //     wait 0.1;
        //     continue;
        // }

        if ( isdefined( level.pap_moving ) && level.pap_moving )
            continue;

        if ( player isswitchingweapons() )
        {
            wait 0.1;

            if ( player isswitchingweapons() )
                continue;
        }

        if ( !maps\mp\zombies\_zm_weapons::is_weapon_or_base_included( current_weapon ) )
            continue;

        upgrade_as_attachment = will_upgrade_weapon_as_attachment( current_weapon );
        if ( upgrade_as_attachment )
        {
            current_cost = self.attachment_cost;
            player.restore_ammo = 1;
            player.restore_clip = player getweaponammoclip( current_weapon );
            player.restore_clip_size = weaponclipsize( current_weapon );
            player.restore_stock = player getweaponammostock( current_weapon );
            player.restore_max = weaponmaxammo( current_weapon );
        }

        current_cost = self.cost;
        player.restore_ammo = undefined;
        player.restore_clip = undefined;
        player.restore_stock = undefined;
        player_restore_clip_size = undefined;
        player.restore_max = undefined;

        player takeweapon(current_weapon);
        
        // Need to replace w/ upgrade tier
        self.pack_tier = 1;
        if (isdefined(player.weapon_tiers[current_weapon]))
            self.pack_tier = player.weapon_tiers[current_weapon] + 1;

        if ( player maps\mp\zombies\_zm_pers_upgrades_functions::is_pers_double_points_active() )
            current_cost = player maps\mp\zombies\_zm_pers_upgrades_functions::pers_upgrade_double_points_cost( current_cost );

        if ( player.score < current_cost )
        {
            self playsound( "deny" );

            if ( isdefined( level.custom_pap_deny_vo_func ) )
                player [[ level.custom_pap_deny_vo_func ]]();
            else
                player maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "perk_deny", undefined, 0 );

            continue;
        }

        self.pack_player = player;
        maps\mp\_demo::bookmark( "zm_player_use_packapunch", gettime(), player );
        player maps\mp\zombies\_zm_stats::increment_client_stat( "use_pap" );
        player maps\mp\zombies\_zm_stats::increment_player_stat( "use_pap" );
        player maps\mp\zombies\_zm_score::minus_to_player_score( current_cost, 1 );
        sound = "evt_bottle_dispense";
        playsoundatposition( sound, self.origin );
        self thread maps\mp\zombies\_zm_audio::play_jingle_or_stinger( "mus_perks_packa_sting" );

        weaponname = self get_nonalternate_weapon(current_weapon);
        is_bo1 = false;
        if ( !maps\mp\zombies\_zm_weapons::is_weapon_or_base_included( weaponname ) )
            is_bo1 = true;
        if ( !player maps\mp\zombies\_zm_weapons::can_upgrade_weapon( weaponname ) )
            is_bo1 = true;

        self.current_weapon = current_weapon;
        if (is_bo1)
            upgrade_name = current_weapon;
        else
            upgrade_name = maps\mp\zombies\_zm_weapons::get_upgrade_weapon(current_weapon, upgrade_as_attachment);

        player giveweapon(upgrade_name, 0, player maps\mp\zombies\_zm_weapons::get_pack_a_punch_weapon_options( upgrade_name ));
        player.weapon_tiers[upgrade_name] = self.pack_tier;
        player switchtoweapon(upgrade_name);

        player pap_tier_hud(self.pack_tier);

        if ( isdefined( level.zombiemode_reusing_pack_a_punch ) && level.zombiemode_reusing_pack_a_punch )
            self sethintstring( &"ZOMBIE_PERK_PACKAPUNCH_ATT", self.cost );
        else
            self sethintstring( &"ZOMBIE_PERK_PACKAPUNCH", self.cost );

        self setvisibletoall();
        self.pack_player = undefined;
        self.pack_tier = undefined;
        flag_clear( "pack_machine_in_use" );
    }
}

tier_damage_callback(mod, hit_location, hit_origin, attacker, amount) {
    if (isdefined(self.damageweapon)) {
        if (isdefined(attacker) && isplayer(attacker)) {
            if (isdefined(attacker.weapon_tiers[self.damageweapon]) && attacker.weapon_tiers[self.damageweapon] > 1) {
                new_damage = amount * (0.5 * (attacker.weapon_tiers[self.damageweapon] - 1));
                self DoDamage(new_damage, hit_origin, attacker, self, hit_location, mod);
            }
        }
    }
    return 0;
}