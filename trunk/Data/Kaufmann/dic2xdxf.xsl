<xsl:transform
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0"
>

    <xsl:output
        method="xml"
        encoding="UTF-8"/>

    <xsl:strip-space elements="*"/>


    <xsl:template match="dictionary">
        <xdxf lang_from="ENG" lang_to="HIL">
            <full_name lang_user="ENG">English-Hiligaynon Dictionary</full_name>
            <description>Derived from Kaufmann's 1934 English-Hiligaynon Dictionary.</description>

            <xsl:apply-templates/>
        </xdxf>
    </xsl:template>


    <xsl:template match="entry">
        <ar>
            <xsl:apply-templates/>
        </ar>
    </xsl:template>


    <xsl:template match="hw">
            <k>
                <xsl:apply-templates/>
            </k>
    </xsl:template>


</xsl:transform>
