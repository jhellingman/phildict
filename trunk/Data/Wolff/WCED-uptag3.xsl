<?xml version="1.0" encoding="ISO-8859-1"?>
<!DOCTYPE xsl:stylesheet [

<!ENTITY larr        "&#x2190;"    >
<!ENTITY rarr        "&#x2192;"    >
<!ENTITY glots       "&#x0294;"    >
<!ENTITY amacracu    "a"           >
<!ENTITY imacracu    "i"           >
<!ENTITY umacracu    "u"           >
<!ENTITY Acaron      "&#x01CD;"         >
<!ENTITY acaron      "&#x01CE;"         >
<!ENTITY Icaron      "&#x01CF;"         >
<!ENTITY icaron      "&#x01D0;"         >
<!ENTITY Ucaron      "&#x01D3;"         >
<!ENTITY ucaron      "&#x01D4;"         >
<!ENTITY schwa       "e"           >

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


    <!-- Make implied structure in Wolff's dictionary explicit: Step 3 -->


    <!-- put number of sense in attribute -->
    <xsl:template match="sense">
        <xsl:copy>
            <xsl:attribute name="n">
                <xsl:choose>
                    <xsl:when test="number">
                        <xsl:value-of select="number"/>
                    </xsl:when>
                    <xsl:otherwise>1</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>


    <!-- put role of homonym in attribute -->
    <xsl:template match="hom">
        <xsl:copy>
            <xsl:if test="pos">
                <xsl:attribute name="role">
                    <xsl:value-of select="pos"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>


    <!-- lift grammar information from trans -->
    <xsl:template match="sense/trans[itype]">
        <itype><xsl:value-of select="itype"/></itype>
        <xsl:copy>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <!-- eliminate the itype copied in the rule above. -->
    <xsl:template match="itype[parent::trans]"/>

    <xsl:template match="XXXnumber"/>

    <xsl:template match="XXXpos"/>



    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>


</xsl:stylesheet>
