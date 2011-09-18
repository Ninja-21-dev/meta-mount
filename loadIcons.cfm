<!--- Load Ach icons --->
<cfset AchJSON = FileRead( 'achievementIcons.json' ) />

<cfdump var="#isJSON( AchJSON )#" />