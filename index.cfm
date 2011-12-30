<cfoutput>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8" />
	<title>#Request.Guild# - #Request.Server# - Mount Meta Completion Tracking</title>	
	<script type="text/javascript" src="http://static.wowhead.com/widgets/power.js" defer></script>
	<link rel='stylesheet' href='css.css' type='text/css'/>
</head>
<body>

<cftry>
<!--- Grab data --->
<cfquery name="getChars">
SELECT CharName, T11, T12, T13
FROM mounts
WHERE GuildName = <cfqueryparam value="#Request.Guild#" cfsqltype="cf_sql_varchar" />
AND ServerName = <cfqueryparam value="#Request.Server#" cfsqltype="cf_sql_varchar" />
ORDER BY CharName
</cfquery>

<!--- Init Tiers --->
<cfset Tiers = DeSerializeJSON( Request.TierJSON ) />

<h1 style="color: ##bcbdbd; text-align:center">#Request.Guild# - #Request.Server#</h1>

<cfloop list="T13,T12,T11" index="Tier">
	<!--- Init Tier Counters --->
	<cfset Total = new com.Total() />
	<cfset CharsDisplayed = 0 />
	
	<table class="ach">
		<tr>
			<th colspan="#2+ArrayLen( Tiers[ Tier ][ 'Required' ] )#">#Tiers[ Tier ].TierName#</th>
		</tr>
		<tr>
			<td class="label">Character</td>
			<cfloop array="#Tiers[ Tier ][ 'Required' ]#" index="Ach">
				<td class="icon">#DisplayIcon( Ach )#</td>
			</cfloop>
			<td class="percent center">#DisplayIcon( Tiers[ Tier ][ 'Meta' ] )#</td>
		</tr>
		
		<cfloop query="getChars">
			<!--- Convert to Struct --->
			<cfset Achs = DeSerializeJSON( getChars[ Tier ][ getChars.CurrentRow ] ) />
						
			<!--- Ensure we have at least one Y --->			
			<cfif ArrayLen( StructFindValue( Achs, 'Y' ) ) EQ 0>
				<cfcontinue />
			</cfif>
			
			<cfset AchLinkBase = "http://us.battle.net/wow/en/character/burning-blade/" & getChars.CharName & "/achievement##168:15068:a" />
			
			<cfset CharsDisplayed++ />
			
			<cfset AchCompleted = 0 />
			<tr>
				<td class="label"><a href="http://us.battle.net/wow/en/character/burning-blade/#getChars.CharName#/advanced">#getChars.CharName#</a></td>
				<cfloop array="#Tiers[ Tier ][ 'Required' ]#" index="Ach">
					<td class="center">
						<cfif StructKeyExists( Achs, Ach.ID ) AND StructFind( Achs, Ach.ID ) EQ 'Y'>
							<a href="#AchLinkBase & Ach.ID#"><img src="images/check.png" alt="Completed" /></a>
							<cfset AchCompleted++ />
							<cfset Total.IncrementTotal( Ach.ID ) />
						<cfelse>
							<a href="#AchLinkBase & Ach.ID#"><img src="images/x.png" alt="Not Completed" /></a>
						</cfif>	
					</td>					
				</cfloop>
				<td class="percent">#formatTotal( AchCompleted, ArrayLen( Tiers[ Tier ][ 'Required' ] ) )#</td>
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
				<td class="total">#formatTotal( Total.getTotal( Ach.Id ), CharsDisplayed )#</td>
			</cfloop>
			<td class="total percent">#formatTotal( Total.getTotal( Tiers[ Tier ][ 'Meta' ].Id ), CharsDisplayed )#</td>
		</tr>
	</table>
	<br/><br/>
</cfloop>

<p class="disclaimer">Only players active within the last two weeks and who have at least one achievement completed are shown in the table. ASCII names are also broken for some reason.</p>

<cffunction name="formatTotal" output="no" returntype="string">
	<cfargument name="Numerator" required="yes" type="numeric" />
	<cfargument name="Denominator" required="yes" type="numeric" />
	
	<cfset var Output = '<span title="' & Arguments.Numerator & '/' & Arguments.Denominator & '">' />
	<!--- Prevent dividing by zero --->
	<cfif Arguments.Denominator EQ 0>
		<cfset Output &= '0.0' />
	<cfelse>
		<cfset Output &= NumberFormat( Arguments.Numerator / Arguments.Denominator * 100, "0.0" ) />
	</cfif>
	<cfset Output &= '%</span>' />
	
	<cfreturn Output />
</cffunction>

<cffunction name="displayIcon" output="no" returntype="string">
	<cfargument name="Ach" required="yes" type="struct" />
	
	<cfreturn '<a href="http://ptr.wowhead.com/achievement=#Arguments.Ach.Id#"><img src="http://wow.zamimg.com/images/wow/icons/medium/#Arguments.Ach.Icon#.jpg" alt="#Arguments.Ach.ID#" /></a>' />
</cffunction>

<cfcatch>
	<cfdump var="#cfcatch#" />
</cfcatch>
</cftry>

</body>
</html>
</cfoutput>