


CREATE TABLE IF NOT EXISTS ceb_entry 
(
    entryid     int(11) NOT NULL,
    entry       text NOT NULL,

    PRIMARY KEY  (entryid)
);


CREATE TABLE IF NOT EXISTS ceb_word
(
    entryid     int(11) NOT NULL default '0',
    word        varchar(32) NOT NULL,
    type        int(11) NOT NULL default '0',

    KEY word (word)
);
