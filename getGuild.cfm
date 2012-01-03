<cfflush interval="10" />
<cfsetting requesttimeout="6000" />

<cftry>

<!--- Init Tiers --->
<cfset Tiers = DeSerializeJSON( Request.TierJSON ) />

<!--- Use BCP Service --->
<cfset API = Application.BCP />

<!--- Run this for All Guilds --->
<cfloop collection="#Application.Guilds#" item="Guild">
	<h2><cfoutput>#Guild#</cfoutput></h2>
	<!--- Config the  API --->
	<cfset API.setServer( Application.Guilds[ Guild ].Server ) />
	<cfset API.setGuild( Application.Guilds[ Guild ].GName ) />
		
	<!--- Grab Guild --->
	<cfset Members = API.getMembers() />
	
	<cfset Updated = 0 />
	<!--- Loop through Members --->
	<cfloop array="#Members#" index="Member">
		<br/>Processing <cfoutput>#Member.Character.Name#</cfoutput>
		<!--- Only Process level 85s ---->
		<cfif Member.Character.Level NEQ 85>
			<cfcontinue />
		</cfif>
		
		<cfset MemberJSON = API.getCharacter( Member.Character.Name ) />
			
		<!--- Did we return an error --->
		<cfif StructKeyExists( MemberJSON, 'Error' )>
			<cfdump var="#MemberJSON.Error#" />
			<cfcontinue />
		</cfif>	
			
		<!--- Only deal with people that have been updated in two weeks --->
		<cfset StartingDate = CreateDate( 1970, 1, 1 ) />
		<!--- Convert LastModified from Milliseconds to minutes, otherwise ACF complains --->
		<cfset LastModified = MemberJSON.LastModified / 1000 / 60 />
		<cfset LastModified = DateAdd( "n", LastModified, StartingDate ) />
		<cfif LastModified LTE DateAdd( "d", -14, Now() )>
			... Character not updated within two weeks, skipping<cfcontinue />
		</cfif>
	
		<!--- Ensure we have achievements --->
		<cfif ! StructKeyExists( MemberJSON, "Achievements" )>
			...Missing Achievements Struct, skipping.
			<cfcontinue />
		</cfif>
	
		<!--- Ensure we have achievements completed --->
		<cfif ! StructKeyExists( MemberJSON.Achievements, "AchievementsCompleted" )>
			...Missing Achievements Completed Struct, skipping.
			<cfcontinue />
		</cfif>
			
		<cfset Achs = MemberJSON.Achievements.AchievementsCompleted />
		
		<cfset hasAch = false />
		
		<!--- Loop the tiers --->
		<cfloop collection="#Tiers#" item="Tier">
			<!--- Is the meta finished? --->
			<cfset Complete = ArrayContains( Achs, Tiers[ Tier ][ 'Meta' ][ 'Id' ] ) /> 
			
			<!--- Set Completed --->
			<cfloop array="#Tiers[ Tier ][ 'Required' ]#" index="Ach">
				<cfif Complete OR ArrayContains( Achs, Ach.ID )>
					<cfset Tiers[ Tier ][ 'Completed' ][ Ach.ID ] = 'Y' />
					<cfset hasAch = true />
				<cfelse>
					<cfset Tiers[ Tier ][ 'Completed' ][ Ach.ID ] = 'N' />
				</cfif>
			</cfloop>
		</cfloop>
		
		<!--- Ensure they have an achievement before we store them --->
		<cfif hasAch>
			<!--- Serialize JSON --->
			<cfloop collection="#Tiers#" item="Tier">
				<cfset Tiers[ Tier ][ 'JSON' ] = SerializeJSON( Tiers[ Tier ][ 'Completed' ] ) />
			</cfloop>	
			
			<!--- Insert/Update --->
			<cfquery>
			INSERT INTO mounts
			( 
				ServerName,
				GuildName,
				CharName,
				<cfloop collection="#Tiers#" item="Tier">
					#Tier#,
				</cfloop>
				LastUpdated
			)
			VALUES
			(
				<cfqueryparam value="#Application.Guilds[ Guild ].Server#" cfsqltype="cf_sql_varchar" />,
				<cfqueryparam value="#Application.Guilds[ Guild ].GName#" cfsqltype="cf_sql_varchar" />,
				<cfqueryparam value="#Member.Character.Name#" cfsqltype="cf_sql_varchar" />,
				<cfloop collection="#Tiers#" item="Tier">
					<cfqueryparam value="#Tiers[ Tier ][ 'JSON' ]#" cfsqltype="cf_sql_varchar" />,
				</cfloop>
				<cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp" />
			)
			ON DUPLICATE KEY UPDATE
			<cfloop list="#StructKeyList( Tiers )#" index="Tier">
				#Tier# = <cfqueryparam value="#Tiers[ Tier ][ 'JSON' ]#" cfsqltype="cf_sql_varchar" />,
			</cfloop>
			LastUpdated = <cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp" />
			</cfquery>
			<cfset Updated++ />
		</cfif>
	</cfloop>
	
	<!--- Cleanup only if we've updated at least 10--->
	<cfif Updated GTE 10>
		<cfquery result="Deleted">
		DELETE FROM mounts
		WHERE LastUpdated <= <cfqueryparam value="#DateAdd( 'd', -14, Now() )#" cfsqltype="cf_sql_timestamp" />
		AND GuildName = <cfqueryparam value="#Application.Guilds[ Guild ].GName#" cfsqltype="cf_sql_varchar" />
		AND ServerName = <cfqueryparam value="#Application.Guilds[ Guild ].Server#" cfsqltype="cf_sql_varchar" />
		</cfquery>
	
		<br/>
		Deleted: <cfoutput>#Deleted.RecordCount#</cfoutput>
		<br/><br/>
	</cfif>
	
	<cfoutput>Done with #Application.Guilds[ Guild ].GName#.<br/><br/></cfoutput>
</cfloop>

All done.
<cfcatch>
	<cfdump var="#cfcatch#">
</cfcatch>
</cftry>