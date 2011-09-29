<cftry>
<!--- Init Tiers --->
<cfset Tiers.T11.List = '5306,5307,5308,5309,5310,4849,5300,4852,5311,5312,5304,5305,5094,5107,5108,5109,5115,5116,5118,5117,5119,5120,5122,5123' />
<cfset Tiers.T11.Complete = '4853' />
<cfset Tiers.T11.Required = [] />
<cfset Tiers.T11.TierName = 'T11 - Cataclysm Raids' />

<cfset Tiers.T12.List = '5821,5810,5813,5829,5830,5799,5807,5808,5806,5809,5805,5804' />
<cfset Tiers.T12.Complete = '5828' />
<cfset Tiers.T12.Required = [] />
<cfset Tiers.T12.TierName = 'T12 - Firelands' />

<!--- Load Ach icons, loop through the list to maintain order --->
<cfloop collection="#Tiers#" item="Tier">
	<!--- Find Normal Requirements --->
	<cfloop list="#Tiers[ Tier ][ 'List' ]#" index="Ach">
		<cfloop file="#getDirectoryFromPath( getCurrentTemplatePath() )#achievementIcons.json" index="Line">
			<cfset ThisAch = DeSerializeJSON( Line ) />
			<cfif ThisAch.ID EQ Ach>
				<cfset ThisAch.Icon = Replace( ThisAch.Icon, " ", "-", "ALL" ) />
				<cfset Tiers[ Tier ][ 'Required' ].Add( ThisAch ) />
				<cfbreak />
			</cfif>
			<!--- Find Meta --->
			<cfif Tiers[ Tier ][ 'Complete' ] EQ ThisAch.ID>
				<cfset Tiers[ Tier ][ 'Meta' ] = ThisAch />
			</cfif>
		</cfloop>
	</cfloop>
</cfloop>

<cfset StructDelete( Tiers.T11, "List" ) />
<cfset StructDelete( Tiers.T11, "Complete" ) />
<cfset StructDelete( Tiers.T12, "List" ) />
<cfset StructDelete( Tiers.T12, "Complete" ) />

<!--- Output it as JSON so we can save it --->
<cfdump var="#SerializeJSON( Tiers )#" />
<cfcatch>
	<cfdump var="#cfcatch#" />
</cfcatch>
</cftry>
