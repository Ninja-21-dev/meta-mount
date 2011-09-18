component output = false
{
	Variables.Total = {};
	
	void function incrementTotal( required string Name, numeric Value = 1 )
	{
		// Ensure the total exists
		createTotal( Arguments.Name );
		
		Variables.Total[ Arguments.Name ] += Arguments.Value;
	}
	
	numeric function getTotal( required string Name )
	{
		// Ensure the total we're getting exists
		createTotal( Arguments.Name );
		
		return Variables.Total[ Arguments.Name ];
	}
	
	private void function createTotal( required string Name )
	{
		// Create the total if it doesn't exist
		if ( ! StructKeyExists( Variables.Total, Arguments.Name ) )
		{
			Variables.Total[ Arguments.Name ] = 0;
		}
	}
}