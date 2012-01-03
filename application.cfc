component output = false
{
	this.name = 'flmounts';
	this.datasource = 'forums';
	
	boolean function onApplicationStart() output = false
	{
		// Global Settings, not the best place for these, but needed to be declared so we can cache all the cfcs
		Application.Guilds = {
			BF = {
				Server = "Blade's Edge",
				GName = 'Exile'
			},
			Stenas = {
				Server = 'Kargath',
				GName = 'Fellowship of Azeroth'
			},
			Nel = {
				Server = 'Bleeding Hollow',
				GName = 'Predestined'
			}
		};

		// Services
		Application.BCP = new com.Blizzard();
		Application.Total = new com.Total();
		
		return true;
	}
	
	boolean function onRequestStart( string TargetPage ) output = false
	{
		// Allow for application restart
		if ( StructKeyExists( url, "Restart" ) )
		{
			onApplicationStart();
		}
		
		// This needs to changed
		Request.TierJSON = '{"T11":{"TIERNAME":"T11 - Cataclysm Raids","REQUIRED":[{"id":5306,"icon":"ability_hunter_pet_worm"},{"id":5307,"icon":"achievement_dungeon_blackwingdescent_darkironcouncil"},{"id":5308,"icon":"inv_misc_bell_01"},{"id":5309,"icon":"warrior_talent_icon_furyintheblood"},{"id":5310,"icon":"ability_racial_aberration"},{"id":4849,"icon":"achievement_boss_onyxia"},{"id":5300,"icon":"inv_misc_crop_01"},{"id":4852,"icon":"achievement_dungeon_bastion-of-twilight_valiona-theralion"},{"id":5311,"icon":"achievement_dungeon_bastion-of-twilight_twilightascendantcouncil"},{"id":5312,"icon":"spell_shadow_mindflay"},{"id":5304,"icon":"spell_deathknight_frostfever"},{"id":5305,"icon":"spell_shaman_staticshock"},{"id":5094,"icon":"ability_hunter_pet_worm"},{"id":5107,"icon":"achievement_dungeon_blackwingdescent_darkironcouncil"},{"id":5108,"icon":"achievement_dungeon_blackwingdescent_raid_maloriak"},{"id":5109,"icon":"achievement_dungeon_blackwingdescent_raid_atramedes"},{"id":5115,"icon":"achievement_dungeon_blackwingdescent_raid_chimaron"},{"id":5116,"icon":"achievement_dungeon_blackwingdescent_raid_nefarian"},{"id":5118,"icon":"achievement_dungeon_bastion-of-twilight_halfus-wyrmbreaker"},{"id":5117,"icon":"achievement_dungeon_bastion-of-twilight_valiona-theralion"},{"id":5119,"icon":"achievement_dungeon_bastion-of-twilight_twilightascendantcouncil"},{"id":5120,"icon":"achievement_dungeon_bastion-of-twilight_chogall-boss"},{"id":5122,"icon":"ability_druid_galewinds"},{"id":5123,"icon":"achievement_boss_murmur"}],"Meta":{"id":4853,"icon":"inv_helmet_100"}},"T12":{"TIERNAME":"T12 - Firelands","REQUIRED":[{"id":5821,"icon":"inv_misc_head_nerubian_01"},{"id":5810,"icon":"misc_arrowright"},{"id":5813,"icon":"spell_magic_polymorphrabbit"},{"id":5829,"icon":"achievement_zone_firelands"},{"id":5830,"icon":"spell_shadow_painandsuffering"},{"id":5799,"icon":"achievement_firelands-raid_fandral-staghelm"},{"id":5807,"icon":"achievement_boss_broodmotheraranae"},{"id":5808,"icon":"achievement_boss_lordanthricyst"},{"id":5806,"icon":"achievement_boss_shannox"},{"id":5809,"icon":"achievement_firelands-raid_alysra"},{"id":5805,"icon":"achievement_firelandsraid_balorocthegatekeeper"},{"id":5804,"icon":"achievement_firelands-raid_fandral-staghelm"}],"Meta":{"id":5828,"icon":"inv_mace_1h_sulfuron_d_01"}},"T13":{"TIERNAME":"T13 - Dragon Soul","REQUIRED":[{"id":6174,"icon":"spell_nature_massteleport"},{"id":6129,"icon":"achievement_doublerainbow"},{"id":6128,"icon":"inv_enchant_voidsphere"},{"id":6175,"icon":"achievement_general_dungeondiplomat"},{"id":6084,"icon":"spell_shadow_twilight"},{"id":6105,"icon":"spell_fire_twilightpyroblast"},{"id":6133,"icon":"achievment_boss_spineofdeathwing"},{"id":6180,"icon":"inv_dragonchromaticmount"},{"id":6110,"icon":"achievment_boss_zonozz"},{"id":6109,"icon":"achievment_boss_morchok"},{"id":6111,"icon":"achievment_boss_yorsahj"},{"id":6112,"icon":"achievment_boss_hagara"},{"id":6113,"icon":"achievment_boss_ultraxion"},{"id":6114,"icon":"achievment_boss_blackhorn"},{"id":6115,"icon":"achievment_boss_spineofdeathwing"},{"id":6116,"icon":"achievment_boss_madnessofdeathwing"}],"Meta":{"id":6169,"icon":"inv_misc_demonsoul"}}}';
		
		// Enable simple switching for now
		if ( Len( CGI.QUERY_STRING ) && StructKeyExists( Application.Guilds, CGI.QUERY_STRING ) )
		{
			Request.Server = Application.Guilds[ CGI.QUERY_STRING ].Server;
			Request.Guild = Application.Guilds[ CGI.QUERY_STRING ].GName;
		}
		// Default to Nel's
		else
		{
			Request.Server = Application.Guilds.Nel.Server;
			Request.Guild = Application.Guilds.Nel.GName;
		}
								
		return true;
	}
}