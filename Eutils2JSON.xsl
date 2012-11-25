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

    <xsl:variable name='VERSION' select='"0.1"'/>
    
    <!-- Turn off pretty-printing by setting this to false() -->
    <xsl:param name='pretty' select='true()'/>
    
    <!-- $nl == newline when pretty-printing; otherwise empty string  -->
    <xsl:variable name='nl'>
        <xsl:choose>
            <xsl:when test='$pretty'>
                <xsl:value-of select='"&#10;"'/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select='""'/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <!-- $iu = indent unit (four spaces) when pretty-printing; 
        otherwise empty string -->
    <xsl:variable name='iu'>
        <xsl:choose>
            <xsl:when test='$pretty'>
                <xsl:value-of select='"    "'/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select='""'/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name='iu2' select='concat($iu, $iu)'/>
    <xsl:variable name='iu3' select='concat($iu2, $iu)'/>
    <xsl:variable name='iu4' select='concat($iu3, $iu)'/>
    
    
    <!--================================================
      Utility templates and functions
    -->
    
    <!-- Convert a string to lowercase. -->

    <xsl:variable name="lo" select="'abcdefghijklmnopqrstuvwxyz'"/>
    <xsl:variable name="hi" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>

    <xsl:template name="np:to-lower">
        <xsl:param name="s"/>
        <xsl:value-of select="translate($s, $hi, $lo)"/>
    </xsl:template>

    <f:function name="np:to-lower">
        <xsl:param name="s"/>
        <f:result>
            <xsl:call-template name="np:to-lower">
                <xsl:with-param name="s" select="$s"/>
            </xsl:call-template>
        </f:result>
    </f:function>

    <!--
      Quote a string to prepare it for insertion into a JSON literal value.
      Right now this backslash-escapes double quotes and backslashes.  Probably
      needs to be made more robust.
    -->
    <f:function name="np:q">
        <xsl:param name="_" select="/.."/>
        <xsl:variable name="quot">"</xsl:variable>
        <xsl:variable name="bs">\</xsl:variable>
        <xsl:variable name="result" 
            select="str:replace(
                      str:replace( str:decode-uri($_), $bs, concat($bs, $bs) ), 
                      $quot, concat($bs, $quot) )"/>
        <f:result>
            <xsl:value-of select="$result"/>
        </f:result>
    </f:function>

    <!-- 
      Convenience function to wrap any string in double-quotes.  This 
      reduces the need for a lot of XML character escaping.
    -->
    <f:function name='np:dq'>
        <xsl:param name='s'/>
        <f:result>
            <xsl:value-of select="concat('&quot;', $s, '&quot;')"/>
        </f:result>
    </f:function>

    <!--============================================================
      Generic eutilities templates
    -->

    <!-- Start-of-output boilerplate -->
    <xsl:template name='result-start'>
        <xsl:value-of select='concat(
            "{", $nl, 
            $iu, np:dq("version"), ": ", np:dq($VERSION), ",", $nl,
            $iu, np:dq("resulttype"), ": ",
            np:dq(substring-before(np:to-lower(name(.)), "result")), ",", $nl
        )'/>
    </xsl:template>
    
    <!--
      simple-in-object
      Call this template for elements that have simple content, when
      in the context of a JSON object.  This translates the element
      into a key:value pair, using the element name, converted to lowercase,
      as the key.
    -->
    <xsl:template name='simple-in-object'>
        <xsl:param name='indent' select='""'/>
        <xsl:param name='key' select='np:to-lower(name(.))'/>

        <xsl:value-of select='concat(
            $indent, np:dq($key), ": ", np:dq(normalize-space(np:q(.))) )'/>
        <xsl:if test='position() != last()'>,</xsl:if>
        <xsl:value-of select='$nl'/>
    </xsl:template>
    
    <!-- 
      simple-in-array
      Call this template for elements that have simple content, when
      in the context of a JSON array.  This discards the element name,
      and produces a quoted string from the content.
    -->
    <xsl:template name='simple-in-array'>
        <xsl:param name='indent' select='""'/>
        <xsl:value-of select="$indent"/>
        <xsl:value-of select="np:dq(normalize-space(np:q(.)))"/>
        
        <xsl:if test='position() != last()'>,</xsl:if>
        <xsl:value-of select='$nl'/>
    </xsl:template>
    
    <!--
      array-in-object
      Call this template for array-type elements.  That is, elements
      whose content is a list of child elements with the same name.
      This produces a JSON array.
    -->
    <xsl:template name='array-in-object'>
        <xsl:param name='indent' select='""'/>
        <xsl:value-of select='$indent'/>
        
        <xsl:value-of select="np:dq(np:to-lower(name(.)))"/>
        <xsl:text>: [</xsl:text>
        <xsl:value-of select='$nl'/>
        <xsl:apply-templates select='*'>
            <xsl:with-param name='indent' select='concat($indent, $iu)'/>
        </xsl:apply-templates>
        <xsl:value-of select='$indent'/>
        <xsl:text>]</xsl:text>
        <xsl:if test='position() != last()'>,</xsl:if>
        <xsl:value-of select='$nl'/>
    </xsl:template>

    <!--
        array-in-array
        Array-type elements that occur inside other arrays.
    -->
    <xsl:template name='array-in-array'>
        <xsl:param name='indent' select='""'/>
        <xsl:value-of select='$indent'/>
        
        <xsl:text>[</xsl:text>
        <xsl:value-of select='$nl'/>
        <xsl:apply-templates select='*'>
            <xsl:with-param name='indent' select='concat($indent, $iu)'/>
        </xsl:apply-templates>
        <xsl:value-of select='$indent'/>
        <xsl:text>]</xsl:text>
        <xsl:if test='position() != last()'>,</xsl:if>
        <xsl:value-of select='$nl'/>
    </xsl:template>

    <!-- 
      object-in-object
      For elements that contain heterogenous content.  These are converted
      into JSON objects.  The key, by default, is taken from this element's name,
      but you can override that by passing in the $key param.
    -->
    <xsl:template name='object-in-object'>
        <xsl:param name='indent' select='""'/>
        <xsl:param name='key' select='np:to-lower(name(.))'/>
        
        <xsl:value-of select='$indent'/>
        <xsl:value-of select="np:dq($key)"/>
        <xsl:text>: {</xsl:text>
        <xsl:value-of select='$nl'/>
        <xsl:apply-templates select='*'>
            <xsl:with-param name='indent' select='concat($indent, $iu)'/>
        </xsl:apply-templates>
        <xsl:value-of select='$indent'/>
        <xsl:text>}</xsl:text>
        <xsl:if test='position() != last()'>,</xsl:if>
        <xsl:value-of select='$nl'/>
    </xsl:template>

    <!-- 
        object-in-array
        For elements that contain heterogenous content.  These are converted
        into JSON objects.  
    -->
    <xsl:template name='object-in-array'>
        <xsl:param name='indent' select='""'/>
        <xsl:value-of select='$indent'/>
        
        <xsl:text>{</xsl:text>
        <xsl:value-of select='$nl'/>
        <xsl:apply-templates select='*'>
            <xsl:with-param name='indent' select='concat($indent, $iu)'/>
        </xsl:apply-templates>
        <xsl:value-of select='$indent'/>
        <xsl:text>}</xsl:text>
        <xsl:if test='position() != last()'>,</xsl:if>
        <xsl:value-of select='$nl'/>
    </xsl:template>
    
    
    <xsl:template match='ERROR'>
        <xsl:param name='indent' select='""'/>
        <xsl:call-template name='simple-in-object'>
            <xsl:with-param name='indent' select='$indent'/>
            <xsl:with-param name='key' select='"ERROR"'/>
        </xsl:call-template>        
    </xsl:template>
 
    <!-- Default template for unmatched elements.  Report a problem. -->
    <xsl:template match='*'>
        <xsl:param name='indent' select='""'/>
        <xsl:variable name='msg'
            select='concat("FIXME:  unmatched element ", np:dq(name(.)))'/>
        
        <xsl:value-of select='concat($indent, $msg, $nl)'/>
        <xsl:message>
            <xsl:value-of select='$msg'/>
        </xsl:message>
    </xsl:template>
    
    <!-- Default template for text nodes.  Throw them away if they
        are all blanks.  Report a problem otherwise.    -->
    <xsl:template match="text()" >
        <xsl:if test='normalize-space(.) != ""'>
            <xsl:text>FIXME:  non-blank text node with no template match</xsl:text>
            <xsl:message>FIXME:  non-blank text node with no template match</xsl:message>
        </xsl:if>
    </xsl:template>
    
    
    <!--============================================================
      einfo-specific
    -->
    
    <xsl:template match='eInfoResult'>
        <xsl:call-template name='result-start'/>
        <xsl:apply-templates select='*'>
            <xsl:with-param name='indent' select='$iu'/>
        </xsl:apply-templates>
        <xsl:text>}</xsl:text>
    </xsl:template>
    
    <xsl:template match="DbList">
        <xsl:param name='indent' select='""'/>
        <xsl:call-template name='array-in-object'>
            <xsl:with-param name='indent' select='$indent'/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match='DbList/DbName'>
        <xsl:param name='indent' select='""'/>
        <xsl:call-template name='simple-in-array'>
            <xsl:with-param name='indent' select='$indent'/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="DbInfo">
        <xsl:param name='indent' select='""'/>
        <xsl:call-template name='object-in-object'>
            <xsl:with-param name='indent' select='$indent'/>
        </xsl:call-template>
    </xsl:template>
  
    <xsl:template match='DbInfo/DbName |
                         MenuName |
                         Description |
                         Count |
                         LastUpdate |
                         FullName |
                         TermCount |
                         IsDate |
                         IsNumerical |
                         SingleToken |
                         Hierarchy |
                         IsHidden |
                         Menu |
                         DbTo'>
        <xsl:param name='indent' select='""'/>
        <xsl:call-template name='simple-in-object'>
            <xsl:with-param name='indent' select='$indent'/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match='FieldList |
                         LinkList'>
        <xsl:param name='indent' select='""'/>
        <xsl:call-template name='array-in-object'>
            <xsl:with-param name='indent' select='$indent'/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match='Field |
                         Link'>
        <xsl:param name='indent' select='""'/>
        <xsl:call-template name='object-in-array'>
            <xsl:with-param name='indent' select='$indent'/>
        </xsl:call-template>
    </xsl:template>

    <!--============================================================
        Esummary version 2.0 specific
    -->
    <xsl:template match='eSummaryResult'>
        <xsl:call-template name='result-start'/>
        <xsl:apply-templates select='*'>
            <xsl:with-param name='indent' select='$iu'/>
        </xsl:apply-templates>
        <xsl:text>}</xsl:text>
    </xsl:template>
    
    <xsl:template match='DocumentSummarySet[@status="OK"]'>
        <xsl:param name='indent' select='""'/>
        <xsl:value-of select='$indent'/>

        <xsl:text>"docsums": {</xsl:text>
        <xsl:value-of select='concat($nl, $indent, $iu)'/>
        
        <!-- Output the uids as an array -->
        <xsl:value-of select='concat(np:dq("uids"), ": [", $nl)'/>
        <xsl:apply-templates select='DocumentSummary/@uid'>
            <xsl:with-param name='indent' select='concat($indent, $iu2)'/>
        </xsl:apply-templates>
        <xsl:value-of select='concat($indent, $iu, "],", $nl)'/>
        
        <xsl:apply-templates select='DocumentSummary' >
            <xsl:with-param name='indent' select='concat($indent, $iu)'/>
        </xsl:apply-templates>
        <xsl:value-of select='concat($indent, "}", $nl)'/>
    </xsl:template>
    
    <xsl:template match='DocumentSummary/@uid'>
        <xsl:param name='indent' select='""'/>
        <xsl:call-template name='simple-in-array'>
            <xsl:with-param name='indent' select='$indent'/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match='DocumentSummary'>
        <xsl:param name='indent' select='""'/>
        <xsl:call-template name='object-in-object'>
            <xsl:with-param name='indent' select='$indent'/>
            <xsl:with-param name='key' select='@uid'/>
        </xsl:call-template>
    </xsl:template>

    <!-- simple-in-array -->
    <xsl:template match='string | 
                         flag'>
        <xsl:param name='indent' select='""'/>
        <xsl:call-template name='simple-in-array'>
            <xsl:with-param name='indent' select='$indent'/>
        </xsl:call-template>
    </xsl:template>
    
    <!-- simple-in-object -->
    <xsl:template match='PubDate | 
                         EPubDate | 
                         Source | 
                         LastAuthor | 
                         Title | 
                         SortTitle | 
                         Volume |
                         Issue |
                         Pages |
                         NlmUniqueID |
                         ISSN |
                         ESSN |
                         PubStatus |
                         PmcRefCount |
                         FullJournalName |
                         ELocationID |
                         ViewCount |
                         DocType |
                         BookTitle |
                         Medium |
                         Edition |
                         PublisherLocation |
                         PublisherName |
                         SrcDate |
                         ReportNumber |
                         AvailableFromURL |
                         LocationLabel |
                         DocDate |
                         BookName |
                         Chapter |
                         SortPubDate |
                         SortFirstAuthor |
                         Name |
                         AuthType |
                         ClusterID |
                         RecordStatus |
                         IdType |
                         IdTypeN |
                         Value | 
                         Date |
                         Marker_Name |
                         Org |
                         Chr |
                         Locus |
                         Polymorphic |
                         EPCR_Summary |
                         Gene_ID |
                         SortDate |
                         PmcLiveDate |
                         DocumentSummary/error'>
        <xsl:param name='indent' select='""'/>
        <xsl:call-template name='simple-in-object'>
            <xsl:with-param name="indent" select='$indent'/>
        </xsl:call-template>
    </xsl:template>
    
    <!-- array-in-object -->
    <xsl:template match='Authors | 
                         Lang | 
                         PubType |
                         ArticleIds |
                         History |
                         References |
                         Attributes |
                         SrcContribList |
                         DocContribList |
                         Map_Gene_Summary_List'>
        <xsl:param name='indent' select='""'/>
        <xsl:call-template name='array-in-object'>
            <xsl:with-param name='indent' select='$indent'/>
        </xsl:call-template>
    </xsl:template>

    <!-- object-in-array -->
    <xsl:template match='Author | 
                         ArticleId |
                         PubMedPubDate |
                         Map_Gene_Summary'>
        <xsl:param name='indent' select='""'/>
        <xsl:call-template name='object-in-array'>
            <xsl:with-param name='indent' select='$indent'/>
        </xsl:call-template>
    </xsl:template>

    <!--============================================================
      ESearch 
    -->

    <xsl:template match='eSearchResult'>
        <xsl:call-template name='result-start'/>
        <xsl:apply-templates select='*'>
            <xsl:with-param name='indent' select='$iu'/>
        </xsl:apply-templates>
        <xsl:text>}</xsl:text>
    </xsl:template>

    <!-- simple-in-object -->
    <xsl:template match='RetMax |
                         RetStart |
                         QueryKey |
                         WebEnv |
                         From |
                         To |
                         Term |
                         TermSet/Field |
                         Explode |
                         QueryTranslation'>
        <xsl:param name='indent' select='""'/>
        <xsl:call-template name='simple-in-object'>
            <xsl:with-param name="indent" select='$indent'/>
        </xsl:call-template>
    </xsl:template>

    <!-- simple-in-array -->
    <xsl:template match='Id |
                         OP'>
        <xsl:param name='indent' select='""'/>
        <xsl:call-template name='simple-in-array'>
            <xsl:with-param name='indent' select='$indent'/>
        </xsl:call-template>
    </xsl:template>
    
    <!-- array-in-object -->
    <xsl:template match='IdList |
                         TranslationSet |
                         TranslationStack'>
        <xsl:param name='indent' select='""'/>
        <xsl:call-template name='array-in-object'>
            <xsl:with-param name='indent' select='$indent'/>
        </xsl:call-template>
    </xsl:template>
    
    <!-- object-in-array -->
    <xsl:template match='Translation |
                         TermSet'>
        <xsl:param name='indent' select='""'/>
        <xsl:call-template name='object-in-array'>
            <xsl:with-param name='indent' select='$indent'/>
        </xsl:call-template>
    </xsl:template>
    

</xsl:stylesheet>
