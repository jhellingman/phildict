#summary Introduction to the database structures used.

Based on [http://www.pgdp.net/wiki/User:Jhellingman/Philippine_Works_in_Progress/Wolff_CED#Database_Structure material originally placed on the PGDP Wiki]

= Introduction =

The database structure for dictionaries will be fairly simple. Three main tables will be used.

The database will be initially filled from the XML master-files, that use some variant of [http://www.tei-c.org/release/doc/tei-p5-doc/en/html/DI.html TEI encoding for Dictionaries]. Some fields will retain the internal XML tagging used (and should be well-formed XML fragments in their own right).

= Data Tables =

== Entry Table ==

Entries will be stored in a main entry table:

{{{
CREATE TABLE  dict_entry 
(
  entryid   int unsigned NOT NULL,
  entry     text NOT NULL
);
}}}

  * `entryid`: a unique id for the entry.
  * `entry`: the entry entry as a well-formed XML fragment.

== Word Table ==

To find words in the main entry, a large indexing table will be used:

{{{
CREATE TABLE dict_word 
(
  wordid     int unsigned NOT NULL,
  language   char(3) NOT NULL,
  word       varchar(32) NOT NULL,
  normalized varchar(32) NOT NULL,
  type       tinyint unsigned NOT NULL default '0'
);
}}}

  * `wordid`: a unique id for the word.
  * `language`: the language the word is in.
  * `word`: the word as it appears in the dictionary.
  * `normalized`: the word normalized according to language specific rules.
  * `type`: an indication of the type of the word.

The type is encoded as a bit field, in a dictionary dependent way. For example, the following meanings can be used for Wolff's Cebuano dictionary:

|| *Value*  || *Derived from* || *Meaning* ||
|| 1        || `//form`       || Headword ||
|| 2        || `//tr`         || Translation ||
|| 4        || {{{*[lang='ceb']}}} || Any Cebuano word ||
|| 8        || {{{*[lang='en']}}}  || Any English word ||
|| 16       || `//form`       || Cebuano word derived from pattern (e.g., if the headword for a sub-entry is *paN-* and the main headword is *abla*, ''pangabla'' will be added as this type.) ||
|| 32       || `//itype`      || Cebuano word derived from verb codes (including those derived from patterns). ||
|| 64       || `//form`       || _l_-dropped variant. (e.g., _balay_ becoming _báy_) ||


== Link Table ==

This word table is related to the entry table with a link table:

{{{
CREATE TABLE dict_wordentry 
(
  wordid     int unsigned NOT NULL,
  entryid    int unsigned NOT NULL,
);
}}}

= Metadata =

{{{
CREATE TABLE dictionary
(
  dictid     int unsigned NOT NULL,
  title      varchar(32) NOT NULL,
  author     varchar(32) NOT NULL,
  language   char(3),
);
}}}


= User Data =

{{{
CREATE TABLE user 
(
  userid     int unsigned NOT NULL,
  name       varchar(32) NOT NULL,
  email      varchar(32) NOT NULL,
  token      varchar(32),
  verified   char(1) NOT NULL default 'F',
  blocked    char(1) NOT NULL default 'F',
  password   varchar(32) NOT NULL,
);
}}}

  * `userid`: Unique identifier for user; used internally.
  * `name`: display name for user; used externally.
  * `email`: email address of users; used externally to identify users (for logon purposes).
  * `token`: random token, used to verify email addresses, password change requests, etc.
  * `verified`: boolean, 'T' if email address of user is verified.
  * `blocked`: boolean, 'T' if email address was previously used for abuse.
  * `password`: actually cryptographic has of salted password.


{{{
CREATE TABLE userlogin 
(
  userid     int unsigned NOT NULL,
  success    char(1) NOT NULL default 'F',
  logintime  datetime,
  ip         char(10),
  browser    text
);
}}}

Maintain log of login and login-attempts.

  * `userid`: User id.
  * `success`: 'T' if login was successful.
  * `logintime`: UTC timestamp of login time.
  * `ip`: IP address from which request came.
  * `browser`: Browser identification string.

= Supplementary Data =
