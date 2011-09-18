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

<style type="text/css">
body {
	background: black;
}
.ach table, tr, th, td {
	margin: 0;
	padding: 0;
	border: 0;
	outline: 0;
	font-size: 100%;
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
}
td.icon { 
	text-align:center; 
	padding: 0px;
}
.ach th {
	height:34px;
	padding:0;
	color: #bcbdbd;
}
td.label {
	text-align: right; 
	word-spacing: -1px; 
	color: #bcbdbd; 
	font-size: 12px; 
	padding-right: 12px; 
}
td.percent {
	text-align: right; 
	word-spacing: -1px; 
	color: #bcbdbd; 
	font-size: 12px;
	border-right: 0;
}
</style>

<cfoutput>

<cfloop list="T11,T12" index="Tier">
	<table cellspacing="0" cellpadding="0" class="ach">
		<tr>
			<th colspan="#2+ArrayLen( Tiers[ Tier ][ 'Required' ] )#">#Tier#</th>
		</tr>
		<tr>
			<td class="label">Character</td>
			<cfloop array="#Tiers[ Tier ][ 'Required' ]#" index="Ach">
				<td class="icon"><a href="http://wowhead.com/achievement=#Ach.Id#"><img src="http://wow.zamimg.com/images/wow/icons/medium/#Ach.Icon#.jpg" alt="#Ach.ID#" /></a></td>
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
				<td class="label">#getChars.CharName#</td>
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
				<td class="percent">#NumberFormat( Counter / ArrayLen( Tiers[ Tier ][ 'Required' ] ) * 100, "0.0" )#%</td>
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