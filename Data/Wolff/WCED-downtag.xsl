<?xml version="1.0" encoding="ISO-8859-1"?>
<!DOCTYPE xsl:stylesheet [

<!ENTITY larr        "&#x2190;"         >
<!ENTITY rarr        "&#x2192;"         >
<!ENTITY glots       "&#x0294;"         >
<!ENTITY amacracu    "&#x0101;&#x0301;" >
<!ENTITY imacracu    "&#x012B;&#x0301;" >
<!ENTITY umacracu    "&#x016B;&#x0301;" >
<!ENTITY Acaron      "&#x01CD;"         >
<!ENTITY acaron      "&#x01CE;"         >
<!ENTITY Icaron      "&#x01CF;"         >
<!ENTITY icaron      "&#x01D0;"         >
<!ENTITY Ucaron      "&#x01D3;"         >
<!ENTITY ucaron      "&#x01D4;"         >
<!ENTITY schwa       "&#x0259;"         >
<!ENTITY mdash       "&#x2014;"         >

]>

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:f="urn:stylesheet-functions"
    version="2.0"
    exclude-result-prefixes="xs f">

    <xsl:output
        method="xml"
        indent="no"
        encoding="UTF-8"/>

    <xsl:include href="WCED-support.xsl"/>

    <xsl:template match="form|formx|b|bx">
        <hi rend="bold" lang="ceb">
            <xsl:apply-templates/>
        </hi>
    </xsl:template>


    <xsl:template match="p/form[1]">
        <xsl:variable name="id" select="if (contains(., ',')) then substring-before(., ',') else ."/>

        <hi rend="bold" lang="ceb" id="{f:strip_diacritics(f:make-id(lower-case(f:as-string($id))))}">
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


    <xsl:template match="tr | sense">
        <xsl:apply-templates/>
    </xsl:template>


    <xsl:template match="note"/>


    <xsl:template match="xr">
        <xsl:apply-templates/>
    </xsl:template>


    <xsl:template match="sc">
        <hi rend="sc" lang="ceb">
            <ref target="{f:make-id(lower-case(f:as-string(.)))}">
                <xsl:apply-templates/>
            </ref>
        </hi>
    </xsl:template>


    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>


    <!-- Checks -->

    <xsl:template match="p[ancestor::p]">
        <xsl:message terminate="no">ERROR: Paragraph inside paragraph [<xsl:value-of select="."/>]</xsl:message>
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="xr[ancestor::xr]">
        <xsl:message terminate="no">ERROR: Cross-reference inside cross-reference [<xsl:value-of select="."/>]</xsl:message>
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="form[ancestor::i]">
        <xsl:message terminate="no">ERROR: form inside example [<xsl:value-of select="."/>]</xsl:message>
        <xsl:apply-templates/>
    </xsl:template>


</xsl:stylesheet>
