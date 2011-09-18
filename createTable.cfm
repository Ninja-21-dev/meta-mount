<!--- Prevent this page from being called accidently --->
<cfif ! StructKeyExists( url, "reload" )>
	<cflocation url="./" addtoken="no" />
</cfif>

<!--- Make Table --->
<cfquery>
DROP TABLE IF EXISTS `mounts`
</cfquery>
Dropped.<br/>

<cfquery>
CREATE TABLE `mounts` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `CharName` varchar(12) CHARACTER SET utf8 NOT NULL,
  `T11` varchar(291) NOT NULL,
  `T12` varchar(255) NOT NULL,
  `LastUpdated` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `character_UNIQUE` (`CharName`)
) ENGINE=InnoDB AUTO_INCREMENT=153 DEFAULT CHARSET=latin1
</cfquery>

Created mounts table.