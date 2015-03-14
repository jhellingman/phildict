<!DOCTYPE xsl:stylesheet>
<xsl:transform
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">

<xsl:template match="/">
    <TEI.2 lang="en">
    <teiHeader>
        <xsl:apply-templates select="document('WCED-frontmatter.xml')//teiHeader/*" />
    </teiHeader>
    <text>
        <front id="frontmatter">
            <xsl:apply-templates select="document('WCED-frontmatter.xml')//front/*" />
        </front>
        <body>
            <xsl:apply-templates select="document('typographical/A.xml')//body/*" />
            <xsl:apply-templates select="document('typographical/B.xml')//body/*" />
            <xsl:apply-templates select="document('typographical/D.xml')//body/*" />
            <xsl:apply-templates select="document('typographical/G.xml')//body/*" />
            <xsl:apply-templates select="document('typographical/H.xml')//body/*" />
            <xsl:apply-templates select="document('typographical/I.xml')//body/*" />
            <xsl:apply-templates select="document('typographical/K.xml')//body/*" />
            <xsl:apply-templates select="document('typographical/L.xml')//body/*" />
            <xsl:apply-templates select="document('typographical/M.xml')//body/*" />
            <xsl:apply-templates select="document('typographical/N.xml')//body/*" />
            <xsl:apply-templates select="document('typographical/P.xml')//body/*" />
            <xsl:apply-templates select="document('typographical/R.xml')//body/*" />
            <xsl:apply-templates select="document('typographical/S.xml')//body/*" />
            <xsl:apply-templates select="document('typographical/T.xml')//body/*" />
            <xsl:apply-templates select="document('typographical/U.xml')//body/*" />
            <xsl:apply-templates select="document('typographical/W.xml')//body/*" />
            <xsl:apply-templates select="document('typographical/Y.xml')//body/*" />
        </body>
        <back id="backmatter">
            <xsl:apply-templates select="document('typographical/addenda.xml')//body/*" />
            <xsl:apply-templates select="document('WCED-backmatter.xml')//back/*" />
            <xsl:apply-templates select="document('WCED-frontmatter.xml')//back/*" />
        </back>
    </text>
    </TEI.2>
</xsl:template>

<xsl:template match="node()|@*">
    <xsl:copy>
        <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
</xsl:template>

</xsl:transform>
