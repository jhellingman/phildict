

DROP TABLE IF EXISTS "android_metadata";
CREATE TABLE "android_metadata"
(
    "locale" TEXT DEFAULT 'en_US'
);

INSERT INTO "android_metadata" VALUES('en_US');

DROP TABLE IF EXISTS "kved_entry";
CREATE TABLE "kved_entry"
(
    "_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "head" VARCHAR,
    "page" INTEGER,
    "entry" TEXT
);

DROP TABLE IF EXISTS "kved_head";
CREATE TABLE "kved_head"
(
    "_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "head" VARCHAR,
    "normalized_head" VARCHAR,
    "entryid" INTEGER,
    "type" CHAR,
    "pos" varchar
);

DROP TABLE IF EXISTS "kved_translation";
CREATE TABLE "kved_translation"
(
    "_id" INTEGER PRIMARY KEY NOT NULL,
    "entryid" INTEGER,
    "translation" VARCHAR
);

DROP TABLE IF EXISTS "kved_word";
CREATE TABLE "kved_word"
(
    "_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "entryid" INTEGER,
    "flags" INTEGER,
    "word" VARCHAR,
    "lang" VARCHAR
);

