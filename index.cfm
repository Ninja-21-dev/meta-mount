<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8" />
	<title>Insolent - Burning Blade - Mount Meta Completion Tracking</title>	
	<script type="text/javascript" src="http://static.wowhead.com/widgets/power.js" defer></script>
	
	<style type="text/css">
	body {
		background: black;
	}
	table, tr, th, td {
		margin: 0;
		padding: 0;
		border: 0;
		outline: 0;
		font-size: 100%;
		color: #bcbdbd;
	}
	table.ach {
		border-collapse: collapse;
		border-spacing: 0;
		background: black;
		margin:auto;
	}
	.ach td { 
		text-align:center; 
		padding:5px; 
		border-bottom:1px solid #333738;  
		line-height:normal;
		border-right:1px solid #333738;
		font-size: 12px; 
	}
	td.total{
		border-bottom: 0;
	}
	td.icon { 
		text-align:center; 
		padding: 0px;
	}
	.ach th {
		height:34px;
		padding:0;
	}
	td.label {
		text-align: right; 
		word-spacing: -1px; 
		padding-right: 12px; 
	}
	td.percent {
		text-align: right; 
		word-spacing: -1px; 
		font-size: 12px;
		border-right: 0;
		padding: 0;
	}
	a, a:link, a:visited, a:active, a:hover{
		color: #bcbdbd;
		text-decoration: none;
	}
	.disclaimer{
		text-align:center;
		color: #bcbdbd;
		font-size:12px;
	}
	.center{
		text-align:center;
	}
	</style>
</head>
<body>

<cftry>
<!--- Grab data --->
<cfquery name="getChars">
SELECT CharName, T11, T12
FROM mounts
ORDER BY CharName
</cfquery>

<!--- Adobe and Railo define JSON 1 differently --->
<cfif Server.ColdFusion.ProductName EQ 'ColdFusion Server'>
	<cfset Value = '1.0' />
<cfelseif Server.ColdFusion.ProductName EQ 'Railo'>
	<cfset Value = '1' />
<cfelse>
	<cfset Value = '1.0' />
</cfif>

<!--- Init Tiers --->
<cfset Tiers = DeSerializeJSON( Request.TierJSON ) />

<cfoutput>
<div style="margin:auto; width:1000px; height:202px;"><img src="images/banner.jpg" style="margin:auto;" width="1000" height="202" alt="Insolent Banner" /></div>

<cfloop list="T11,T12" index="Tier">
	<cfset Total = {} />
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
						
			<!--- Ensure we have at least a 1 --->			
			<cfif ArrayLen( StructFindValue( Achs, Value ) ) EQ 0>
				<cfcontinue />
			</cfif>
			
			<cfset CharsDisplayed++ />
			
			<cfset AchCompleted = 0 />
			<tr>
				<td class="label"><a href="http://us.battle.net/wow/en/character/burning-blade/#getChars.CharName#/advanced">#getChars.CharName#</a></td>
				<cfloop array="#Tiers[ Tier ][ 'Required' ]#" index="Ach">
					<!--- Create a running total --->
					<cfif ! StructKeyExists( Total, "A" & Ach.ID )>
						<cfset Total[ 'A' & Ach.ID ] = 0 />
					</cfif>
					<td class="center">
						<cfif StructFind( Achs, "A" & Ach.ID )>
							<img src="images/check.png" alt="Completed" />
							<cfset AchCompleted++ />
							<cfset Total[ 'A' & Ach.ID ]++ />
						<cfelse>
							<img src="images/x.png" alt="Not Completed" />
						</cfif>	
					</td>					
				</cfloop>
				<td class="percent">#displayPercent( AchCompleted, ArrayLen( Tiers[ Tier ][ 'Required' ] ) )#</td>
				<!--- Track the meta total too --->
				<cfif ! StructKeyExists( Total, "A" & Tiers[ Tier ][ 'Meta' ].Id )>
					<cfset Total[ "A" & Tiers[ Tier ][ 'Meta' ].Id ] = 0 />
				</cfif>
				<cfif AchCompleted EQ ArrayLen( Tiers[ Tier ][ 'Required' ] )>
					<cfset Total[ "A" & Tiers[ Tier ][ 'Meta' ].Id ]++ />
				</cfif>
			</tr>
		</cfloop>
		<!--- Display Totals --->
		<tr>
			<td class="total">&nbsp;</td>
			<cfloop array="#Tiers[ Tier ][ 'Required' ]#" index="Ach">
				<td class="total">#displayPercent( Total[ 'A' & Ach.Id ], CharsDisplayed )#</td>
			</cfloop>
			<td class="total percent">#displayPercent( Total[ 'A' & Tiers[ Tier ][ 'Meta' ].Id ], CharsDisplayed )#</td>
		</tr>
	</table>
	<br/><br/>
</cfloop>

<p class="disclaimer">Only players active within the last two weeks and who have at least one achievement completed are shown in the table. ASCII names are also broken for some reason.</p>
</cfoutput>

<cffunction name="displayPercent">
	<cfargument name="Numerator" />
	<cfargument name="Denominator" />

	<cfreturn '<span title="#Arguments.Numerator#/#Arguments.Denominator#">#NumberFormat( Arguments.Numerator / Arguments.Denominator * 100, "0.0" )#%</span>' />
</cffunction>

<cffunction name="displayIcon">
	<cfargument name="Ach" required="yes" type="struct" />
	
	<cfreturn '<a href="http://wowhead.com/achievement=#Arguments.Ach.Id#"><img src="http://wow.zamimg.com/images/wow/icons/medium/#Arguments.Ach.Icon#.jpg" alt="#Arguments.Ach.ID#" /></a>' />
</cffunction>

<cfcatch>
	<cfdump var="#cfcatch#" />
</cfcatch>
</cftry>

</body>
</html>