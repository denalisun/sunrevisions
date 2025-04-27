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
    hud.alignX = "left";
    hud.alignY = "top";
    hud.horzAlign = "user_left";
    hud.vertAlign = "user_top";
    hud.x = 15;
    
    if(self.perk_hud_array.size > 0)
        hud.y = self.perk_hud_array[ self.perk_hud_array.size - 1].y + 10;
    
    hud.y = hud.y + 15;

    hud.alpha = 1;
    hud SetShader( shader, 24, 24 );

    hud.archived = 0;
    
    self.perk_hud[ perk ] = hud;
    self.perk_hud_array[ self.perk_hud_array.size ] = hud;
    
    // if(self.perk_hud.size > 1) {
    //     foreach(hud in self.perk_hud_array) 
    //         hud.y += 14;
    // }
}