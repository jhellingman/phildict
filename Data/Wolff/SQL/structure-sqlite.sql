

DROP TABLE IF EXISTS "android_metadata";
CREATE TABLE "android_metadata" (
    "locale" TEXT DEFAULT 'en_US'
);

INSERT INTO "android_metadata" VALUES('en_US');

DROP TABLE IF EXISTS "wced_entry";
CREATE TABLE "wced_entry" (
    "_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "head" VARCHAR,
    "page" INTEGER,
    "entry" TEXT
);

DROP TABLE IF EXISTS "wced_head";
CREATE TABLE "wced_head" (
    "_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "head" VARCHAR,
    "normalized_head" VARCHAR,
    "entryid" INTEGER,
    "type" CHAR,
    "pos" varchar
);

DROP TABLE IF EXISTS "wced_translation";
CREATE TABLE "wced_translation" (
    "_id" INTEGER PRIMARY KEY NOT NULL,
    "entryid" INTEGER,
    "translation" VARCHAR
);

