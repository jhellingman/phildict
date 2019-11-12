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
    xmlns:f="urn:stylesheet-functions"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    version="2.0"
    exclude-result-prefixes="xs f xd">

    <xsl:include href="WCED-support.xsl"/>

    <xsl:output
        method="xml"
        indent="no"
        encoding="UTF-8"/>

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to make the implied structure in Wolff's dictionary more explicit.</xd:short>
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

        <!--
        <xsl:call-template name="list-cross-references"/>
        <xsl:call-template name="list-roots"/>
        <xsl:call-template name="list-heads"/>
        <xsl:call-template name="list-heads-sql"/> 
        -->

    </xsl:template>

    <!--=========================================================================-->

    <xsl:template name="list-heads">
        <!-- Create list of head words in separate document -->
        <xsl:result-document
                href="output/heads.xml"
                method="xml"
                encoding="UTF-8">
            <heads>
                <xsl:apply-templates mode="heads" select="//form|//formx"/>
            </heads>
        </xsl:result-document>
    </xsl:template>

    <xsl:template mode="heads" match="form|formx">
        <xsl:variable name="heads">
            <xsl:apply-templates mode="heads"/>
        </xsl:variable>
        <xsl:variable name="id" select="ancestor::p/@id"/>
        <!-- remove asterisks and daggers and split on comma or slash -->
        <xsl:for-each select="tokenize(replace($heads, '[*&dagger;]', ''), '[,/][,/ ]*')">
            <head id="{$id}">
                <xsl:value-of select="."/>
            </head>
            <xsl:text>&lf;</xsl:text>
        </xsl:for-each>
    </xsl:template>

    <xsl:template mode="heads" match="sub"/>

    <xsl:template mode="heads" match="pb"/>

    <xsl:template mode="heads" match="abbr">
        <xsl:value-of select="@expan"/>
    </xsl:template>

    <!--=========================================================================-->

    <xsl:template name="list-heads-sql">
        <!-- Create list of head words in separate document -->
        <xsl:result-document
                href="sql/WCED_head.sql"
                method="text"
                encoding="UTF-8">
            <heads>
                <xsl:apply-templates mode="heads-sql" select="//form|//formx"/>
            </heads>
        </xsl:result-document>
    </xsl:template>

    <xsl:template mode="heads-sql" match="form|formx">
        <xsl:variable name="heads">
            <xsl:apply-templates mode="heads-sql"/>
        </xsl:variable>
        <xsl:variable name="id" select="ancestor::p/@id"/>
        <!-- remove asterisks and split on comma or slash -->
        <xsl:for-each select="tokenize(replace($heads, '[*&dagger;]', ''), '[,/][,/ ]*')">
            <xsl:value-of select="f:insertHeadSql($id, .)"/>
        </xsl:for-each>
    </xsl:template>

    <xsl:template mode="heads-sql" match="sub"/>

    <xsl:template mode="heads-sql" match="pb"/>

    <xsl:template mode="heads-sql" match="abbr">
        <xsl:value-of select="@expan"/>
    </xsl:template>

    <xsl:function name="f:insertHeadSql">
        <xsl:param name="entryId"/>
        <xsl:param name="word"/>

        <xsl:variable name="normalizedWord">
            <xsl:value-of select="lower-case(f:strip_diacritics($word))"/>
        </xsl:variable>

        <xsl:text>&lf;</xsl:text>
        <xsl:text>INSERT INTO `wced_head` (entryid, head, normalized_head) VALUES (</xsl:text>
        <xsl:value-of select="$entryId"/>
        <xsl:text>, </xsl:text>
        <xsl:text>&quot;</xsl:text><xsl:value-of select="$word"/><xsl:text>&quot;</xsl:text>
        <xsl:text>, </xsl:text>
        <xsl:text>&quot;</xsl:text><xsl:value-of select="$normalizedWord"/><xsl:text>&quot;</xsl:text>
        <xsl:text>);</xsl:text>
    </xsl:function>


    <!--=========================================================================-->

    <xsl:template name="list-roots">
        <!-- Create list of root-forms in separate document -->
        <xsl:result-document
                href="output/roots.xml"
                method="xml"
                encoding="UTF-8">
            <forms>
                <xsl:apply-templates mode="roots" select="//form|//formx"/>
            </forms>
        </xsl:result-document>
    </xsl:template>

    <xsl:template mode="roots" match="form|formx">
        <xsl:variable name="forms">
            <xsl:apply-templates mode="form"/>
        </xsl:variable>
        <!-- remove asterisks and split on comma, space, or slash -->
        <xsl:for-each select="tokenize(replace($forms, '\*', ''), '[,\s/]+')">
            <form>
                <xsl:value-of select="."/>
            </form>
            <xsl:text>&lf;</xsl:text>
        </xsl:for-each>
    </xsl:template>

    <xsl:template mode="roots" match="sub"/>

    <xsl:template mode="roots" match="abbr">
        <xsl:value-of select="@expan"/>
    </xsl:template>


    <!--=========================================================================-->

    <xsl:template name="list-cross-references">
        <!-- Create list of cross-references in separate document -->
        <xsl:result-document
                href="output/cross-references.xml"
                method="xml"
                encoding="UTF-8">
            <xrs>
                <xsl:apply-templates mode="xr" select="//xr"/>
            </xrs>
        </xsl:result-document>
    </xsl:template>

    <xsl:template mode="xr" match="xr">
        <xsl:copy-of select="."/>
        <xsl:text>&lf;</xsl:text>
    </xsl:template>

    <xsl:template mode="xr" match="pb"/>

    <!--=========================================================================-->

    <!-- Eliminate the TEI header, front, back and headings -->
    <xsl:template match="teiHeader"/>
    <xsl:template match="front"/>
    <xsl:template match="back"/>
    <xsl:template match="head"/>


    <!-- Remove various tags -->
    <xsl:template match="TEI.2|text|body|div1">
        <xsl:apply-templates/>
    </xsl:template>


    <xd:doc>
        <xd:short>Process each entry.</xd:short>
        <xd:detail>Entries are processed in two phases. In the first phase, we infer the overal
        logical structure of the entry, in the second phase, we do some cleanup tasks.</xd:detail>
    </xd:doc>

    <xsl:template match="p">

        <xsl:variable name="entry">
            <xsl:text>&lf;&lf;</xsl:text>
            <entry>
                <xsl:attribute name="page" select="preceding::pb[1]/@n"/>
                <xsl:attribute name="id" select="@id"/>
                <xsl:call-template name="split-entry">
                    <xsl:with-param name="nodes" select="*|text()"/>
                </xsl:call-template>
            </entry>
        </xsl:variable>

        <xsl:apply-templates mode="phase2" select="$entry"/>

    </xsl:template>


    <!--== PHASE 1: INFER LOGICAL STRUCTURE ======================-->

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
            <xsl:if test="not(f:is-empty(current-group()))">
                <xsl:text>&lf;</xsl:text>
                <hom>
                    <xsl:choose>
                        <xsl:when test="name(.) = 'pos'">
                            <xsl:attribute name="role" select="string(.)"/>
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
        use of letters; however their usage is not very consistent.</p>

        <p>In a few cases, a sense contains a phrase (formatted as a head-word). These have to 
        manually handled.</p></xd:detail>
    </xd:doc>

    <xsl:template name="split-role">
        <xsl:param name="nodes" as="node()*"/>

        <xsl:for-each-group select="$nodes" group-starting-with="number">
            <!-- eliminate spurious empty groups (caused by spaces in source text) -->
            <xsl:if test="not(f:is-empty(current-group()))">
                <xsl:text>&lf;</xsl:text>
                <sense>
                    <xsl:attribute name="n" select="if (name(.) = 'number') then string(.) else 0"/>

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

                <!-- We have a hard-coded sub-sense in the source: restart splitting it at a higher level 
                     TODO: code split to work nice on this level -->
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


    <xsl:template match="xr">
        <xsl:apply-templates mode="crossref"/>
    </xsl:template>


    <xsl:template match="*" mode="crossref">
        <xsl:apply-templates select="."/>
    </xsl:template>


    <xsl:template match="sc" mode="crossref">
        <xsl:variable name="target" select="if(abbr/@expan) then abbr/@expan else ."/>
        <xr lang="ceb" target="#{f:make-id(lower-case(f:as-string($target)))}">
            <sc><xsl:apply-templates/></sc>
        </xr>
    </xsl:template>


    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>



    <!--== PHASE 2: CLEAN-UP =====================================-->

    <xd:doc>
        <xd:short>Copy by default.</xd:short>
        <xd:detail>Copy elements in entries by default.</xd:detail>
    </xd:doc>

    <xsl:template mode="phase2" match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates mode="#current" select="@*|node()"/>
        </xsl:copy>
    </xsl:template>


    <xd:doc>
        <xd:short>Add id's to forms, and change formx back to form.</xd:short>
        <xd:detail>Add id's to forms, and change formx back to form. The id is derived from the expanded version of the form, 
        using only the part before the comma (i.e., first cited form).</xd:detail>
    </xd:doc>

    <xsl:template mode="phase2" match="form | formx">
        <xsl:variable name="expanded-form">
            <xsl:apply-templates mode="expanded-form" select="."/>
        </xsl:variable>
        <xsl:variable name="id">
            <xsl:value-of select="f:make-id(if (contains(',', $expanded-form)) then substring-before(',', $expanded-form) else $expanded-form)"/>
        </xsl:variable>
        <form id="{$id}">
            <xsl:if test="not(@lang)">
                <xsl:attribute name="lang" select="'ceb'"/>
            </xsl:if>
            <xsl:apply-templates mode="phase2" select="@*|node()"/>
        </form>
    </xsl:template>

    <xsl:template mode="expanded-form" match="abbr">
        <xsl:value-of select="@expan"/>
    </xsl:template>

    <xsl:template mode="expanded-form" match="*|@*">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>

    <xsl:template mode="expanded-form" match="text()">
        <xsl:copy/>
    </xsl:template>


    <!-- remove empty trans -->
    <xsl:template mode="phase2" match="trans[normalize-space(.) = '']"/>


    <!-- lift various types of information from trans-element. -->
    <xsl:template mode="phase2" match="trans">
        <xsl:choose>
            <xsl:when test="itype | form | formx">
                <xsl:apply-templates select="(*|text())[not(preceding-sibling::itype | preceding-sibling::formx | preceding-sibling::form)]" mode="#current"/>
                <xsl:copy>
                    <xsl:apply-templates select="(*|text())[preceding-sibling::itype | preceding-sibling::formx | preceding-sibling::form]" mode="#current"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates mode="#current"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
