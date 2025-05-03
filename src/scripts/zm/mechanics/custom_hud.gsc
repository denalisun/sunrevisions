#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_perks;
#include maps\mp\zombies\_zm_powerups;
#include maps\mp\gametypes_zm\spawnlogic;
#include maps\mp\gametypes_zm\_hostmigration;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\gametypes_zm\_hud_message;

init() {
    level thread on_player_connect();
}

on_player_connect() {
    for (;;) {
        level waittill("connected", player);
        //player thread init_health_bar();
    }
}

init_health_bar() {
    flag_wait("initial_blackscreen_passed");
    self endon("disconnect");
    level endon("end_game");
    
    self.ui__healthbar = createPrimaryProgressBar();
    self.ui__healthbar setPoint("CENTER", "BOTTOM", 0, 30);
    self.ui__healthbar.color = (0, 0, 0);
    self.ui__healthbar.bar.color = (1, 0, 0);
    self.ui__healthbar.alpha = 1;
    self.ui__healthbar.archived = 1;

    self thread health_bar_loop();
}

health_bar_loop() {
    while (self.maxhealth > 0) {
        self endon("disconnect");
        level endon("end_game");
        health_percentage = (int(self.health) / int(self.maxhealth));
        self.ui__healthbar updateBar(health_percentage);
        if (health_percentage > 0.75)
            self.ui__healthbar.bar.color = (0, 1, 0);
        else if (health_percentage > 0.5)
            self.ui__healthbar.bar.color = (1, 1, 0);
        else if (health_percentage > 0.25)
            self.ui__healthbar.bar.color = (1, 0.5, 0);
        else if (health_percentage > 0)
            self.ui__healthbar.bar.color = (1, 0, 0);
        wait 0.05;
        waittillframeend;
    }
}

perk_hud(perk) {
    if ( !IsDefined( self.perk_hud ) ) {
        self.perk_hud = [];
    }

    if (!IsDefined(self.perk_hud_array)) {
        self.perk_hud_array = [];
    }

    switch( perk ) {
    	case "specialty_armorvest":
        	shader = "specialty_juggernaut_zombies";
        	break;
    	case "specialty_quickrevive":
        	shader = "specialty_quickrevive_zombies";
        	break;
    	case "specialty_fastreload":
        	shader = "specialty_fastreload_zombies";
        	break;
    	case "specialty_rof":
        	shader = "specialty_doubletap_zombies";
        	break;  
    	case "specialty_longersprint":
        	shader = "specialty_marathon_zombies";
        	break; 
    	case "specialty_flakjacket":
        	shader = "specialty_divetonuke_zombies";
        	break;  
    	case "specialty_deadshot":
        	shader = "specialty_ads_zombies";
        	break;
    	case "specialty_additionalprimaryweapon":
        	shader = "specialty_additionalprimaryweapon_zombies";
        	break; 
		case "specialty_scavenger": 
			shader = "specialty_tombstone_zombies";
        	break; 
    	case "specialty_finalstand":
			shader = "specialty_chugabud_zombies";
        	break; 
    	case "specialty_nomotionsensor":
			shader = "specialty_vulture_zombies";
        	break; 
    	case "specialty_grenadepulldeath":
			shader = "specialty_electric_cherry_zombie";
        	break; 
    	default:
        	shader = "";
        	break;
    }
    hud = newclienthudelem( self );
    hud.foreground = true;
    hud.sort = 1;
    hud.hidewheninmenu = true;
    hud.alignX = "center";
    hud.alignY = "bottom";
    hud.horzAlign = "user_center";
    hud.vertAlign = "user_bottom";
    hud.y = -5;
    
    if(self.perk_hud_array.size > 0)
        hud.x = self.perk_hud_array[ self.perk_hud_array.size - 1].x + 20;

    hud.alpha = 1;
    hud SetShader( shader, 16, 16 );

    hud.archived = 0;
    
    self.perk_hud[ perk ] = hud;
    self.perk_hud_array[ self.perk_hud_array.size ] = hud;
    
    if(self.perk_hud.size > 1) {
        foreach(hud in self.perk_hud_array) 
            hud.x -= 10;
    }
}

give_perk_modified(perk, bought) {
    self setperk( perk );
    self.num_perks++;

    if ( isdefined( bought ) && bought )
    {
        self maps\mp\zombies\_zm_audio::playerexert( "burp" );

        if ( isdefined( level.remove_perk_vo_delay ) && level.remove_perk_vo_delay )
            self maps\mp\zombies\_zm_audio::perk_vox( perk );
        else
            self delay_thread( 1.5, maps\mp\zombies\_zm_audio::perk_vox, perk );

        self setblur( 4, 0.1 );
        wait 0.1;
        self setblur( 0, 0.1 );
        self notify( "perk_bought", perk );
    }

    self perk_set_max_health_if_jugg( perk, 1, 0 );

    if ( !( isdefined( level.disable_deadshot_clientfield ) && level.disable_deadshot_clientfield ) )
    {
        if ( perk == "specialty_deadshot" )
            self setclientfieldtoplayer( "deadshot_perk", 1 );
        else if ( perk == "specialty_deadshot_upgrade" )
            self setclientfieldtoplayer( "deadshot_perk", 1 );
    }

    if ( perk == "specialty_scavenger" )
        self.hasperkspecialtytombstone = 1;

    players = get_players();

    if ( use_solo_revive() && perk == "specialty_quickrevive" )
    {
        self.lives = 1;

        if ( !isdefined( level.solo_lives_given ) )
            level.solo_lives_given = 0;

        if ( isdefined( level.solo_game_free_player_quickrevive ) )
            level.solo_game_free_player_quickrevive = undefined;
        else
            level.solo_lives_given++;

        if ( level.solo_lives_given >= 3 )
            flag_set( "solo_revive" );

        self thread solo_revive_buy_trigger_move( perk );
    }

    if ( perk == "specialty_finalstand" )
    {
        self.lives = 1;
        self.hasperkspecialtychugabud = 1;
        self notify( "perk_chugabud_activated" );
    }

    if ( isdefined( level._custom_perks[perk] ) && isdefined( level._custom_perks[perk].player_thread_give ) )
        self thread [[ level._custom_perks[perk].player_thread_give ]]();

    maps\mp\_demo::bookmark( "zm_player_perk", gettime(), self );
    self maps\mp\zombies\_zm_stats::increment_client_stat( "perks_drank" );
    self maps\mp\zombies\_zm_stats::increment_client_stat( perk + "_drank" );
    self maps\mp\zombies\_zm_stats::increment_player_stat( perk + "_drank" );
    self maps\mp\zombies\_zm_stats::increment_player_stat( "perks_drank" );

    if ( !isdefined( self.perk_history ) )
        self.perk_history = [];

    self.perk_history = add_to_array( self.perk_history, perk, 0 );
    self notify( "perk_acquired" );
    self perk_hud(perk);
    self thread perk_think( perk );
}

player_downed_watcher() {
	level endon("end_game");
	while(1) {
		self waittill("player_downed");
		foreach(hud in self.perk_hud) {
            self.perk_hud = [];
            self.perk_hud_array = [];
            hud destroy();
        }
		self notify( "stop_electric_cherry_reload_attack" );
	}
}