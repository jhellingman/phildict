<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    version="2.0"
    exclude-result-prefixes="xs dc">

    <xsl:output 
        method="text" 
        indent="no"
        encoding="UTF-8"/>

    <xsl:key name="id" match="*[@id]" use="@id"/>

    <xsl:template match="/">

        <xsl:result-document href="words.sql" method="xml" encoding="UTF-8">
            <xsl:apply-templates mode="words" select="//f"/>
        </xsl:result-document>


    </xsl:template>



    <xsl:template mode="words" match="w">

        <xsl:variable name="wordid">
            <xsl:value-of select="position()"/>
        </xsl:variable>

        <xsl:text>
INSERT INTO `wced_word` VALUES (</xsl:text>
        <xsl:value-of select="$wordid"/><xsl:text>, </xsl:text>
        <xsl:text>&quot;</xsl:text><xsl:value-of select="."/><xsl:text>&quot;</xsl:text>
        <xsl:text>);</xsl:text>
    </xsl:template>



<!-- INSERT INTO `kved_word` VALUES (18, "yégwa", "yigwa", "HW"); -->

</xsl:stylesheet>
