<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8" />
	<title>Insolent - Burning Blade - Mount Meta Completion Tracking</title>	
	<script type="text/javascript" src="http://static.wowhead.com/widgets/power.js" defer></script>
	<link rel='stylesheet' href='css.css' type='text/css'/>
</head>
<body>

<cftry>
<!--- Grab data --->
<cfquery name="getChars">
SELECT CharName, T11, T12
FROM mounts
ORDER BY CharName
</cfquery>

<!--- Init Tiers --->
<cfset Tiers = DeSerializeJSON( Request.TierJSON ) />

<cfoutput>
<div style="margin:auto; width:1000px; height:202px;"><img src="images/banner.jpg" width="1000" height="202" alt="Insolent Banner" /></div>

<cfloop list="T11,T12" index="Tier">
	<cfset Total = new Total() />
	<table class="ach">
		<tr>
			<th colspan="#2+ArrayLen( Tiers[ Tier ][ 'Required' ] )#">#Tier#</th>
		</tr>
		<tr>
			<td class="label">Character</td>
			<cfloop array="#Tiers[ Tier ][ 'Required' ]#" index="Ach">
				<td class="icon">#DisplayIcon( Ach )#</td>
			</cfloop>
			<td class="percent center">#DisplayIcon( Tiers[ Tier ][ 'Meta' ] )#</td>
		</tr>
		<cfset CharsDisplayed = 0 />
		<cfloop query="getChars">
			<!--- Convert to Struct --->
			<cfset Achs = DeSerializeJSON( getChars[ Tier ][ getChars.CurrentRow ] ) />
						
			<!--- Ensure we have at least one Y --->			
			<cfif ArrayLen( StructFindValue( Achs, 'Y' ) ) EQ 0>
				<cfcontinue />
			</cfif>
			
			<cfset CharsDisplayed++ />
			
			<cfset AchCompleted = 0 />
			<tr>
				<td class="label"><a href="http://us.battle.net/wow/en/character/burning-blade/#getChars.CharName#/advanced">#getChars.CharName#</a></td>
				<cfloop array="#Tiers[ Tier ][ 'Required' ]#" index="Ach">
					<td class="center">
						<cfif StructFind( Achs, Ach.ID ) EQ 'Y'>
							<img src="images/check.png" alt="Completed" />
							<cfset AchCompleted++ />
							<cfset Total.IncrementTotal( Ach.ID ) />
						<cfelse>
							<img src="images/x.png" alt="Not Completed" />
						</cfif>	
					</td>					
				</cfloop>
				<td class="percent">#displayPercent( AchCompleted, ArrayLen( Tiers[ Tier ][ 'Required' ] ) )#</td>
				<!--- Track the meta total too --->
				<cfif AchCompleted EQ ArrayLen( Tiers[ Tier ][ 'Required'] )>
					<cfset Total.IncrementTotal( Tiers[ Tier ][ 'Meta' ].ID ) />
				</cfif>
			</tr>
		</cfloop>
		<!--- Display Totals --->
		<tr>
			<td class="total">&nbsp;</td>
			<cfloop array="#Tiers[ Tier ][ 'Required' ]#" index="Ach">
				<td class="total">#displayPercent( Total.getTotal( Ach.Id ), CharsDisplayed )#</td>
			</cfloop>
			<td class="total percent">#displayPercent( Total.getTotal( Tiers[ Tier ][ 'Meta' ].Id ), CharsDisplayed )#</td>
		</tr>
	</table>
	<br/><br/>
</cfloop>

<p class="disclaimer">Only players active within the last two weeks and who have at least one achievement completed are shown in the table. ASCII names are also broken for some reason.</p>
</cfoutput>

<cffunction name="displayPercent" output="no" returntype="string">
	<cfargument name="Numerator" required="yes" type="numeric" />
	<cfargument name="Denominator" required="yes" type="numeric" />

	<cfreturn '<span title="#Arguments.Numerator#/#Arguments.Denominator#">#NumberFormat( Arguments.Numerator / Arguments.Denominator * 100, "0.0" )#%</span>' />
</cffunction>

<cffunction name="displayIcon" output="no" returntype="string">
	<cfargument name="Ach" required="yes" type="struct" />
	
	<cfreturn '<a href="http://www.wowhead.com/achievement=#Arguments.Ach.Id#"><img src="http://wow.zamimg.com/images/wow/icons/medium/#Arguments.Ach.Icon#.jpg" alt="#Arguments.Ach.ID#" /></a>' />
</cffunction>

<cfcatch>
	<cfdump var="#cfcatch#" />
</cfcatch>
</cftry>

</body>
</html>