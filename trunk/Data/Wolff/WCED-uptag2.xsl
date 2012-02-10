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
        <xd:short>Stylesheet to make implied structure in Wolff's dictionary explicit.</xd:short>
        <xd:detail>This stylesheet attempts to recognize the structure of Wolff's Cebuano-English dictionary, and apply appropriate tags.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2012, Jeroen Hellingman</xd:copyright>
    </xd:doc>


    <xsl:template match="/">
    
        <!--
            <xsl:processing-instruction name="xml-stylesheet">href="WCED-view.xsl" type="text/xsl"</xsl:processing-instruction>
        -->

        <!-- uptag the main dictionary -->
        <dictionary lang="en-US">
            <xsl:apply-templates/>
            <xsl:text>&lf;&lf;</xsl:text>
        </dictionary>

        <!-- Create list of cross-references in separate document -->
        <xsl:result-document
                href="cross-references.xml"
                method="xml"
                encoding="UTF-8">

            <xrs>
                <xsl:apply-templates mode="xr" select="//xr"/>
            </xrs>
        </xsl:result-document>
    </xsl:template>


    <xsl:template mode="xr" match="xr">
        <xr>
            <xsl:value-of select="."/>
        </xr>
        <xsl:text>&lf;</xsl:text>
    </xsl:template>


    <!-- Eliminate the TEI header, front, back and headings -->
    <xsl:template match="teiHeader"/>
    <xsl:template match="front"/>
    <xsl:template match="back"/>
    <xsl:template match="head"/>


    <!-- Remove various tags -->
    <xsl:template match="TEI.2|text|body|div1">
        <xsl:apply-templates/>
    </xsl:template>


    <!-- Process each entry -->
    <xsl:template match="p">

        <xsl:variable name="entry">
            <xsl:text>&lf;&lf;</xsl:text>
            <entry>
                <xsl:attribute name="id">
                    <xsl:number format="1" level="any" count="p"/>
                </xsl:attribute>
                <xsl:call-template name="split-entry">
                    <xsl:with-param name="nodes" select="*|text()"/>
                </xsl:call-template>
            </entry>
        </xsl:variable>

        <xsl:apply-templates mode="phase2" select="$entry"/>

    </xsl:template>


    <!--== INFER LOGICAL STRUCTURE ==-->

    <xd:doc>
        <xd:short>Split entry into sub-entries.</xd:short>
        <xd:detail>Entries consist of a main part, optionally followed by sub-entries. The headwords
        for entries and subentries are marked with the form element, so we can
        split the entry on these.</xd:detail>
    </xd:doc>

    <xsl:template name="split-entry">
        <xsl:param name="nodes" as="node()*"/>

        <xsl:for-each-group select="$nodes" group-starting-with="form">
            <xsl:choose>
                <!-- First group is the main entry -->
                <xsl:when test="position() = 1">
                    <xsl:choose>
                        <xsl:when test="name(.) = 'form'">
                            <xsl:apply-templates select="@*"/>
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
                    <xsl:text>&lf;</xsl:text>
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


    <xd:doc>
        <xd:short>Split sub-entry into homonyms.</xd:short>
        <xd:detail>Each entry is split, based on the part-of-speech (indicated in the pos element).
        Many entries do not have a pos element. These are either:
        
            <ul>
                <li>cross-references</li>
                <li>phrases</li>
                <li>words not being one of noun, verb, adjective/adverb.</li>
                <li>mistakes in the data.</li>
            </ul>
        </xd:detail>
    </xd:doc>

    <xsl:template name="split-subentry">
        <xsl:param name="nodes" as="node()*"/>

        <xsl:for-each-group select="$nodes" group-starting-with="pos">
            <!-- ignore spurious empty groups (caused by spaces in source text) -->
            <xsl:if test="not(local:is-empty(current-group()))">
                <xsl:text>&lf;</xsl:text>
                <hom>
                    <xsl:choose>
                        <xsl:when test="name(.) = 'pos'">
                            <xsl:attribute name="role">
                                <xsl:value-of select="."/>
                            </xsl:attribute>
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


    <xd:doc>
        <xd:short>Split homonyms into senses.</xd:short>
        <xd:detail><p>Each pos-element, is then split into some numbered senses. Note that
        the numbers are not given when only one sense is present.</p>

        <p>The sense-numbering seems to indicate some further hierarchy by the
        use of letters; however their usage seems not very consistent.</p>

        <p>In a few cases, a sense contains a phrase (formatted as a head-word).</p></xd:detail>
    </xd:doc>

    <xsl:template name="split-role">
        <xsl:param name="nodes" as="node()*"/>

        <xsl:for-each-group select="$nodes" group-starting-with="number">
            <!-- eliminate spurious empty groups (caused by spaces in source text) -->
            <xsl:if test="not(local:is-empty(current-group()))">
                <xsl:text>&lf;</xsl:text>
                <sense>
                    <xsl:attribute name="n">
                        <xsl:choose>
                            <xsl:when test="name(.) = 'number'">
                                <xsl:value-of select="."/>
                            </xsl:when>
                            <xsl:otherwise>0</xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>

                    <xsl:call-template name="split-examples">
                        <xsl:with-param name="nodes" select="current-group()"/>
                    </xsl:call-template>
                </sense>
            </xsl:if>
        </xsl:for-each-group>
    </xsl:template>


    <xd:doc>
        <xd:short>Split examples and sub-senses from sense.</xd:short>
        <xd:detail>Each sense starts with a translation or description of the sense, followed
        by zero or more examples, where the Cebuano is given in italics, and
        the English translation in upright letters.</xd:detail>
    </xd:doc>

    <xsl:template name="split-examples">
        <xsl:param name="nodes" as="node()*"/>

        <xsl:for-each-group select="$nodes" group-starting-with="i | sense">
            <xsl:choose>
                <xsl:when test="position() = 1">
                    <xsl:choose>
                        <xsl:when test="name(.) = 'number'">
                            <xsl:apply-templates select="."/>
                            <trans>
                                <xsl:apply-templates select="current-group() except ."/>
                            </trans>
                        </xsl:when>
                        <xsl:otherwise>
                            <trans><xsl:apply-templates select="current-group()"/></trans>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>

                <!-- We have a hard-coded sub-sense in the source: restart splitting it -->
                <xsl:when test="name(.) = 'sense'">
                    <sense>
                        <xsl:call-template name="split-entry">
                            <xsl:with-param name="nodes" select="./*|./text()"/>
                        </xsl:call-template>
                    </sense>
                    <xsl:apply-templates select="current-group() except ."/>
                </xsl:when>

                <xsl:otherwise>
                    <eg>
                        <xsl:apply-templates select="."/>
                        <trans><xsl:apply-templates select="current-group() except ."/></trans>
                    </eg>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>&lf;</xsl:text>
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
        <form lang="ceb">
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>
        </form>
    </xsl:template>


    <!-- TODO handle actual link on sc element -->
    <xsl:template match="xr">
        <xr lang="ceb" target="#{local:make-id(lower-case(local:as-string(sc)))}">
            <xsl:apply-templates/>
        </xr>
    </xsl:template>


    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <!--== PHASE 2 ==-->

    <xsl:template mode="phase2" match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates mode="phase2" select="@*|node()"/>
        </xsl:copy>
    </xsl:template>


    <!-- split up forms -->
    <xsl:template mode="phase2" match="form">
        <form>
            <xsl:apply-templates mode="splitoncommas" select="@*|node()"/>
        </form>
    </xsl:template>

    <xsl:template mode="splitoncommas" match="*|@*">
        <xsl:copy-of select="."/>
    </xsl:template>

    <xsl:template mode="splitoncommas" match="text()">
        <xsl:analyze-string select="." regex="(, |\*|[/])">
            <xsl:matching-substring>
                <xsl:value-of select="."/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <w id="{local:make-id(.)}">
                    <xsl:value-of select="."/>
                </w>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>


    <!-- remove empty trans -->
    <xsl:template mode="phase2" match="trans[normalize-space(.) = '']"/>


    <!-- lift grammar information from trans -->
    <xsl:template mode="phaseXXX" match="trans">
        <xsl:copy-of select="itype"/>
        <xsl:copy>
            <xsl:apply-templates mode="phase2"/>
        </xsl:copy>
    </xsl:template>


    <!-- eliminate the itype copied in the rule above. -->
    <xsl:template mode="phaseXXX" match="itype[parent::trans]"/>




    <!--== SUPPORT FUNCTIONS ==-->

    <!-- Turn a word into a string usable as id -->
    <xsl:function name="local:make-id" as="xs:string">
        <xsl:param name="word" as="xs:string"/>

        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '�',          'ax')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '�',          'ix')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '�',          'ux')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '�',          'aq')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '�',          'iq')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '�',          'uq')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '&larr;',     'lx')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '&rarr;',     'rx')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '[ ,/]+',     '_')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '&mdash;',    '--')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '^-',         'x-')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '[ ()\[\],]', '')"/></xsl:variable>
        <xsl:variable name="word" as="xs:string"><xsl:value-of select="replace($word, '\*',         'xx')"/></xsl:variable>

        <xsl:value-of select="$word"/>
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
