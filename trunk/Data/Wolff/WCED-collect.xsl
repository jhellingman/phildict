<!DOCTYPE xsl:stylesheet>
<xsl:transform
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">

<xsl:template match="/">
    <dictionary lang="en-US">
        <xsl:apply-templates select="document('structural-A.xml')/dictionary/entry" />
        <xsl:apply-templates select="document('structural-B.xml')/dictionary/entry" />
        <xsl:apply-templates select="document('structural-D.xml')/dictionary/entry" />
        <xsl:apply-templates select="document('structural-G.xml')/dictionary/entry" />
        <xsl:apply-templates select="document('structural-H.xml')/dictionary/entry" />
        <xsl:apply-templates select="document('structural-I.xml')/dictionary/entry" />
        <xsl:apply-templates select="document('structural-K.xml')/dictionary/entry" />
        <xsl:apply-templates select="document('structural-L.xml')/dictionary/entry" />
        <xsl:apply-templates select="document('structural-M.xml')/dictionary/entry" />
        <xsl:apply-templates select="document('structural-N.xml')/dictionary/entry" />
        <xsl:apply-templates select="document('structural-P.xml')/dictionary/entry" />
        <xsl:apply-templates select="document('structural-R.xml')/dictionary/entry" />
        <xsl:apply-templates select="document('structural-S.xml')/dictionary/entry" />
        <xsl:apply-templates select="document('structural-T.xml')/dictionary/entry" />
        <xsl:apply-templates select="document('structural-U.xml')/dictionary/entry" />
        <xsl:apply-templates select="document('structural-W.xml')/dictionary/entry" />
        <xsl:apply-templates select="document('structural-Y.xml')/dictionary/entry" />
        <xsl:apply-templates select="document('structural-addenda.xml')/dictionary/entry" />
    </dictionary>
</xsl:template>

<xsl:template match="node()|@*">
    <xsl:copy>
        <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
</xsl:template>

</xsl:transform>
