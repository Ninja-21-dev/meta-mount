CREATE TABLE `mounts` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ServerName` varchar(30) CHARACTER SET utf8 NOT NULL,
  `GuildName` varchar(30) CHARACTER SET utf8 NOT NULL,
  `CharName` varchar(12) CHARACTER SET utf8 NOT NULL,
  `T11` varchar(291) NOT NULL,
  `T12` varchar(255) NOT NULL,
  `T13` varchar(255) NOT NULL,
  `LastUpdated` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `character_UNIQUE` ( `ServerName`, `GuildName`, `CharName` )
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1