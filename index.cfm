<script type="text/javascript" src="http://static.wowhead.com/widgets/power.js" defer="defer"></script>
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

<cfloop list="T11,T12" index="Tier">
	<table border="1">
		<tr>
			<th colspan="#2+ArrayLen( Tiers[ Tier ][ 'Required' ] )#">#Tier#</th>
		</tr>
		<tr>
			<th>Character</th>
			<cfloop array="#Tiers[ Tier ][ 'Required' ]#" index="Ach">
				<th><a href="http://wowhead.com/achievement=#Ach.Id#"><img src="http://wow.zamimg.com/images/wow/icons/medium/#Ach.Icon#.jpg" alt="#Ach.ID#" /></a></th>
			</cfloop>
			<th><a href="http://wowhead.com/achievement=#Tiers[ Tier ][ 'Meta' ].Id#"><img src="http://wow.zamimg.com/images/wow/icons/medium/#Tiers[ Tier ][ 'Meta' ].Icon#.jpg" alt="#Tiers[ Tier ][ 'Meta' ].Id#" /></a></th>
		</tr>
		<cfloop query="getChars">
			<!--- Convert to Struct --->
			<cfset Achs = DeSerializeJSON( getChars[ Tier ][ getChars.CurrentRow ] ) />
						
			<!--- Ensure we have at least a 1 --->			
			<cfif ArrayLen( StructFindValue( Achs, Value ) ) EQ 0>
				<cfcontinue />
			</cfif>
			
			<cfset Counter = 0 />
			<tr>
				<th>#getChars.CharName#</th>
				<cfloop array="#Tiers[ Tier ][ 'Required' ]#" index="Ach">
					<td align="center">
						<cfif StructFind( Achs, "A" & Ach.ID )>
							<img src="images/check.png" alt="Completed" />
							<cfset Counter++ />
						<cfelse>
							<img src="images/x.png" align="Not Completed" />
						</cfif>	
					</td>				
				</cfloop>
				<td align="right">#NumberFormat( Counter / ArrayLen( Tiers[ Tier ][ 'Required' ] ) * 100, "0.0" )#%</td>
			</tr>
		</cfloop>
	</table>
	<br/><br/>
</cfloop>

</cfoutput>

<cfcatch>
	<cfdump var="#cfcatch#" />
</cfcatch>
</cftry>