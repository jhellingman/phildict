-- KVED-Structure.sql -- structure of the KVED SQL database.

-- Full entries

CREATE TABLE kved_entry (
    entryid         int(11) NOT NULL,
    entry           text NOT NULL,
    `page`          int(11) NOT NULL,

    PRIMARY KEY (entryid)
);


-- words

CREATE TABLE kved_word (
    wordid          int(11) NOT NULL,
    word            varchar(32) NOT NULL,
    normalized      varchar(32) NOT NULL,
    lang            char(3) NOT NULL,

    PRIMARY KEY (wordid),
    KEY word (word),
    KEY normalized (normalized)
);


-- link words to entries

CREATE TABLE kved_wordentry (
    wordid          int(11) NOT NULL,
    entryid         int(11) NOT NULL,

    KEY wordid (wordid)
);
