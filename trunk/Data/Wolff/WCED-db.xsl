<?xml version="1.0" encoding="ISO-8859-1"?>
<!DOCTYPE xsl:stylesheet [

<!ENTITY lf "&#x0A;" >

]>

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:local="localhost"
    version="2.0"
    exclude-result-prefixes="xs dc local fn">

<xsl:output
    method="text"
    indent="no"
    encoding="UTF-8"/>


<xsl:key name="id" match="*[@id]" use="@id"/>


<xsl:variable name="prefix" select="'wced'"/>


<xsl:template match="/">
    <xsl:result-document href="WCED-structure.sql" method="text" encoding="UTF-8">
        <xsl:call-template name="database-structure"/>
    </xsl:result-document>

    <xsl:apply-templates mode="entries" select="dictionary/entry"/>
</xsl:template>


<xsl:template name="database-structure">

CREATE TABLE IF NOT EXISTS `<xsl:value-of select="$prefix"/>_metadata`
(
    `workid` varchar(4) NOT NULL,
    `author` varchar(32) NOT NULL default '',
    `title` varchar(32) NOT NULL default '',
    `year` varchar(32) NOT NULL default '',
    `description` text NOT NULL default '',

    PRIMARY KEY (`workid`)
);

INSERT INTO `<xsl:value-of select="$prefix"/>_metadata` VALUES (
    'wced',
    'John U. Wolff',
    'A Dictionary of Cebuano Visayan',
    '1972',
    'intro'
    );

CREATE TABLE IF NOT EXISTS `<xsl:value-of select="$prefix"/>_flag`
(
    `flagid` int(11) NOT NULL,
    `description` varchar(32) NOT NULL default '',

    PRIMARY KEY (`flagid`)
);

INSERT INTO `<xsl:value-of select="$prefix"/>_flag` VALUES (1, 'First Headword');
INSERT INTO `<xsl:value-of select="$prefix"/>_flag` VALUES (2, 'Headwords');
INSERT INTO `<xsl:value-of select="$prefix"/>_flag` VALUES (4, 'Other Words');
INSERT INTO `<xsl:value-of select="$prefix"/>_flag` VALUES (8, 'Exact');
INSERT INTO `<xsl:value-of select="$prefix"/>_flag` VALUES (16, 'Normalized');

CREATE TABLE IF NOT EXISTS `<xsl:value-of select="$prefix"/>_language`
(
    `lang` varchar(5) NOT NULL,
    `name` varchar(32) NOT NULL default '',

    PRIMARY KEY (`lang`)
);

INSERT INTO `<xsl:value-of select="$prefix"/>_language` VALUES ("ceb", "Cebuano");
INSERT INTO `<xsl:value-of select="$prefix"/>_language` VALUES ("en-US", "English (US)");

CREATE TABLE IF NOT EXISTS `<xsl:value-of select="$prefix"/>_entry`
(
    `entryid` int(11) NOT NULL auto_increment,
    `word` varchar(32) NOT NULL default '',
    `page` varchar(4) NOT NULL default '',
    `entry` text NOT NULL default '',

    PRIMARY KEY (`entryid`),
    KEY `word` (`word`)
);

CREATE TABLE IF NOT EXISTS `<xsl:value-of select="$prefix"/>_word`
(
    `entryid` int(11) NOT NULL,
    `flags` int(11) NOT NULL,
    `word` varchar(32) NOT NULL default '',
    `lang` varchar(5) NOT NULL default '',

    KEY `word` (`word`)
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
        <xsl:value-of select="(.//w)[1]"/>
    </xsl:variable>

    <xsl:variable name="normalizedHeadword">
        <xsl:value-of select="fn:lower-case(local:strip_diacritics($headword))"/>
    </xsl:variable>

    <xsl:value-of select="local:insertEntrySql($entryid, $normalizedHeadword, $entrytext, @page)"/>

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

    <!-- Find unique normalized forms in entry -->
    <xsl:for-each-group select="$words/w[@form != .]" group-by="@xml:lang">
        <xsl:for-each-group select="current-group()" group-by=".">
            <xsl:variable name="flags" select="current-group()[1]/@flags"/>
            <xsl:variable name="flags" select="if (current-group()[1]/@form = $normalizedHeadword) then $flags + 1 else $flags"/>
            <xsl:value-of select="local:insertWordSql($entryid, $flags + 16, current-group()[1]/@form, current-group()[1]/@xml:lang)"/>
        </xsl:for-each-group>
    </xsl:for-each-group>

</xsl:template>


<!-- SQL support functions -->

<xsl:function name="local:escapeSql">
    <xsl:param name="string"/>

    <xsl:value-of select="fn:replace($string, '&quot;', '&quot;&quot;')"/>
</xsl:function>


<!-- INSERT INTO `wced_entry` VALUES (id, page, "entry"); -->

<xsl:function name="local:insertEntrySql">
    <xsl:param name="entryid"/>
    <xsl:param name="word"/>
    <xsl:param name="entry"/>
    <xsl:param name="page"/>

    <xsl:text>&lf;</xsl:text>
    <xsl:text>INSERT INTO `</xsl:text><xsl:value-of select="$prefix"/><xsl:text>_entry` VALUES (</xsl:text>
        <xsl:value-of select="$entryid"/>
        <xsl:text>, </xsl:text>
        <xsl:text>&quot;</xsl:text><xsl:value-of select="$word"/><xsl:text>&quot;</xsl:text>
        <xsl:text>, </xsl:text>
        <xsl:text>&quot;</xsl:text><xsl:value-of select="$page"/><xsl:text>&quot;</xsl:text>
        <xsl:text>, </xsl:text>
        <xsl:text>&quot;</xsl:text><xsl:value-of select="local:escapeSql($entry)"/><xsl:text>&quot;</xsl:text>
    <xsl:text>);</xsl:text>
</xsl:function>


<!-- INSERT INTO `wced_word` VALUES (id, flags, "word", "lang"); -->

<xsl:function name="local:insertWordSql">
    <xsl:param name="wordid"/>
    <xsl:param name="flags"/>
    <xsl:param name="word"/>
    <xsl:param name="lang"/>

    <xsl:text>&lf;</xsl:text>
    <xsl:text>INSERT INTO `</xsl:text><xsl:value-of select="$prefix"/><xsl:text>_word` VALUES (</xsl:text>
        <xsl:value-of select="$wordid"/>
        <xsl:text>, </xsl:text>
        <xsl:value-of select="$flags"/>
        <xsl:text>, </xsl:text>
        <xsl:text>&quot;</xsl:text><xsl:value-of select="$word"/><xsl:text>&quot;</xsl:text>
        <xsl:text>, </xsl:text>
        <xsl:text>&quot;</xsl:text><xsl:value-of select="$lang"/><xsl:text>&quot;</xsl:text>
    <xsl:text>);</xsl:text>
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


<!-- Ignore codes and numbers -->
<xsl:template mode="words" match="pos | itype | number | sub"/>


<xsl:template mode="words" match="text()">
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
                     if element is not empty
                -->
                <xsl:when test="normalize-space(.) != $empty or *">
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
