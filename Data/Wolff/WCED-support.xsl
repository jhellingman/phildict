<?xml version="1.0" encoding="ISO-8859-1"?>
<!DOCTYPE xsl:stylesheet [

<!ENTITY cr          "&#x0D;"           >
<!ENTITY lf          "&#x0A;"           >
<!ENTITY larr        "&#x2190;"         >
<!ENTITY rarr        "&#x2192;"         >
<!ENTITY glots       "&#x0294;"         >

<!ENTITY amacrgra    "&#x0101;&#x0300;" >
<!ENTITY imacrgra    "&#x012B;&#x0300;" >
<!ENTITY umacrgra    "&#x016B;&#x0300;" >

<!ENTITY amacracu    "&#x0101;&#x0301;" >
<!ENTITY imacracu    "&#x012B;&#x0301;" >
<!ENTITY umacracu    "&#x016B;&#x0301;" >

<!ENTITY amacrcir    "&#x0101;&#x0302;" >
<!ENTITY imacrcir    "&#x012B;&#x0302;" >
<!ENTITY umacrcir    "&#x016B;&#x0302;" >

<!ENTITY Acaron      "&#x01CD;"         >
<!ENTITY acaron      "&#x01CE;"         >
<!ENTITY Icaron      "&#x01CF;"         >
<!ENTITY icaron      "&#x01D0;"         >
<!ENTITY Ucaron      "&#x01D3;"         >
<!ENTITY ucaron      "&#x01D4;"         >

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
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, 'à',          'aq')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, 'â',          'a3')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '&acaron;',   'a4')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '&amacracu;', 'a5')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '&amacrgra;', 'a6')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '&amacrcir;', 'a7')"/></xsl:variable>

        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, 'í',          'ix')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, 'ì',          'iq')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, 'î',          'i3')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '&icaron;',   'i4')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '&imacracu;', 'i5')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '&imacrgra;', 'i6')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '&imacrcir;', 'i7')"/></xsl:variable>

        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, 'ú',          'ux')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, 'ù',          'uq')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, 'û',          'u3')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '&ucaron;',   'u4')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '&umacracu;', 'u5')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '&umacrgra;', 'u6')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '&umacrcir;', 'u7')"/></xsl:variable>

        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '&larr;',     'lx')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '&rarr;',     'rx')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '[ ,/]+',     '_')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '&mdash;',    '--')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '^-',         'x-')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '[ ()\[\],]', '')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '\*',         'xx')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '&dagger;',   'qq')"/></xsl:variable>

        <!-- Ignore subscript one, so non-subscripted cross-references work -->
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '1',          '')"/></xsl:variable>

        <xsl:value-of select="$word"/>
    </xsl:function>

    <xsl:function name="local:make-sortkey" as="xs:string">
        <xsl:param name="word" as="xs:string"/>

        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, 'a',          'a0')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, 'á',          'a1')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, 'à',          'a2')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, 'â',          'a3')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '&acaron;',   'a4')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '&amacracu;', 'a5')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '&amacrgra;', 'a6')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '&amacrcir;', 'a7')"/></xsl:variable>

        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, 'i',          'i0')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, 'í',          'i1')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, 'ì',          'i2')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, 'î',          'i3')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '&icaron;',   'i4')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '&imacracu;', 'i5')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '&imacrgra;', 'i6')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '&imacrcir;', 'i7')"/></xsl:variable>

        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, 'u',          'u0')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, 'ú',          'u1')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, 'ù',          'u2')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, 'û',          'u3')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '&ucaron;',   'u4')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '&umacracu;', 'u5')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '&umacrgra;', 'u6')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '&umacrcir;', 'u7')"/></xsl:variable>

        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '&larr;',     '')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '&rarr;',     '')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '[ ,/]+',     '')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '&mdash;',    '')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '^-',         '')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '[ ()\[\],]', '')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '\*',         '')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '&dagger;',   '')"/></xsl:variable>

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
