<?xml version="1.0" encoding="ISO-8859-1"?>
<!DOCTYPE xsl:stylesheet [

<!ENTITY lf         "&#x0A;"    >
<!ENTITY dagger     "&#x2020;"  >

]>

<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:local="localhost"
    exclude-result-prefixes="xs dc local fn">

<xsl:output
    method="text"
    indent="no"
    encoding="UTF-8"/>

<xsl:param name="prefix" select="'wced'"/>

<!-- For generating the database for the Android App, this needs to be set to false(); for the site, use true() -->
<xsl:param name="generateWordTable" select="false()"/>


<xsl:key name="id" match="*[@id]" use="@id"/>


<xsl:template match="/">
    <xsl:result-document href="SQL/structure.sql" method="text" encoding="UTF-8">
        <xsl:call-template name="database-structure"/>
    </xsl:result-document>

    <xsl:result-document href="SQL/structure-sqlite.sql" method="text" encoding="UTF-8">
        <xsl:call-template name="database-structure-sqlite"/>
    </xsl:result-document>

    <xsl:text>BEGIN TRANSACTION;&lf;</xsl:text>
    <xsl:apply-templates mode="entries" select="dictionary/entry"/>
    <xsl:text>COMMIT;&lf;</xsl:text>
</xsl:template>


<xsl:template name="database-structure-sqlite" expand-text="yes">

DROP TABLE IF EXISTS "android_metadata";
CREATE TABLE "android_metadata" (
    "locale" TEXT DEFAULT 'en_US'
);

INSERT INTO "android_metadata" VALUES('en_US');

DROP TABLE IF EXISTS "{$prefix}_entry";
CREATE TABLE "{$prefix}_entry" (
    "_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "head" VARCHAR,
    "page" INTEGER,
    "entry" TEXT
);

DROP TABLE IF EXISTS "{$prefix}_head";
CREATE TABLE "{$prefix}_head" (
    "_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "head" VARCHAR,
    "normalized_head" VARCHAR,
    "entryid" INTEGER,
    "type" CHAR,
    "pos" varchar
);

DROP TABLE IF EXISTS "{$prefix}_translation";
CREATE TABLE "{$prefix}_translation" (
    "_id" INTEGER PRIMARY KEY NOT NULL,
    "entryid" INTEGER,
    "translation" VARCHAR
);

<xsl:if test="$generateWordTable">

DROP TABLE IF EXISTS "{$prefix}_word";
CREATE TABLE "{$prefix}_word" (
    "_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "entryid" INTEGER,
    "flags" INTEGER,
    "word" VARCHAR,
    "lang" VARCHAR
);

</xsl:if>

</xsl:template>



<xsl:template name="database-structure" expand-text="yes">

CREATE TABLE IF NOT EXISTS `{$prefix}_metadata` (
    `workid` varchar(4) NOT NULL,
    `author` varchar(32) NOT NULL default '',
    `title` varchar(32) NOT NULL default '',
    `year` varchar(32) NOT NULL default '',
    `description` text NOT NULL default '',

    PRIMARY KEY (`workid`)
);

INSERT INTO `{$prefix}_metadata` VALUES (
    'wced',
    'John U. Wolff',
    'A Dictionary of Cebuano Visayan',
    '1972',
    'intro'
    );

CREATE TABLE IF NOT EXISTS `{$prefix}_flag` (
    `flagid` int(11) NOT NULL,
    `description` varchar(32) NOT NULL default '',

    PRIMARY KEY (`flagid`)
);

INSERT INTO `{$prefix}_flag` VALUES (1, 'First Headword');
INSERT INTO `{$prefix}_flag` VALUES (2, 'Headwords');
INSERT INTO `{$prefix}_flag` VALUES (4, 'Other Words');
INSERT INTO `{$prefix}_flag` VALUES (8, 'Exact');
INSERT INTO `{$prefix}_flag` VALUES (16, 'Normalized');

CREATE TABLE IF NOT EXISTS `{$prefix}_language` (
    `lang` varchar(5) NOT NULL,
    `name` varchar(32) NOT NULL default '',

    PRIMARY KEY (`lang`)
);

INSERT INTO `{$prefix}_language` VALUES ("ceb", "Cebuano");
INSERT INTO `{$prefix}_language` VALUES ("en-US", "English (US)");

CREATE TABLE IF NOT EXISTS `{$prefix}_entry` (
    `entryid` int(11) NOT NULL auto_increment,
    `word` varchar(32) NOT NULL default '',
    `page` varchar(4) NOT NULL default '',
    `entry` text NOT NULL default '',

    PRIMARY KEY (`entryid`),
    KEY `word` (`word`)
);

