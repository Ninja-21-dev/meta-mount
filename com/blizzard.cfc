component output = false
{
	property Guild;
	property Server;
		
	array function getMembers() output = false
	{
		// Grab our result
		var http = new HTTP( url = 'http://us.battle.net/api/wow/guild/' & Variables.Server & '/' & Variables.Guild & '?fields=members', getasbinary = 'yes' );
		http = http.Send().getPrefix();
						
		// Convert to JSON
		var JSON = DeSerializeJSON( ToString( http.FileContent ) );
		
		// Ensure the Members struct exists
		if ( ! StructKeyExists( JSON, "Members" ) )
		{
			dump( JSON );
			// Throw an error
			throw( message = 'Error, no members downloaded - ' & 'http://us.battle.net/api/wow/guild/' & Variables.Server & '/' & Variables.Guild & '?fields=members' );
		}
		
		return JSON.Members;		
	}
	
	struct function getCharacter( required string Name )
	{
		// Grab our result
		var http = new HTTP( url = 'http://us.battle.net/api/wow/character/' & Variables.Server & '/' & Arguments.Name & '?fields=achievements', getasbinary = 'yes' );
		http = http.Send().getPrefix();
		
		// Ensure it's JSON
		if ( ! isJSON( ToString( http.FileContent ) ) )
		{
			return { error = 'This is not JSON', http = MemberJSON };
		}
		
		var JSON = DeSerializeJSON( ToString( http.FileContent ) );
		
		// See if we have a result
		if ( StructKeyExists( JSON, "Status" ) && JSON.Status == 'nok' )
		{
			return { error = '...Character not found', http = '' };
		}
		
		return JSON;
	}
	
	void function setGuild( required GuildName ) output = false
	{
		Variables.Guild = URLEncodedFormat( Arguments.GuildName );
	}
	
	void function setServer( required ServerName ) output = false
	{
		Variables.Server = URLEncodedFormat( Arguments.ServerName );
	}	
}