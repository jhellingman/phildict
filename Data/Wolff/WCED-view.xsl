<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:local="http://localhost"
    version="2.0"
    exclude-result-prefixes="xs dc">

    <xsl:output 
        method="html" 
        indent="yes"
        encoding="ISO-8859-1"/>

    <xsl:key name="id" match="*[@id]" use="@id"/>

    <xsl:template match="dictionary">
        <html>
            <head>
                <title>Dictionary of Cebuano Visayan</title>

                <style type="text/css">

                    .entry, .hom, .sense, .eg { margin: 5px; }

                    .entry { border-top: solid 1px black; margin-top: 10px; }

                    .entry { margin-left: 10px; border-left: solid 1px black; padding-left: 10px; }

                    .hom { margin-left: 10px; border-left: solid 4px red; padding-left: 10px; }

                    .noun { background-color: #EEFFEE; border-color: green; }
                    .verb { background-color: #EEFFEE; border-color: #99FF99; }
                    .adjective { background-color: #EEFFEE; border-color: #66FF66; }

                    .sense { margin-left: 10px; border-left: solid 0px blue; padding-left: 10px; }

                    .form { font-size: 28px; }

                    .eg { margin-left: 10px; border-left: solid 0px yellow; padding-left: 10px; }

                    .eg { background-color: #FFCCCC; }
                    .eg i {  font-style: italic }

                    .pos { font-size: 20px; }

                    .itype { background-color: yellow; }

                    .note { background-color: orange; }
                    .bio { background-color: #BFFF92; font-style: italic; font-weight: bold; }
                    .tr { background-color: #CCFFFF; }
                    .xr { background-color: #FFFFAA; }
                    .pb { color: red; font-weight: bold; }
                    .gramGrp { background-color: yellow; }
                    .exp { color: grey; }

                    .rm { font-style: normal; font-weight: normal; }

                </style>
            </head>
            <body>
                <xsl:apply-templates/>
            </body>
        </html>
    </xsl:template>

    <xsl:function name="local:get-page-url" as="xs:string">
        <xsl:param name="page" as="xs:string"/>
        <xsl:variable name="pageNumber" select="number($page)"/>

        <xsl:choose>
            <xsl:when test="$page = '537a'">
                <xsl:sequence select="'http://seapdatapapers.library.cornell.edu/cgi/t/text/pageviewer-idx?c=seap&amp;cc=seap&amp;idno=seap085b&amp;node=seap085b%3A11&amp;view=image&amp;seq=7&amp;size=200'"/>
            </xsl:when>
            <xsl:when test="$pageNumber &lt; 538">
                <xsl:sequence select="concat(concat(
                    'http://seapdatapapers.library.cornell.edu/cgi/t/text/pageviewer-idx?c=seap&amp;cc=seap&amp;idno=seap085a&amp;node=seap085a%3A11&amp;view=image&amp;seq=', 
                    $pageNumber + 24),
                    '&amp;size=200')"/>
            </xsl:when>
            <xsl:when test="$pageNumber &gt; 537">
                <xsl:sequence select="concat(concat(
                    'http://seapdatapapers.library.cornell.edu/cgi/t/text/pageviewer-idx?c=seap&amp;cc=seap&amp;idno=seap085b&amp;node=seap085b%3A11&amp;view=image&amp;seq=', 
                    $pageNumber - 530),
                    '&amp;size=200')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text></xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:template match="entry">
        <xsl:if test="parent::dictionary">
            <div class="page-ref"><a href="{local:get-page-url(@page)}"><xsl:value-of select="@page"/></a></div>
        </xsl:if>

        <div class="entry">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="hom[pos='v']">
        <div class="hom verb">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="hom[pos='n']">
        <div class="hom noun">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="hom[pos='a']">
        <div class="hom adjective">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="hom">
        <div class="hom">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="sense">
        <div class="sense">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="form">
        <b class="form">
            <xsl:apply-templates/>
        </b>
    </xsl:template>

    <xsl:template match="w">
        <span id="{@id}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="number">
        <b>
            <xsl:apply-templates/>
        </b>
    </xsl:template>

    <xsl:template match="gramGrp">
        <span class="gramGrp">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="pos">
        <i class="pos">
            <xsl:choose>
                <xsl:when test=".='v'">verb</xsl:when>
                <xsl:when test=".='n'">noun</xsl:when>
                <xsl:when test=".='a'">adjective</xsl:when>
                <xsl:otherwise><xsl:apply-templates/></xsl:otherwise>
            </xsl:choose>
        </i>
    </xsl:template>

    <xsl:template match="pos[parent::xr]">
        <i><xsl:apply-templates/></i>
    </xsl:template>

    <xsl:template match="number[parent::xr]">
        <b><xsl:apply-templates/></b>
    </xsl:template>

    <xsl:template match="number[parent::form]">
        <sub><xsl:apply-templates/></sub>
    </xsl:template>

    <xsl:template match="number[parent::hw]">
        <sub><xsl:apply-templates/></sub>
    </xsl:template>

    <xsl:template match="bio">
        <span class="bio">
            <a>
                <xsl:attribute name="href">http://www.google.com/search?q=<xsl:value-of select="translate(., ' ', '+')"/></xsl:attribute>
                <xsl:apply-templates/>
            </a>
        </span>
    </xsl:template>

    <xsl:template match="note">
        <span class="note">[* <xsl:apply-templates/> *]</span>
    </xsl:template>

    <xsl:template match="tr">
        <span class="tr">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="xr">
        <span>
            <xsl:choose>
                <xsl:when test="key('id', substring(@target, 2))">
                    <a href="{@target}"><xsl:apply-templates/></a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">xr</xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </span>
    </xsl:template>

    <xsl:template match="eg">
        <div class="eg">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="q">
        <i><xsl:apply-templates/></i>
    </xsl:template>

    <xsl:template match="hw">
        <b><xsl:apply-templates/></b>
    </xsl:template>

    <xsl:template match="*">
        <xsl:copy>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="pb">
        <span class="pb">
            <xsl:value-of select="@n"/>
        </span>
    </xsl:template>

    <xsl:template match="itype">
        <span class="itype">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="bx | formx">
        <b>
            <xsl:apply-templates/>
        </b>
    </xsl:template>

    <xsl:template match="r">
        <span class="rm">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="ix">
        <i>
            <xsl:apply-templates/>
        </i>
    </xsl:template>

    <!-- Discard unwanted stuff -->

    <xsl:template match="TEI.2|text|body|trans|div1|sc|corr|head|foreign|back|divGen|sic">
        <xsl:apply-templates/>
    </xsl:template>

</xsl:stylesheet>
