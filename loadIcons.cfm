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

<cfset Tiers.T13.List = '6174,6129,6128,6175,6084,6105,6133,6180,6110,6109,6111,6112,6113,6114,6115,6116' />
<cfset Tiers.T13.Complete = '6169' />
<cfset Tiers.T13.Required = [] />
<cfset Tiers.T13.TierName = 'T13 - Dragon Soul' />

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

<!--- Clean up Struct before we serialize it --->
<cfloop list="#StructKeyList( Tiers )#" index="Tier">
	<cfset StructDelete( Tiers[ Tier ], "List" ) />
	<cfset StructDelete( Tiers[ Tier ], "Complete" ) />
</cfloop>

<!--- Output it as JSON so we can save it --->
<cfdump var="#SerializeJSON( Tiers )#" />
<cfcatch>
	<cfdump var="#cfcatch#" />
</cfcatch>
</cftry>