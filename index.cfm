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

<cfoutput>

<cfloop list="T11,T12" index="Tier">
	<!--- Need a static ach list --->
	<cfset AchList = StructKeyList( DeSerializeJSON( getChars[ Tier ][ 1 ] ) ) />
	<table border="1">
		<tr>
			<th colspan="#2+ListLen( AchList )#">#Tier#</th>
		</tr>
		<tr>
			<th>Character</th>
			<cfloop list="#AchList#" index="Ach">
				<th>#Ach#</th>
			</cfloop>
			<th>% Done</th>
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
				<cfloop list="#AchList#" index="Ach">
					<cfif StructFind( Achs, Ach )>
						<td align="center">Yes</td>
						<cfset Counter++ />
					<cfelse>
						<td align="center">No</td>
					</cfif>						
				</cfloop>
				<td align="right">#NumberFormat( Counter / ListLen( AchList ) * 100, "0.0" )#%</td>
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