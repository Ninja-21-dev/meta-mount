component output = false
{
	blizzard function init( required string Server, required string Guild ) output = false
	{
		// Convert to URL safe variables and set
		Variables.Guild = URLEncodedFormat( Arguments.Guild );
		Variables.Server = URLEncodedFormat( Arguments.Server );
		
		return this;
	}
	
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
			// Throw an error
			throw( message = 'Error, no members downloaded' );
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
}