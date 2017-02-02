

CREATE TABLE IF NOT EXISTS `wced_metadata`
(
    `workid` varchar(4) NOT NULL,
    `author` varchar(32) NOT NULL default '',
    `title` varchar(32) NOT NULL default '',
    `year` varchar(32) NOT NULL default '',
    `description` text NOT NULL default '',

    PRIMARY KEY (`workid`)
);

INSERT INTO `wced_metadata` VALUES (
    'wced',
    'John U. Wolff',
    'A Dictionary of Cebuano Visayan',
    '1972',
    'intro'
    );

CREATE TABLE IF NOT EXISTS `wced_flag`
(
    `flagid` int(11) NOT NULL,
    `description` varchar(32) NOT NULL default '',

    PRIMARY KEY (`flagid`)
);

INSERT INTO `wced_flag` VALUES (1, 'First Headword');
INSERT INTO `wced_flag` VALUES (2, 'Headwords');
INSERT INTO `wced_flag` VALUES (4, 'Other Words');
INSERT INTO `wced_flag` VALUES (8, 'Exact');
INSERT INTO `wced_flag` VALUES (16, 'Normalized');

CREATE TABLE IF NOT EXISTS `wced_language`
(
    `lang` varchar(5) NOT NULL,
    `name` varchar(32) NOT NULL default '',

    PRIMARY KEY (`lang`)
);

INSERT INTO `wced_language` VALUES ("ceb", "Cebuano");
INSERT INTO `wced_language` VALUES ("en-US", "English (US)");

CREATE TABLE IF NOT EXISTS `wced_entry`
(
    `entryid` int(11) NOT NULL auto_increment,
    `word` varchar(32) NOT NULL default '',
    `page` varchar(4) NOT NULL default '',
    `entry` text NOT NULL default '',

    PRIMARY KEY (`entryid`),
    KEY `word` (`word`)
);

CREATE TABLE IF NOT EXISTS `wced_word`
(
    `entryid` int(11) NOT NULL,
    `flags` int(11) NOT NULL,
    `word` varchar(32) NOT NULL default '',
    `lang` varchar(5) NOT NULL default '',

    KEY `word` (`word`)
);

CREATE TABLE IF NOT EXISTS `wced_head`
(
    `entryid` int(11) NOT NULL,
    `head` varchar(64) NOT NULL default '',
    `normalized_head` varchar(64) NOT NULL default '',
    `type` varchar(6) NOT NULL default '',
    `pos` varchar(6) NOT NULL default '',

    KEY `head` (`head`)
);

CREATE TABLE IF NOT EXISTS `wced_translations`
(
    `entryid` int(11) NOT NULL,
    `translation` varchar(64) NOT NULL default '',

    KEY `translation` (`translation`)
);

CREATE TABLE IF NOT EXISTS `wced_note`
(
    `noteid` int(11) NOT NULL auto_increment,
    `entryid` int(11) NOT NULL,
    `userid` int(11) NOT NULL,
    `date` int(11) NOT NULL,
    `ip` varchar(16) NOT NULL default '',
    `note` text NOT NULL default '',
    `public` char(1) NOT NULL default 'F',

    PRIMARY KEY (`noteid`),
    KEY `entryid` (`entryid`),
    KEY `userid` (`userid`),
    KEY `date` (`date`)
);

