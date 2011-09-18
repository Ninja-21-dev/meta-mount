<cfsetting requesttimeout="600" />

<!--- Grab Guild --->

<!--- get as a binary to work around ACF screwing the UTF names --->
<cfhttp url="http://us.battle.net/api/wow/guild/Burning%20Blade/Insolent?fields=members" result="GuildJSON" charset="utf-16" getasbinary="yes" />

<cftry>

<cfset Members = DeSerializeJSON( ToString( GuildJSON.FileContent ) ).Members />

<!--- Init Tiers --->
<cfset Tiers = DeSerializeJSON( Request.TierJSON ) />

<cfflush interval="10" />
	
<!--- Loop through Members --->
<cfloop array="#Members#" index="Member">
	Processing <cfoutput>#Member.Character.Name#</cfoutput><br/>
	<!--- Only Process level 85s ---->
	<cfif Member.Character.Level NEQ 85>
		<cfcontinue />
	</cfif>
		
	<cfhttp url="http://us.battle.net/api/wow/character/Burning%20Blade/#Member.Character.Name#?fields=achievements" result="MemberJSON" />
	
	<!--- Ensure it's JSON --->
	<cfif ! isJSON ( MemberJSON.FileContent )>
		This is not JSON.
		<cfdump var="#MemberJSON#" />
		<cfcontinue />
	</cfif>
	
	<cfset MemberJSON = DeSerializeJSON( MemberJSON.FileContent ) />

	<!--- Ensure we have achievements --->
	<cfif ! StructKeyExists( MemberJSON, "Achievements" )>
		Missing Achievements Struct.
		<cfoutput>http://us.battle.net/api/wow/character/Burning%20Blade/#Member.Character.Name#?fields=achievements</cfoutput>
		<cfdump var="#MemberJSON#" />
		<cfcontinue />
	</cfif>

	<!--- Ensure we have achievements completed --->
	<cfif ! StructKeyExists( MemberJSON.Achievements, "AchievementsCompleted" )>
		Missing Achievements Completed Struct.
		<cfdump var="#MemberJSON.Achievements#" />
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
				<cfset Tiers[ Tier ][ 'Completed' ][ 'A' & Ach.ID ] = 1 />
				<cfset hasAch = true />
			<cfelse>
				<cfset Tiers[ Tier ][ 'Completed' ][ 'A' & Ach.ID ] = 0 />
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
			CharName,
			<cfloop collection="#Tiers#" item="Tier">
				#Tier#,
			</cfloop>
			LastUpdated
		)
		VALUES
		(
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
	</cfif>
</cfloop>

<!--- Cleanup --->
<cfquery result="Deleted">
DELETE FROM mounts
WHERE LastUpdated <= <cfqueryparam value="#DateAdd( 'd', -14, Now() )#" cfsqltype="cf_sql_timestamp" />
</cfquery>

<br/>
Deleted: <cfoutput>#Deleted.RecordCount#</cfoutput>
<br/><br/>

All done.
<cfcatch>
	<cfdump var="#cfcatch#">
</cfcatch></cftry>