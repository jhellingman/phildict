<?xml version="1.0" encoding="ISO-8859-1"?>
<!DOCTYPE xsl:stylesheet [

<!ENTITY lf          "&#x0A;"           >

]>

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:local="localhost"
    version="2.0"
    exclude-result-prefixes="xs dc">

    <xsl:output 
        method="text" 
        indent="no"
        encoding="UTF-8"/>

    <xsl:key name="id" match="*[@id]" use="@id"/>


    <xsl:template match="/">

        <xsl:result-document href="words.sql" method="xml" encoding="UTF-8">
            <xsl:apply-templates mode="words" select="//w"/>
        </xsl:result-document>

    </xsl:template>



    <xsl:template mode="words" match="w">

        <xsl:variable name="wordid">
            <xsl:value-of select="position()"/>
        </xsl:variable>

        <xsl:value-of select="local:insertWordSql(., $wordid, 'ceb')"/>
    </xsl:template>


    <!-- INSERT INTO `wced_word` VALUES (1, "aaaa", "aaaa", "ceb"); -->

    <xsl:function name="local:insertWordSql">
        <xsl:param name="word"/>
        <xsl:param name="wordid"/>
        <xsl:param name="lang"/>

        <xsl:text>&lf;</xsl:text>
        <xsl:text>INSERT INTO `wced_word` VALUES (</xsl:text>
            <xsl:value-of select="$wordid"/>
            <xsl:text>, </xsl:text>
            <xsl:text>&quot;</xsl:text><xsl:value-of select="$word"/><xsl:text>&quot;</xsl:text>
            <xsl:text>, </xsl:text>
            <xsl:text>&quot;</xsl:text><xsl:value-of select="$lang"/><xsl:text>&quot;</xsl:text>
        <xsl:text>);</xsl:text>
    </xsl:function>

</xsl:stylesheet>
