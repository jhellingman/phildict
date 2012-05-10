<?xml version="1.0" encoding="ISO-8859-1"?>
<!DOCTYPE xsl:stylesheet [

<!ENTITY cr          "&#x0D;"           >
<!ENTITY lf          "&#x0A;"           >
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
<!ENTITY mdash       "&#x2014;"         >
<!ENTITY dagger      "&#x2020;"         >

]>

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:local="http://localhost"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    version="2.0"
    exclude-result-prefixes="xs local xd">

    <xsl:output
        method="xml"
        indent="no"
        encoding="UTF-8"/>


    <xd:doc type="stylesheet">
        <xd:short>Support functions used in various stylesheets.</xd:short>
        <xd:detail>This stylesheet contains functions used in various stylesheets.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2012, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <!--== SUPPORT FUNCTIONS ==-->

    <!-- Turn a word into a string usable as id -->
    <xsl:function name="local:make-id" as="xs:string">
        <xsl:param name="word" as="xs:string"/>

        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, 'á',          'ax')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, 'í',          'ix')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, 'ú',          'ux')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, 'à',          'aq')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, 'ì',          'iq')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, 'ù',          'uq')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '&larr;',     'lx')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '&rarr;',     'rx')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '[ ,/]+',     '_')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '&mdash;',    '--')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '^-',         'x-')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '[ ()\[\],]', '')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '\*',         'xx')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '&dagger;',   'qq')"/></xsl:variable>

        <xsl:value-of select="$word"/>
    </xsl:function>


    <xsl:function name="local:strip_diacritics" as="xs:string">
        <xsl:param name="string" as="xs:string"/>
        <xsl:value-of select="replace(normalize-unicode($string, 'NFD'), '\p{M}', '')"/>
    </xsl:function>


    <!-- Flatten a sequence of nodes to a string -->
    <xsl:function name="local:as-string" as="xs:string">
        <xsl:param name="sequence"/>

        <xsl:variable name="string">
            <xsl:for-each select="$sequence">
                <xsl:value-of select="."/>
            </xsl:for-each>
        </xsl:variable>

        <xsl:value-of select="$string"/>
    </xsl:function>


    <!-- Determine whether a sequence of nodes has no text content -->
    <xsl:function name="local:is-empty" as="xs:boolean">
        <xsl:param name="sequence" as="node()*"/>

        <xsl:variable name="string">
            <xsl:for-each select="$sequence">
                <xsl:value-of select="."/>
            </xsl:for-each>
        </xsl:variable>

        <xsl:value-of select="normalize-space($string) = ''"/>
    </xsl:function>


    <!-- Remove initial empty nodes from a sequence -->
    <xsl:function name="local:remove-initial-empty" as="node()*">
        <xsl:param name="sequence" as="node()*"/>

        <xsl:variable name="sequence">
            <xsl:for-each select="$sequence">
                <xsl:if test="normalize-space(.) != ''">
                    <xsl:sequence select="."/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>

        <xsl:value-of select="$sequence"/>
    </xsl:function>

</xsl:stylesheet>
