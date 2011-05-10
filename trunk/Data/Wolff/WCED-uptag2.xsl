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
<!ENTITY mdash       "&#x2014;"         >

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


    <!-- Make implied structure in Wolff's dictionary explicit -->

    <xsl:template match="/">
        <xsl:processing-instruction name="xml-stylesheet">href="WCED-view.xsl" type="text/xsl"</xsl:processing-instruction>
        <dictionary lang="en-US">
            <xsl:apply-templates/>
        </dictionary>

        <xsl:result-document 
                href="xrefs.xml"
                method="xml" 
                encoding="UTF-8">

            <xrefs>
                <xsl:apply-templates mode="xref" select="//xref"/>
            </xrefs>
        </xsl:result-document>
    </xsl:template>


    <xsl:template mode="xref" match="xref">
        <xref>
            <xsl:value-of select="."/>
        </xref>
        <xsl:text>
</xsl:text>
    </xsl:template>


    <xsl:template match="teiHeader"/>


    <xsl:template match="entry|p">
        <entry>
            <xsl:call-template name="split-entry">
                <xsl:with-param name="nodes" select="*|text()"/>
            </xsl:call-template>
        </entry>
    </xsl:template>


    <!--

    Entries consist of a main part, followed by sub-entries. The headwords
    for entries and subentries are marked with the form element, so we can
    split the entry on these.

    -->

    <xsl:template name="split-entry">
        <xsl:param name="nodes" as="node()*"/>

        <xsl:for-each-group select="$nodes" group-starting-with="form">
            <xsl:choose>
                <!-- First group is the main entry -->
                <xsl:when test="position() = 1">
                    <xsl:choose>
                        <xsl:when test="name(.) = 'form'">
                            <xsl:apply-templates select="."/>
                            <xsl:call-template name="split-subentry">
                                <xsl:with-param name="nodes" select="current-group() except ."/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="split-subentry">
                                <xsl:with-param name="nodes" select="current-group()"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <!-- Following groups are sub-entries -->
                <xsl:otherwise>
                    <entry>
                        <xsl:apply-templates select="."/>
                        <xsl:call-template name="split-subentry">
                            <xsl:with-param name="nodes" select="current-group() except ."/>
                        </xsl:call-template>
                    </entry>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each-group>
    </xsl:template>


    <!--

    Each entry is split, based on the part-of-speech (indicated in the pos element).
    Many entries do not have a pos element. These are either

    * cross-references
    * phrases
    * words not being one of noun, verb, adjective/adverb.
    * mistakes in the data.

    -->

    <xsl:template name="split-subentry">
        <xsl:param name="nodes" as="node()*"/>

        <xsl:for-each-group select="$nodes" group-starting-with="pos">
            <!-- ignore spurious empty groups (caused by spaces in source text) -->
            <xsl:if test="not(local:is-empty(current-group()))">
                <hom>
                    <xsl:choose>
                        <xsl:when test="name(.) = 'pos'">
                            <xsl:apply-templates select="."/>
                            <xsl:call-template name="split-role">
                                <xsl:with-param name="nodes" select="current-group() except ."/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="split-role">
                                <xsl:with-param name="nodes" select="current-group()"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </hom>
            </xsl:if>
        </xsl:for-each-group>
    </xsl:template>

    <!--

    Each pos-element, is then split into some numbered senses. Note that
    the numbers are not given when only one sense is present.

    The sense-numbering seems to indicate some further hierarchy by the
    use of letters; however their usage seems not very consistent.

    In a few cases, a sense contains a phrase (formatted as a head-word).

    -->

    <xsl:template name="split-role">
        <xsl:param name="nodes" as="node()*"/>

        <xsl:for-each-group select="$nodes" group-starting-with="number">
            <!-- ignore spurious empty groups (caused by spaces in source text) -->
            <xsl:if test="not(local:is-empty(current-group()))">
                <sense>
                    <xsl:call-template name="split-samples">
                        <xsl:with-param name="nodes" select="current-group()"/>
                    </xsl:call-template>
                </sense>
            </xsl:if>
        </xsl:for-each-group>
    </xsl:template>


    <xsl:template name="split-samples">
        <xsl:param name="nodes" as="node()*"/>

        <xsl:for-each-group select="$nodes" group-starting-with="i">
            <xsl:choose>
                <xsl:when test="position() = 1">
                    <xsl:apply-templates select="."/>
                    <trans>
                        <xsl:apply-templates select="current-group() except ."/>
                    </trans>
                </xsl:when>
                <xsl:otherwise>
                    <eg>
                        <xsl:apply-templates select="."/>
                        <trans><xsl:apply-templates select="current-group() except ."/></trans>
                    </eg>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each-group>
    </xsl:template>


    <xsl:template match="number">
        <number>
            <xsl:apply-templates/>
        </number>
    </xsl:template>


    <xsl:template match="i">
        <i lang="ceb">
            <xsl:apply-templates/>
        </i>
    </xsl:template>


    <xsl:template match="form">
        <form lang="ceb" id="{local:make-id(.)}">
            <xsl:apply-templates/>
        </form>
    </xsl:template>


    <xsl:template match="xref">
        <xref lang="ceb" target="#{local:make-id(lower-case(local:as-string(sc)))}">
            <xsl:apply-templates/>
        </xref>
    </xsl:template>


    <xsl:template match="*">
        <xsl:copy>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>


    <!-- Turn a word into a string usable as id -->
    <xsl:function name="local:make-id" as="xs:string">
        <xsl:param name="w0" as="xs:string"/>

        <xsl:variable name="w1" as="xs:string"><xsl:value-of select="replace($w0, 'á', 'ax')"/></xsl:variable>
        <xsl:variable name="w2" as="xs:string"><xsl:value-of select="replace($w1, 'í', 'ix')"/></xsl:variable>
        <xsl:variable name="w3" as="xs:string"><xsl:value-of select="replace($w2, 'ú', 'ux')"/></xsl:variable>
        <xsl:variable name="w4" as="xs:string"><xsl:value-of select="replace($w3, 'à', 'aq')"/></xsl:variable>
        <xsl:variable name="w5" as="xs:string"><xsl:value-of select="replace($w4, 'ì', 'iq')"/></xsl:variable>
        <xsl:variable name="w6" as="xs:string"><xsl:value-of select="replace($w5, 'ù', 'uq')"/></xsl:variable>
        <xsl:variable name="w7" as="xs:string"><xsl:value-of select="replace($w6, '&larr;', 'lx')"/></xsl:variable>
        <xsl:variable name="w8" as="xs:string"><xsl:value-of select="replace($w7, '&rarr;', 'rx')"/></xsl:variable>
        <xsl:variable name="w9" as="xs:string"><xsl:value-of select="replace($w8, '[ ,/]+', '_')"/></xsl:variable>
        <xsl:variable name="w10" as="xs:string"><xsl:value-of select="replace($w9, '&mdash;', '--')"/></xsl:variable>
        <xsl:variable name="w11" as="xs:string"><xsl:value-of select="replace($w10, '^-', 'x-')"/></xsl:variable>
        <xsl:variable name="w12" as="xs:string"><xsl:value-of select="replace($w11, '[ ()\[\],]', '')"/></xsl:variable>
        <xsl:variable name="w13" as="xs:string"><xsl:value-of select="replace($w12, '\*', 'xx')"/></xsl:variable>

        <xsl:value-of select="$w13"/>
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


    <!-- Determine whether a sequence of nodes has no text content -->
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
