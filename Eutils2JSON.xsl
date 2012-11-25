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
    xmlns:c="http://exslt.org/common"
    xmlns:libxslt="http://xmlsoft.org/XSLT/namespace" xmlns:f="http://exslt.org/functions"
    extension-element-prefixes="libxslt np f str">
    <xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>

    <xsl:variable name='VERSION' select='"0.1"'/>
    
    <!-- Turn off pretty-printing by setting this to false() -->
    <xsl:param name='pretty' select='true()'/>
    
    <!-- Parse the ESearch translation stack into a JSON tree structure.  This is
      experimental (just for fun).  -->
    <xsl:param name='parse-translation-stack' select='true()'/>
    
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
        <xsl:param name='force-comma' select='false()'/>
        <xsl:value-of select='$indent'/>
        
        <xsl:text>{</xsl:text>
        <xsl:value-of select='$nl'/>
        <xsl:apply-templates select='*'>
            <xsl:with-param name='indent' select='concat($indent, $iu)'/>
        </xsl:apply-templates>
        <xsl:value-of select='$indent'/>
        <xsl:text>}</xsl:text>
        <xsl:if test='$force-comma or position() != last()'>,</xsl:if>
        <xsl:value-of select='$nl'/>
    </xsl:template>
    
    <!-- 
        simple-obj-in-array
        This is for simple-type XML elements, but we want to convert
        them into mini JSON objects.  For example,
          <PhraseNotFound>fleegle</PhraseNotFound>
        will be converted to
          { "phrasenotfound": "fleegle" }
    -->
    <xsl:template name='simple-obj-in-array'>
        <xsl:param name='indent' select='""'/>
        <xsl:param name='key' select='np:to-lower(name(.))'/>
        <xsl:value-of select='$indent'/>
        
        <xsl:text>{ </xsl:text>
        <xsl:value-of select='concat(
            np:dq($key), ": ", np:dq(normalize-space(np:q(.))) )'/>
        <xsl:text> }</xsl:text>
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
                         ErrorList'>
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
    
    <!-- simple-obj-in-array -->
    <xsl:template match='PhraseNotFound |
                         FieldNotFound'>
        <xsl:param name='indent' select='""'/>
        <xsl:call-template name='simple-obj-in-array'>
            <xsl:with-param name='indent' select='$indent'/>
        </xsl:call-template>
    </xsl:template>
    
    <!-- 
      For the TranslationStack, just for fun, I took on the challenge of converting it
      into a JSON tree structure.  The stack is a sequence of TermSet objects and 
      binary operators, in reverse-polish notation.  It is tricky to convert this into
      a tree structure, using recursion within XSLT.
      
      This is experimental, not thoroughly tested, and optional.  Just set the 
      $parse-translation-stack parameter (at the top) to
      false() to turn this off, in which case it will be treated as a run-of-the-mill
      array.
    -->
    <xsl:template match='TranslationStack'>
        <xsl:param name='indent' select='""'/>
        <xsl:choose>
            <xsl:when test='$parse-translation-stack'>
                <xsl:value-of select='$indent'/>
                <xsl:text>"translationstack": </xsl:text>
                <xsl:value-of select='$nl'/>
                <xsl:call-template name='term-tree'>
                    <xsl:with-param name='indent' select='concat($indent, $iu)'/>
                    <xsl:with-param name='elems' select='*'/>
                    <xsl:with-param name='trailing-comma' select='position() != last()'/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name='array-in-object'>
                    <xsl:with-param name='indent' select='$indent'/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- term-tree is the entry point for the recursion.  It prints out one node of
        the tree.  When the $elems is a single TermSet, it prints it as a JSON object.
        When it is a list, with an operator at the end, it prints it as an array of
        three elements, e.g.,   [ "AND", { ... }, { ... } ]
    -->
    <xsl:template name='term-tree'>
        <xsl:param name='indent' select='""'/>
        <xsl:param name='elems'/>
        <xsl:param name='trailing-comma' select='false()'/>
        
        <xsl:variable name='numelems' select='count($elems)'/>
        <xsl:variable name='lastelem' select='$elems[last()]'/>

        <xsl:choose>
            <!-- If there's only one element, it better be a TermSet.  Render this
              as an object inside an array.  -->
            <xsl:when test='$numelems = 1'>
                <xsl:for-each select='$elems[1]'>
                    <xsl:call-template name='object-in-array'>
                        <xsl:with-param name='indent' select='$indent'/>
                        <xsl:with-param name='force-comma' select='$trailing-comma'/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:when>
            
            <!-- We ignore the "GROUP" operator - not sure what it is for. -->
            <xsl:when test='$lastelem[self::OP] and string($lastelem) = "GROUP"'>
                <xsl:call-template name='term-tree'>
                    <xsl:with-param name='indent' select='$indent'/>
                    <xsl:with-param name='elems' select='$elems[position() &lt; last()]'/>
                    <xsl:with-param name='trailing-comma' select='$trailing-comma'/>
                </xsl:call-template>
            </xsl:when>
            
            <!-- If the last thing on the stack is a binary operator, then put out
                an array. -->
            <xsl:when test='$lastelem[self::OP]'>
                <xsl:value-of select='$indent'/>
                <xsl:value-of select='concat(
                    "[", $nl, $indent, $iu, np:dq($lastelem), ",", $nl
                )'/>
                
                <!-- Count how many elements compose the second of my operands -->
                <xsl:variable name='num-top-elems'>
                    <xsl:call-template name='count-top-elems'>
                        <xsl:with-param name='elems' 
                            select='$elems[position() &lt; last()]'/>
                    </xsl:call-template>
                </xsl:variable>

                <!-- Recurse for the first operand.  -->
                <xsl:call-template name='term-tree'>
                    <xsl:with-param name='indent' select='concat($indent, $iu)'/>
                    <xsl:with-param name='elems'
                        select='$elems[position() &lt; $numelems - $num-top-elems]'/>
                    <xsl:with-param name='trailing-comma' select='true()'/>
                </xsl:call-template>

                <!-- Recurse for the second operand. -->
                <xsl:call-template name='term-tree'>
                    <xsl:with-param name='indent' select='concat($indent, $iu)'/>
                    <xsl:with-param name='elems'
                        select='$elems[position() >= $numelems - $num-top-elems and position() &lt; last()]'/>
                </xsl:call-template>
                <xsl:value-of select='concat($indent, "]")'/>
                <xsl:if test='$trailing-comma'>,</xsl:if>
                <xsl:value-of select='$nl'/>
            </xsl:when>
            <xsl:otherwise>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- This template just counts the number of XML elements that make up the
        branch of the term tree at the top of the stack (counting backwards
        from the end). -->
    <xsl:template name='count-top-elems'>
        <xsl:param name='elems'/>
        <xsl:choose>
            <!-- If the thing on top is a TermSet, then the answer is 1. -->
            <xsl:when test='$elems[last()][self::TermSet]'>1</xsl:when>
            
            <!-- If the top is the "GROUP" OP, then pop it off and recurse.
              Basically, the "GROUP" operator is ignored.  -->
            <xsl:when test='$elems[last()][self::OP][.="GROUP"]'>
                <xsl:variable name='num-top-elems'>
                    <xsl:call-template name='count-top-elems'>
                        <xsl:with-param name='elems'
                            select='$elems[position() &lt; last()]'/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:value-of select='1 + $num-top-elems'/>
            </xsl:when>
            
            <!-- Otherwise the top is a binary OP, such as "OR", "AND", or
                "RANGE".  -->
            <xsl:otherwise>
                <xsl:variable name='num-top-elems'>
                    <xsl:call-template name='count-top-elems'>
                        <xsl:with-param name='elems'
                          select='$elems[position() &lt; last()]'/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name='num-next-elems'>
                    <xsl:call-template name='count-top-elems'>
                        <xsl:with-param name='elems'
                            select='$elems[position() &lt; last() - $num-top-elems]'/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:value-of select='1 + $num-top-elems + $num-next-elems'/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
