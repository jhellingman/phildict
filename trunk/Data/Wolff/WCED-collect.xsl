<!DOCTYPE xsl:stylesheet>
<xsl:transform
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">

<xsl:template match="/">
    <dictionary lang="en-US">
        <xsl:apply-templates select="document('structural-A.xml')//entry" />
        <xsl:apply-templates select="document('structural-B.xml')//entry" />
        <xsl:apply-templates select="document('structural-D.xml')//entry" />
        <xsl:apply-templates select="document('structural-G.xml')//entry" />
        <xsl:apply-templates select="document('structural-H.xml')//entry" />
        <xsl:apply-templates select="document('structural-I.xml')//entry" />
        <xsl:apply-templates select="document('structural-K.xml')//entry" />
        <xsl:apply-templates select="document('structural-L.xml')//entry" />
        <xsl:apply-templates select="document('structural-M.xml')//entry" />
        <xsl:apply-templates select="document('structural-N.xml')//entry" />
        <xsl:apply-templates select="document('structural-P.xml')//entry" />
        <xsl:apply-templates select="document('structural-R.xml')//entry" />
        <xsl:apply-templates select="document('structural-S.xml')//entry" />
        <xsl:apply-templates select="document('structural-T.xml')//entry" />
        <xsl:apply-templates select="document('structural-U.xml')//entry" />
        <xsl:apply-templates select="document('structural-W.xml')//entry" />
        <xsl:apply-templates select="document('structural-Y.xml')//entry" />
        <xsl:apply-templates select="document('structural-addenda.xml')//entry" />
    </dictionary>
</xsl:template>

<xsl:template match="node()|@*">
    <xsl:copy>
        <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
</xsl:template>

</xsl:transform>
