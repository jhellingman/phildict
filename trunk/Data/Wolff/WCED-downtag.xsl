<?xml version="1.0" encoding="ISO-8859-1"?>
<!DOCTYPE xsl:stylesheet [

<!ENTITY larr        "&#x2190;"         >
<!ENTITY rarr        "&#x2192;"         >
<!ENTITY glots       "&#x0294;"         >
<!ENTITY amacracu    "&#x0101;&#x0301;" >
<!ENTITY imacracu    "&#x012B;&#x0301;" >
<!ENTITY umacracu    "&#x016B;&#x0301;" >
<!ENTITY acaron      "a&#x030C;"        >
<!ENTITY ucaron      "u&#x030C;"        >
<!ENTITY icaron      "i&#x030C;"        >
<!ENTITY schwa       "&#x0259;"         >

]>

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:local="http://localhost"
    version="2.0"
    exclude-result-prefixes="xs local">

    <xsl:output
        method="xml"
        indent="no"
        encoding="UTF-8"/>


    <xsl:template match="form|formx|b|bx">
        <hi rend="bold" lang="ceb">
            <xsl:apply-templates/>
        </hi>
    </xsl:template>


    <xsl:template match="number">
        <hi rend="bold" lang="xx">
            <xsl:apply-templates/>
        </hi>
    </xsl:template>


    <xsl:template match="i|ix">
        <hi lang="ceb">
            <xsl:apply-templates/>
        </hi>
    </xsl:template>

    <xsl:template match="pos">
        <hi lang="xx">
            <xsl:apply-templates/>
        </hi>
    </xsl:template>


    <xsl:template match="sc">
        <hi rend="sc" lang="ceb">
            <xsl:apply-templates/>
        </hi>
    </xsl:template>


    <xsl:template match="bio">
        <hi rend="bold" lang="la-x-bio"><hi>
            <xsl:apply-templates/>
        </hi></hi>
    </xsl:template>


    <xsl:template match="sub">
        <hi rend="sub">
            <xsl:apply-templates/>
        </hi>
    </xsl:template>


    <xsl:template match="itype">
        <hi rend="rm" lang="xx">
            <xsl:apply-templates/>
        </hi>
    </xsl:template>


    <xsl:template match="r">
        <hi rend="rm">
            <xsl:apply-templates/>
        </hi>
    </xsl:template>


    <xsl:template match="tr">
        <xsl:apply-templates/>
    </xsl:template>


    <xsl:template match="note"/>


    <xsl:template match="xr">
        <xsl:apply-templates/>
    </xsl:template>



    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>



</xsl:stylesheet>
