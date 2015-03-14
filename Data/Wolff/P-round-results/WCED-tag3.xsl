<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    version="2.0"
    exclude-result-prefixes="xs dc">

    <xsl:output 
        method="xml" 
        indent="yes"
        encoding="UTF-8"/>


    <xsl:template match="entryXXX">
        <xsl:for-each-group select="*" group-starting-with="form">
            <sub>
                <xsl:for-each-group select="current-group()" group-starting-with="pos">
                    <role>
                        <xsl:for-each-group select="current-group()" group-starting-with="number">
                            <sense>
                                <xsl:apply-templates/>
                            </sense>
                        </xsl:for-each-group>
                    </role>
                </xsl:for-each-group>
            </sub>
        </xsl:for-each-group>
    </xsl:template>


    <xsl:template match="entry">
        <entry>
            <xsl:call-template name="split-form"/>
        </entry>
    </xsl:template>

    <xsl:template name="split-form">
        <xsl:choose>
            <xsl:when test="form">
                <xsl:for-each-group select="node()" group-starting-with="form">
                    <sub>
                        <xsl:apply-templates select="current-group()"/>
                    </sub>
                </xsl:for-each-group>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template name="split-pos">
        <xsl:choose>
            <xsl:when test="pos">
                <xsl:for-each-group select="node()" group-starting-with="pos">
                    <role>
                        <xsl:apply-templates select="current-group()"/>
                    </role>
                </xsl:for-each-group>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>



    <xsl:template match="*">
        <xsl:copy>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>


</xsl:stylesheet>
