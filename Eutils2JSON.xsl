<!--
  XSLT 1.0 stylesheet for conversion of E-Utilities XML to JSON.

  This work is in the public domain and may be reproduced, published or
  otherwise used without the permission of the National Library of Medicine (NLM).

  We request only that the NLM is cited as the source of the work.

  Although all reasonable efforts have been taken to ensure the accuracy and
  reliability of the software and data, the NLM and the U.S. Government  do
  not and cannot warrant the performance or results that may be obtained  by
  using this software or data. The NLM and the U.S. Government disclaim all
  warranties, express or implied, including warranties of performance,
  merchantability or fitness for any particular purpose.
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:np="http://ncbi.gov/portal/XSLT/namespace"
    xmlns:str="http://exslt.org/strings"
    xmlns:libxslt="http://xmlsoft.org/XSLT/namespace" xmlns:f="http://exslt.org/functions"
    extension-element-prefixes="libxslt np f str">
    <xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>

    <xsl:variable name="lo" select="'abcdefghijklmnopqrstuvwxyz'"/>
    <xsl:variable name="hi" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
    <xsl:variable name="spaces"
        select="'                                                                '"/>

    <xsl:template name="np:to-lower">
        <xsl:param name="s"/>
        <xsl:value-of select="translate($s, $hi, $lo)"/>
    </xsl:template>

    <f:function name="np:q">
        <xsl:param name="_" select="/.."/>
        <xsl:variable name="quot">"</xsl:variable>
        <xsl:variable name="bs">\</xsl:variable>
        <xsl:variable name="result" select="str:replace(str:replace(str:decode-uri($_), $bs, concat($bs,$bs)), $quot, concat($bs,$quot))"/>
        <f:result>
            <xsl:value-of select="$result"/>
        </f:result>
    </f:function>

    <f:function name="np:to-lower">
        <xsl:param name="s"/>
        <f:result>
            <xsl:call-template name="np:to-lower">
                <xsl:with-param name="s" select="$s"/>
            </xsl:call-template>
        </f:result>
    </f:function>

    <!-- You must override this stylesheet to produce JSON -->
    <xsl:template name="einfoFormatAll">
        <xsl:text>{ "dblist" : [</xsl:text>
        <xsl:variable name="qq">"</xsl:variable>
        <xsl:for-each select="DbName">
            <xsl:text>"</xsl:text>
            <xsl:value-of select="np:q(.)"/>
            <xsl:text>"</xsl:text>
            <xsl:if test="position() != last()">
                <xsl:text>, </xsl:text>
            </xsl:if>
        </xsl:for-each>
        <xsl:text>] }</xsl:text>
    </xsl:template>

    <xsl:template name="conditional-comma">
        <xsl:param name="newline" select="false()"/>
<!--        <np:debug-output>-->
<!--            <xsl:value-of select="concat('newline=',$newline)"/>-->
<!--        </np:debug-output>-->
        <xsl:if test="position() != last()">
            <xsl:text>, </xsl:text>
            <xsl:if test="$newline != false()">
                <xsl:text>
