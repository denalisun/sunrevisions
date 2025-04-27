#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_perks;
#include scripts\ps_ui;

main() {
    replacefunc(::give_perk, ::give_perk_modified);
}

init() {
    thread remove_perk_limit();
    thread zombie_caps();
    level thread on_player_connected();
    level.local_doors_stay_open = 1;
}

remove_perk_limit() {
    level waittill("start_of_round");
    level.perk_purchase_limit = 9;
}

zombie_caps() {
    for (;;) {
        level waittill("start_of_round");
        if (level.zombie_total > 47)
            level.zombie_total = 47;
        if (level.zombie_health > 11272) //11272
            level.zombie_health = 11272;
    }
}

on_player_connected() {
    level endon("end_game");
    for (;;) {
        level waittill("connected", player);
        player thread on_player_spawned();
        player setperk("specialty_unlimitedsprint");
    }
}

on_player_spawned() {
    self endon("disconnect");
    level endon("end_game");
    for (;;) {
        self waittill("spawned_player");
        self setclientdvar("r_fog", 0);
        if(!isdefined(self.initial_spawn)) {
			self.initial_spawn = 1;
			self thread player_downed_watcher();
			self.perk_hud_array = [];
		}
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