CREATE TABLE IF NOT EXISTS `{$prefix}_word` (
    `entryid` int(11) NOT NULL,
    `flags` int(11) NOT NULL,
    `word` varchar(32) NOT NULL default '',
    `lang` varchar(5) NOT NULL default '',

    KEY `word` (`word`)
);

CREATE TABLE IF NOT EXISTS `{$prefix}_head` (
    `entryid` int(11) NOT NULL,
    `head` varchar(64) NOT NULL default '',
    `normalized_head` varchar(64) NOT NULL default '',
    `type` varchar(6) NOT NULL default '',
    `pos` varchar(6) NOT NULL default '',

    KEY `head` (`head`)
);

CREATE TABLE IF NOT EXISTS `{$prefix}_translation` (
    `entryid` int(11) NOT NULL,
    `translation` varchar(64) NOT NULL default '',

    KEY `translation` (`translation`)
);

CREATE TABLE IF NOT EXISTS `{$prefix}_note` (
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

</xsl:template>


<xsl:template mode="entries" match="dictionary/entry">

    <xsl:variable name="entryid">
        <xsl:value-of select="@id"/>
    </xsl:variable>

    <xsl:variable name="entrytext">
        <xsl:apply-templates mode="nodetostring" select="."/>
    </xsl:variable>

    <xsl:variable name="headword">
        <xsl:value-of select="(.//form)[1]"/>
    </xsl:variable>

    <xsl:variable name="normalizedHeadword">
        <xsl:value-of select="local:normalize($headword)"/>
    </xsl:variable>

    <xsl:variable name="isCrossReference">
        <xsl:value-of select="if (xr) then 1 else 0"/>
    </xsl:variable>

    <xsl:value-of select="local:insertEntrySql($entryid, $normalizedHeadword, $entrytext, @page)"/>

    <xsl:if test="$generateWordTable">
        <!-- Find all words with language for this entry -->
        <xsl:variable name="words">
            <xsl:apply-templates mode="words"/>
        </xsl:variable>

        <!-- Find unique words in entry -->
        <xsl:for-each-group select="$words/w" group-by="@xml:lang">
            <xsl:for-each-group select="current-group()" group-by=".">
                <xsl:variable name="flags" select="current-group()[1]/@flags"/>
                <xsl:variable name="flags" select="if (current-group()[1] = $headword) then $flags + 1 else $flags"/>
                <xsl:variable name="flags" select="if (current-group()[1] = current-group()[1]/@form) then $flags + 24 else $flags + 8"/>
                <xsl:value-of select="local:insertWordSql($entryid, $flags, current-group()[1], current-group()[1]/@xml:lang)"/>
            </xsl:for-each-group>
        </xsl:for-each-group>

        <!-- Find unique normalized forms of words in entry -->
        <xsl:for-each-group select="$words/w[@form != .]" group-by="@xml:lang">
            <xsl:for-each-group select="current-group()" group-by=".">
                <xsl:variable name="flags" select="current-group()[1]/@flags"/>
                <xsl:variable name="flags" select="if (current-group()[1]/@form = $normalizedHeadword) then $flags + 1 else $flags"/>
                <xsl:value-of select="local:insertWordSql($entryid, $flags + 16, current-group()[1]/@form, current-group()[1]/@xml:lang)"/>
            </xsl:for-each-group>
        </xsl:for-each-group>
    </xsl:if>

    <!-- Find all headings -->
    <xsl:variable name="heads">
        <xsl:apply-templates mode="heads" select=".//form|.//formx"/>
    </xsl:variable>

    <!-- List unique head-words in entry -->
    <xsl:for-each-group select="$heads/h" group-by=".">
        <xsl:variable name="entryType" select="if (current-group()[1] = $headword) then 'm' else 's'"/>
        <xsl:variable name="pos" select="current-group()[1]/@pos"/>
        <xsl:value-of select="local:insertHeadSql($entryid, current-group()[1], local:normalize(current-group()[1]), $entryType, $pos)"/>
    </xsl:for-each-group>

    <!-- Find all translations -->
    <xsl:variable name="translations">
        <xsl:apply-templates mode="translations" select=".//tr"/>
    </xsl:variable>

    <!-- List unique head-words in entry -->
    <xsl:for-each-group select="$translations/t" group-by=".">
        <xsl:value-of select="local:insertTranslationSql($entryid, current-group()[1])"/>
    </xsl:for-each-group>

</xsl:template>


<!-- MODE: translations -->

<xsl:template mode="translations" match="tr">
    <xsl:variable name="translations">
        <xsl:apply-templates mode="translations"/>
    </xsl:variable>

    <!-- remove asterisks and daggers and split on comma or slash -->
    <xsl:for-each select="tokenize(replace($translations, '[*&dagger;]', ''), '[,/][,/ ]*')">
        <t>
            <xsl:value-of select="."/>
        </t>
    </xsl:for-each>
</xsl:template>

<xsl:template mode="translations" match="sub"/>

<xsl:template mode="translations" match="pb"/>

<xsl:template mode="translations" match="abbr">
    <xsl:value-of select="@expan"/>
</xsl:template>


<!-- MODE: heads -->

<xsl:template mode="heads" match="form|formx">
    <xsl:variable name="heads">
        <xsl:apply-templates mode="heads"/>
    </xsl:variable>

    <!-- TODO: determine what POS and X-ref status this headword has -->
    <!-- POS can be found in the hom/@role siblings of this element -->
    <xsl:variable name="pos"><xsl:value-of select="../hom/@role"/></xsl:variable>
    <xsl:variable name="pos"><xsl:value-of select="translate($pos, ' ', '')"/></xsl:variable>
    <!-- XREF can be found digged away in the hom/sense/trans/xr element -->

    <!-- remove asterisks and daggers and split on comma or slash -->
    <xsl:for-each select="tokenize(replace($heads, '[*&dagger;]', ''), '[,/][,/ ]*')">
        <h pos="{$pos}">
            <xsl:value-of select="."/>
        </h>
    </xsl:for-each>
</xsl:template>

<xsl:template mode="heads" match="sub"/>

<xsl:template mode="heads" match="pb"/>

<xsl:template mode="heads" match="abbr">
    <xsl:value-of select="@expan"/>
</xsl:template>



<xsl:function name="local:normalize" as="xs:string">
    <xsl:param name="string" as="xs:string"/>

    <xsl:value-of select="fn:lower-case(local:strip_diacritics($string))"/>
</xsl:function>


<!-- SQL support functions -->

<xsl:function name="local:escapeSql" as="xs:string">
    <xsl:param name="string" as="xs:string"/>

    <xsl:value-of select="fn:replace($string, '&quot;', '&quot;&quot;')"/>
</xsl:function>


<!-- INSERT INTO `wced_entry` VALUES (entryid, word, entry, page); -->

<xsl:function name="local:insertEntrySql">
    <xsl:param name="entryid"/>
    <xsl:param name="word"/>
    <xsl:param name="entry"/>
    <xsl:param name="page"/>

    <xsl:text expand-text="yes">INSERT INTO `{$prefix}_entry` VALUES ({$entryid}, &quot;{$word}&quot;, &quot;{$page}&quot;, &quot;{local:escapeSql($entry)}&quot;);&lf;</xsl:text>
</xsl:function>


<!-- INSERT INTO `wced_head` VALUES (id, head, normalizedHead); -->

<xsl:function name="local:insertHeadSql" expand-text="yes">
    <xsl:param name="entryid"/>
    <xsl:param name="head"/>
    <xsl:param name="normalizedHead"/>
    <xsl:param name="entryType"/>
    <xsl:param name="pos"/>

    <xsl:if test="$head != ''">
        <xsl:text expand-text="yes">INSERT INTO `{$prefix}_head` (entryid, head, normalized_head, type, pos) VALUES ({$entryid}, &quot;{$head}&quot;, &quot;{$normalizedHead}&quot;, &quot;{$entryType}&quot;, &quot;{$pos}&quot;);&lf;</xsl:text>
    </xsl:if>
</xsl:function>


<!-- INSERT INTO `wced_translation` VALUES (id, translation); -->

<xsl:function name="local:insertTranslationSql" expand-text="yes">
    <xsl:param name="entryid"/>
    <xsl:param name="translation"/>

    <xsl:if test="$translation != ''">
        <xsl:text expand-text="yes">INSERT INTO `{$prefix}_translation` (entryid, translation) VALUES ({$entryid}, &quot;{$translation}&quot;);&lf;</xsl:text>
    </xsl:if>
</xsl:function>


<!-- INSERT INTO `wced_word` VALUES (entryid, flags, "word", "lang"); -->

<xsl:function name="local:insertWordSql">
    <xsl:param name="entryid"/>
    <xsl:param name="flags"/>
    <xsl:param name="word"/>
    <xsl:param name="lang"/>

    <xsl:if test="$word != ''">
        <xsl:text expand-text="yes">INSERT INTO `{$prefix}_word` (entryid, flags, word, lang) VALUES ({$entryid}, {$flags}, &quot;{$word}&quot;, &quot;{$lang}&quot;);&lf;</xsl:text>
    </xsl:if>
</xsl:function>


<!-- Code copied and modified from tei2html/tei2wl.xsl -->

<xsl:function name="local:words" as="xs:string*">
    <xsl:param name="string" as="xs:string"/>
    <xsl:analyze-string select="$string" regex="{'[\p{L}\p{N}\p{M}-]+'}">
        <xsl:matching-substring>
            <xsl:sequence select="."/>
        </xsl:matching-substring>
    </xsl:analyze-string>
</xsl:function>

<xsl:function name="local:strip_diacritics" as="xs:string">
    <xsl:param name="string" as="xs:string"/>
    <xsl:value-of select="fn:replace(fn:normalize-unicode($string, 'NFD'), '\p{M}', '')"/>
</xsl:function>

<!-- Ignore POS codes, verb classes, and numbers -->
<xsl:template mode="words" match="pos | itype | number | sub"/>

<!-- Handle both expanded and collapsed forms -->
<xsl:template mode="words" match="abbr">
    <xsl:apply-templates mode="words" select="@expan"/>
    <xsl:apply-templates mode="words"/>
</xsl:template>

<xsl:template mode="words" match="@expan|text()">
    <xsl:variable name="lang" select="(ancestor-or-self::*/@lang|ancestor-or-self::*/@xml:lang)[last()]"/>

    <!-- Determine word type flags: 2 if headword or suggested translation; 4 otherwise -->
    <xsl:variable name="flags" select="if (ancestor-or-self::form|ancestor-or-self::tr) then 2 else 4"/>

    <xsl:for-each select="local:words(.)">
        <xsl:if test=". != ''">
            <w>
                <xsl:variable name="form" select="fn:lower-case(local:strip_diacritics(.))"/>

                <xsl:attribute name="xml:lang" select="$lang"/>
                <xsl:attribute name="form" select="$form"/>
                <xsl:attribute name="flags" select="$flags"/>
                <xsl:value-of select="."/>
            </w>
        </xsl:if>
    </xsl:for-each>
</xsl:template>


<!-- Begin node to string conversion -->

<!-- Taken from https://raw.github.com/iwyg/xml-nodeset-to-string/master/nodetostring.xsl
See: http://symphony-cms.com/download/xslt-utilities/view/79266/

Copyright 2011, Thomas Appel, http://thomas-appel.com, mail(at)thomas-appel.com
dual licensed under MIT and GPL license
http://dev.thomas-appel.com/licenses/mit.txt
http://dev.thomas-appel.com/licenses/gpl.txt

-->

<xsl:variable name="q">
    <xsl:text>"</xsl:text>
</xsl:variable>

<xsl:variable name="empty"/>

<xsl:template match="* | text()" mode="nodetostring">
    <xsl:choose>
        <xsl:when test="boolean(name())">
            <xsl:choose>
                <!--
                     if element is not empty (removed normalize-space(.) from test below)
                -->
                <xsl:when test=". != $empty or *">
                    <xsl:apply-templates select="." mode="opentag"/>
                        <xsl:apply-templates select="* | text()" mode="nodetostring"/>
                    <xsl:apply-templates select="." mode="closetag"/>
                </xsl:when>
                <!--
                     assuming empty tags are self closing, e.g. <img/>, <source/>, <input/>
                -->
                <xsl:otherwise>
                    <xsl:apply-templates select="." mode="selfclosetag"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="."/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="*" mode="selfclosetag">
    <xsl:text>&lt;</xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:apply-templates select="@*" mode="attribs"/>
    <xsl:text>/&gt;</xsl:text>
</xsl:template>

<xsl:template match="*" mode="opentag">
    <xsl:text>&lt;</xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:apply-templates select="@*" mode="attribs"/>
    <xsl:text>&gt;</xsl:text>
</xsl:template>

<xsl:template match="*" mode="closetag">
    <xsl:text>&lt;/</xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:text>&gt;</xsl:text>
</xsl:template>

<xsl:template match="@*" mode="attribs">
    <xsl:if test="position() = 1">
        <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:value-of select="concat(name(), '=', $q, ., $q)"/>
    <xsl:if test="position() != last()">
        <xsl:text> </xsl:text>
    </xsl:if>
</xsl:template>

<!-- End node to string conversion -->

</xsl:stylesheet>
