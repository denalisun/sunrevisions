#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_net;
#include maps\mp\zombies\_zm_spawner;
#include maps\mp\zombies\_zm_craftables;
#include maps\mp\zombies\_zm_equipment;
#include maps\mp\zombies\_zm_ai_basic;
#include maps\mp\animscripts\zm_shared;
#include maps\mp\zombies\_zm_unitrigger;
#include maps\mp\zombies\_zm_zonemgr;
#include maps\mp\zombies\_zm_challenges;

is_weapon_upgraded_staff( weapon )
{
    if ( weapon == "staff_water_upgraded_zm" )
        return true;
    else if ( weapon == "staff_lightning_upgraded_zm" )
        return true;
    else if ( weapon == "staff_fire_upgraded_zm" )
        return true;
    else if ( weapon == "staff_air_upgraded_zm" )
        return true;

    return false;
}

_kill_zombie_network_safe_internal( e_attacker, str_weapon )
{
    if ( !isdefined( self ) )
        return;

    if ( !isalive( self ) )
        return;

    self.staff_dmg = str_weapon;
    self dodamage( self.health, self.origin, e_attacker, e_attacker, "none", self.kill_damagetype, 0, str_weapon );
}

_damage_zombie_network_safe_internal( e_attacker, str_weapon, n_damage_amt )
{
    if ( !isdefined( self ) )
        return;

    if ( !isalive( self ) )
        return;

    self dodamage( n_damage_amt, self.origin, e_attacker, e_attacker, "none", self.kill_damagetype, 0, str_weapon );
}

do_damage_network_safe( e_attacker, n_amount, str_weapon, str_mod )
{
    if ( isdefined( self.is_mechz ) && self.is_mechz )
        self dodamage( n_amount, self.origin, e_attacker, e_attacker, "none", str_mod, 0, str_weapon );
    else if ( n_amount < self.health )
    {
        self.kill_damagetype = str_mod;
        maps\mp\zombies\_zm_net::network_safe_init( "dodamage", 6 );
        self maps\mp\zombies\_zm_net::network_choke_action( "dodamage", ::_damage_zombie_network_safe_internal, e_attacker, str_weapon, n_amount );
    }
    else
    {
        self.kill_damagetype = str_mod;
        maps\mp\zombies\_zm_net::network_safe_init( "dodamage_kill", 4 );
        self maps\mp\zombies\_zm_net::network_choke_action( "dodamage_kill", ::_kill_zombie_network_safe_internal, e_attacker, str_weapon );
    }
}

watch_staff_usage()
{
    self notify( "watch_staff_usage" );
    self endon( "watch_staff_usage" );
    self endon( "disconnect" );
    self setclientfieldtoplayer( "player_staff_charge", 0 );

    while ( true )
    {
        self waittill( "weapon_change", weapon );
        has_upgraded_staff = 0;
        has_revive_staff = 0;
        weapon_is_upgraded_staff = is_weapon_upgraded_staff( weapon );
        str_upgraded_staff_weapon = undefined;
        a_str_weapons = self getweaponslist();

        foreach ( str_weapon in a_str_weapons )
        {
            if ( is_weapon_upgraded_staff( str_weapon ) )
            {
                has_upgraded_staff = 1;
                str_upgraded_staff_weapon = str_weapon;
            }

            if ( str_weapon == "staff_revive_zm" )
                has_revive_staff = 1;
        }

/#
        if ( has_upgraded_staff && !has_revive_staff )
            has_revive_staff = 1;
#/

        if ( has_upgraded_staff && !has_revive_staff )
        {
            self takeweapon( str_upgraded_staff_weapon );
            has_upgraded_staff = 0;
        }

        if ( !has_upgraded_staff && has_revive_staff )
        {
            self takeweapon( "staff_revive_zm" );
            has_revive_staff = 0;
        }

        if ( !has_revive_staff || !weapon_is_upgraded_staff && "none" != weapon && "none" != weaponaltweaponname( weapon ) )
            self setactionslot( 3, "altmode" );
        else
            self setactionslot( 3, "weapon", "staff_revive_zm" );

        if ( weapon_is_upgraded_staff )
            self thread staff_charge_watch_wrapper( weapon );
    }
}

staff_charge_watch_wrapper( weapon )
{
    self notify( "staff_charge_watch_wrapper" );
    self endon( "staff_charge_watch_wrapper" );
    self endon( "disconnect" );
    self setclientfieldtoplayer( "player_staff_charge", 0 );

    while ( is_weapon_upgraded_staff( weapon ) )
    {
        self staff_charge_watch();
        self setclientfieldtoplayer( "player_staff_charge", 0 );
        weapon = self getcurrentweapon();
    }
}

staff_charge_watch()
{
    self endon( "disconnect" );
    self endon( "player_downed" );
    self endon( "weapon_change" );
    self endon( "weapon_fired" );

    while ( !self attackbuttonpressed() )
        wait 0.05;

    n_old_charge = 0;

    while ( true )
    {
        if ( n_old_charge != self.chargeshotlevel )
        {
            self setclientfieldtoplayer( "player_staff_charge", self.chargeshotlevel );
            n_old_charge = self.chargeshotlevel;
        }

        wait 0.1;
    }
}

_throttle_bullet_trace_think()
{
    do
    {
        level.bullet_traces_this_frame = 0;
        wait_network_frame();
    }
    while (true );
}

bullet_trace_throttled( v_start, v_end, e_ignore )
{
    if ( !isdefined( level.bullet_traces_this_frame ) )
        level thread _throttle_bullet_trace_think();

    while ( level.bullet_traces_this_frame >= 2 )
        wait_network_frame();

    level.bullet_traces_this_frame++;
    return bullettracepassed( v_start, v_end, 0, e_ignore );
}