</xsl:text>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <!-- Downcase and copy immediate properties to JSON -->
    <xsl:template name="copy-properties">
        <xsl:param name="indent" select="number(0)"/>
        <xsl:param name="newline" select="false()"/>

       <xsl:for-each select="*[count(*) = 0]">
            <xsl:value-of select="substring($spaces, 1, $indent)"/>
            <xsl:text>"</xsl:text>
            <xsl:value-of select="np:to-lower(np:q(name(.)))"/>
            <xsl:text>"</xsl:text>
            <xsl:text>:"</xsl:text>
            <xsl:value-of select="np:q(.)"/>
            <xsl:text>"</xsl:text>
            <xsl:call-template name="conditional-comma">
                <xsl:with-param name="newline" select="$newline"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="format-list">
        <xsl:param name="listname"/>
        <xsl:param name="nodes" select="/.."/>
        <xsl:variable name="quot">"</xsl:variable>

            <xsl:text>        </xsl:text>
            <xsl:value-of select="concat($quot,$listname,$quot)"/>
            <xsl:text> : {
</xsl:text>
            <xsl:for-each select="$nodes">
<!--                <xsl:text>           { </xsl:text>
-->                <xsl:text>"</xsl:text>
                <xsl:value-of select="*[name() = 'Name']"/>
                <xsl:text>":{</xsl:text>
                <xsl:call-template name="copy-properties">
                    <xsl:with-param name="indent" select="number(1)"/>
                </xsl:call-template>
                <xsl:text>}</xsl:text>
                <xsl:call-template name="conditional-comma"/>
                <xsl:text>
            </xsl:text>
            </xsl:for-each>
            <xsl:text>}</xsl:text>
    </xsl:template>

    <xsl:template name="einfoFormatSingle">
        <xsl:text>
{
    "dbinfo": {
</xsl:text>
        <!-- Data not in fields or links -->
        <xsl:call-template name="copy-properties">
            <xsl:with-param name="indent" select="number(8)"/>
            <xsl:with-param name="newline" select="true()"/>
        </xsl:call-template>
        <xsl:text>,
</xsl:text>
        <!-- fields -->
        <xsl:call-template name="format-list">
            <xsl:with-param name="listname" select="'fields'"/>
            <xsl:with-param name="nodes" select="FieldList/Field"/>
        </xsl:call-template>
        <xsl:text>,
</xsl:text>
        <!-- links -->
        <xsl:call-template name="format-list">
            <xsl:with-param name="listname" select="'links'"/>
            <xsl:with-param name="nodes" select="LinkList/Link"/>
        </xsl:call-template> } }
    </xsl:template>

    <xsl:template match="/__INTERNAL_xml-set___">
        <xsl:apply-templates select="*"/>
    </xsl:template>

    <xsl:template match="eInfoResult/DbInfo">
        <xsl:call-template name="einfoFormatSingle"/>
    </xsl:template>

    <xsl:template match="eInfoResult/DbList">
        <xsl:call-template name="einfoFormatAll"/>
    </xsl:template>

    <xsl:template match="TranslationSet">
        <xsl:text>    "translationset":[</xsl:text>
        <xsl:apply-templates select="Translation"/>
        <xsl:text>]</xsl:text>
    </xsl:template>

    <xsl:template match="Translation">
        <xsl:text>{"from":"</xsl:text>
        <xsl:value-of select="np:q(From)"/>
        <xsl:text>","to":"</xsl:text>
        <xsl:value-of select="np:q(To)"/>
        <xsl:text>"}</xsl:text>
        <xsl:if test="position() != last()">
            <xsl:text>,
</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template match="TranslationStack">
        <xsl:text>    "translationstack":[</xsl:text>
        <xsl:apply-templates select="TermSet|OP"/>
        <xsl:text>]</xsl:text>
    </xsl:template>

    <xsl:template match="TermSet">
        <xsl:text>{</xsl:text>
        <xsl:text>"op":"</xsl:text>
        <xsl:value-of select="name(.)"/>
        <xsl:text>",</xsl:text>
        <xsl:call-template name="copy-properties">
            <xsl:with-param name="indent" select="number(0)"/>
            <xsl:with-param name="newline" select="false()"/>
        </xsl:call-template>
        <xsl:text>}</xsl:text>
        <xsl:value-of select="substring(',',2*number(position() = last()))"/>
    </xsl:template>

    <xsl:template match="OP">
        <xsl:text>{"op":"</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>"}</xsl:text>
        <xsl:value-of select="substring(',',2*number(position() = last()))"/>
    </xsl:template>


    <xsl:template match="eSearchResult" priority="1">
        <xsl:text>{
</xsl:text>
        <xsl:call-template name="copy-properties">
            <xsl:with-param name="indent">4</xsl:with-param>
            <xsl:with-param name="newline" select="true()"/>
        </xsl:call-template>
        <xsl:text>,
    "ids":[</xsl:text>
        <xsl:for-each select="IdList/Id">
            <xsl:value-of select="concat(., substring(',', 2 * number(position() = last())))"/>
        </xsl:for-each>
        <xsl:text>],</xsl:text>
            <xsl:text>
</xsl:text>

        <xsl:apply-templates select="TranslationSet"/>

        <xsl:text>,
</xsl:text>
        <xsl:apply-templates select="TranslationStack"/>

        <xsl:text>
}
</xsl:text>

    </xsl:template>



    <xsl:template match="eSummaryResult[ERROR]">
        <xsl:text>{ "error":[</xsl:text>
        <xsl:for-each select="ERROR">
            <xsl:text>"</xsl:text>
            <xsl:value-of select="."/>
            <xsl:text>"</xsl:text>
            <xsl:call-template name="conditional-comma"/>
        </xsl:for-each>
        <xsl:text>]}</xsl:text>
    </xsl:template>

    <xsl:template match="eSummaryResult[DocSum]">
        <xsl:text>{"docsums":[</xsl:text>
        <xsl:apply-templates select="DocSum"/>
        <xsl:text>]
}</xsl:text>
    </xsl:template>

    <xsl:template match="DocSum">
        <xsl:text>
{"id":</xsl:text>
        <xsl:value-of select="Id"/>
        <xsl:text>,
</xsl:text>

        <xsl:apply-templates select="Item"/>
<xsl:text>}</xsl:text>
        <xsl:call-template name="conditional-comma"/>
    </xsl:template>

    <xsl:template match="Item[@Type='Structure']">
        <xsl:text>{</xsl:text>
        <xsl:apply-templates select="Item"/>
        <xsl:text>}</xsl:text>
    </xsl:template>

    <xsl:template match="Item">
        <xsl:text>    "</xsl:text>
        <xsl:value-of select="np:to-lower(@Name)"/>
        <xsl:text>":</xsl:text>
        <xsl:choose>

            <xsl:when test="(@Type = 'String') or (@Type = 'Date')">
                <xsl:text>"</xsl:text>
                <xsl:value-of select="np:q(.)"/>
                <xsl:text>"</xsl:text>
            </xsl:when>

            <xsl:when test="@Type = 'Integer'">
                <xsl:value-of select="."/>
            </xsl:when>

            <xsl:when test="@Type = 'List'">
                <xsl:text>[
</xsl:text>
                <xsl:for-each select="Item">
                    <xsl:if test="not(@Type = 'Structure')">
                        <xsl:text>{</xsl:text>
                    </xsl:if>
                    <xsl:apply-templates select="."/>
                    <xsl:if test="not(@Type = 'Structure')">
                        <xsl:text>}</xsl:text>
                    </xsl:if>                    <xsl:call-template name="conditional-comma"/>
                </xsl:for-each>
                <xsl:text>    ]</xsl:text>
            </xsl:when>
        </xsl:choose>
        <xsl:call-template name="conditional-comma"/>
        <xsl:text>
</xsl:text>
    </xsl:template>

    <!-- Execute no builtin rules -->
   <!-- <xsl:template match="*" priority="-5">
        <xsl:comment>SKIP: <xsl:value-of select="name()"/></xsl:comment>
    </xsl:template>-->

</xsl:stylesheet>
