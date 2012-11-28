<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0"
                xmlns:np="http://ncbi.gov/portal/XSLT/namespace"
                xmlns:str="http://exslt.org/strings"
                xmlns:f="http://exslt.org/functions"
                extension-element-prefixes="np str f">
  
  <xsl:variable name='VERSION' select='"0.1"'/>
  
  <!-- Turn off pretty-printing by setting this to false() -->
  <xsl:param name='pretty' select='true()'/>
  
  <!-- Parse the ESearch translation stack into a JSON tree structure.  This is
    experimental.  -->
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
    simple
    Delegates either to simple-in-object or simple-in-array.
  -->
  <xsl:template name='simple'>
    <xsl:param name='indent' select='""'/>
    <xsl:param name='context' select='"unknown"'/>
    <xsl:param name='key' select='""'/>
    
    <xsl:message>
      <xsl:text>In simple template, key is '</xsl:text>
      <xsl:value-of select='$key'/>
      <xsl:text>'</xsl:text>
    </xsl:message>
    <xsl:choose>
      <xsl:when test='$context = "object" and $key = ""'>
        <xsl:call-template name='simple-in-object'>
          <xsl:with-param name='indent' select='$indent'/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test='$context = "object" and $key != ""'>
        <xsl:call-template name='simple-in-object'>
          <xsl:with-param name='indent' select='$indent'/>
          <xsl:with-param name='key' select='$key'/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test='$context = "array"'>
        <xsl:call-template name="simple-in-array">
          <xsl:with-param name='indent' select='$indent'/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>
          <xsl:text>Error:  context is not defined for element </xsl:text>
          <xsl:value-of select='name(.)'/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!--
    array 
    Delegates either to array-in-object or array-in-array.
  -->
  <xsl:template name='array'>
    <xsl:param name='indent' select='""'/>
    <xsl:param name='context' select='"unknown"'/>
    <xsl:param name='key' select='""'/>
    
    <xsl:choose>
      <xsl:when test='$context = "object" and $key = ""'>
        <xsl:call-template name='array-in-object'>
          <xsl:with-param name='indent' select='$indent'/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test='$context = "object" and $key != ""'>
        <xsl:call-template name='array-in-object'>
          <xsl:with-param name='indent' select='$indent'/>
          <xsl:with-param name='key' select='$key'/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test='$context = "array"'>
        <xsl:call-template name="array-in-array">
          <xsl:with-param name='indent' select='$indent'/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>
          <xsl:text>Error:  context is not defined for element </xsl:text>
          <xsl:value-of select='name(.)'/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!--
    object 
    Delegates either to object-in-object or object-in-array.
  -->
  <xsl:template name='object'>
    <xsl:param name='indent' select='""'/>
    <xsl:param name='context' select='"unknown"'/>
    <xsl:param name='key' select='""'/>
    
    <xsl:choose>
      <xsl:when test='$context = "object" and $key = ""'>
        <xsl:call-template name='object-in-object'>
          <xsl:with-param name='indent' select='$indent'/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test='$context = "object" and $key != ""'>
        <xsl:call-template name='object-in-object'>
          <xsl:with-param name='indent' select='$indent'/>
          <xsl:with-param name='key' select='$key'/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test='$context = "array"'>
        <xsl:call-template name="object-in-array">
          <xsl:with-param name='indent' select='$indent'/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>
          <xsl:text>Error:  context is not defined for element </xsl:text>
          <xsl:value-of select='name(.)'/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
  <!--
    simple-in-object
    For text nodes, attributes, or elements that have simple 
    content, when in the context of a JSON object.  
    This translates the node into a key:value pair.  If it's a text node, then, by 
    default, the key will be "value".  If it's an attribute or element node, then, 
    by default, the key will be the name converted to lowercase (it's up to you
    to make sure they are unique within the object).
    
    FIXME:  I don't think we always want to normalize-space on the content.
  -->
  <xsl:template name='simple-in-object'>
    <xsl:param name='indent' select='""'/>
    <xsl:param name='key'>
      <xsl:choose>
        <xsl:when test='self::text()'>
          <xsl:text>value</xsl:text>
        </xsl:when>
        <xsl:otherwise>  <!-- This is an attribute or element node -->
          <xsl:value-of select='np:to-lower(name(.))'/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    
    <xsl:value-of select='concat(
      $indent, np:dq($key), ": ", np:dq(normalize-space(np:q(.))) )'/>
    <xsl:if test='position() != last()'>,</xsl:if>
    <xsl:value-of select='$nl'/>
  </xsl:template>
  
  <!-- 
    simple-in-array
    For text nodes, attributes, or elements that have simple content, when
    in the context of a JSON array.  This discards the attribute or element name,
    and produces a quoted string from the content.
    
    FIXME:  I don't think we always want to normalize-space on the content.
  -->
  <xsl:template name='simple-in-array'>
    <xsl:param name='indent' select='""'/>
    
    <xsl:value-of select="concat( $indent, np:dq(normalize-space(np:q(.))) )"/>
    <xsl:if test='position() != last()'>,</xsl:if>
    <xsl:value-of select='$nl'/>
  </xsl:template>
  
  <!--
    array-in-object
    Call this template for array-type elements.  That is, usually, elements
    whose content is a list of child elements with the same name.
    By default, the key will be the name converted to lowercase.
    This produces a JSON array.  The "kids" are the set of child elements only,
    so attributes and text node children are discarded.
  -->
  <xsl:template name='array-in-object'>
    <xsl:param name='indent' select='""'/>
    <xsl:param name='key' select='np:to-lower(name(.))'/>
      
    <xsl:value-of select='concat( $indent, np:dq($key), ": [", $nl )'/>
    <xsl:apply-templates select='*'>
      <xsl:with-param name='indent' select='concat($indent, $iu)'/>
      <xsl:with-param name='context' select='"array"'/>
    </xsl:apply-templates>
    <xsl:value-of select='concat($indent, "]")'/>
    <xsl:if test='position() != last()'>,</xsl:if>
    <xsl:value-of select='$nl'/>
  </xsl:template>
  
  <!--
    array-in-array
    Array-type elements that occur inside other arrays.
  -->
  <xsl:template name='array-in-array'>
    <xsl:param name='indent' select='""'/>
    <xsl:param name='key' select='np:to-lower(name(.))'/>
      
    <xsl:value-of select='concat( $indent, "[", $nl )'/>
    <xsl:apply-templates select='*'>
      <xsl:with-param name='indent' select='concat($indent, $iu)'/>
      <xsl:with-param name='context' select='"array"'/>
    </xsl:apply-templates>
    <xsl:value-of select='concat($indent, "]")'/>
    <xsl:if test='position() != last()'>,</xsl:if>
    <xsl:value-of select='$nl'/>
  </xsl:template>
  
  <!-- 
    object-in-object
    For elements that have attributes and/or heterogenous content.  These are 
    converted into JSON objects.  
    The key, by default, is taken from this element's name, converted to lowercase.
    By default, this recurses by calling apply-templates on all attributes and
    element children.  So text-node children are discarded.  You can override that
    by passing the $kids param.
  -->
  <xsl:template name='object-in-object'>
    <xsl:param name='indent' select='""'/>
    <xsl:param name='key' select='np:to-lower(name(.))'/>
    <xsl:param name='kids' select='@*|*'/>
    <xsl:param name='force-comma' select='false()'/>
    
    <xsl:value-of select='concat( $indent, np:dq($key), ": {", $nl )'/>
    <xsl:apply-templates select='$kids'>
      <xsl:with-param name='indent' select='concat($indent, $iu)'/>
      <xsl:with-param name='context' select='"object"'/>
    </xsl:apply-templates>
    <xsl:value-of select='concat($indent, "}")'/>
    <xsl:if test='$force-comma or position() != last()'>,</xsl:if>
    <xsl:value-of select='$nl'/>
  </xsl:template>

  <!-- 
    object-in-array
    For elements that contain heterogenous content.  These are converted
    into JSON objects.  
  -->
  <xsl:template name='object-in-array'>
    <xsl:param name='indent' select='""'/>
    <xsl:param name='kids' select='@*|*'/>
    <xsl:param name='force-comma' select='false()'/>
    
    <xsl:value-of select='concat($indent, "{", $nl )'/>
    <xsl:apply-templates select='$kids'>
      <xsl:with-param name='indent' select='concat($indent, $iu)'/>
      <xsl:with-param name='context' select='"object"'/>
    </xsl:apply-templates>
    <xsl:value-of select='concat($indent, "}")'/>
    <xsl:if test='$force-comma or position() != last()'>,</xsl:if>
    <xsl:value-of select='$nl'/>
  </xsl:template>
  
  <!-- 
    simple-obj-in-array
    This is for simple-type XML attributes or elements, but we want to convert
    them into mini JSON objects.  For example,
    <PhraseNotFound>fleegle</PhraseNotFound>
    will be converted to
    { "phrasenotfound": "fleegle" }
  -->
  <xsl:template name='simple-obj-in-array'>
    <xsl:param name='indent' select='""'/>
    <xsl:param name='key' select='np:to-lower(name(.))'/>

    <xsl:value-of select='concat( 
      $indent, "{ ", np:dq($key), ": ", np:dq(normalize-space(np:q(.))), "}" 
    )'/>
    <xsl:if test='position() != last()'>,</xsl:if>
    <xsl:value-of select='$nl'/>
  </xsl:template>
  
  <!-- 
    Default template for an element or attribute. 
    Reports a problem.
  -->
  <xsl:template match='@*|*'>
    <xsl:param name='indent' select='""'/>
    <xsl:param name='context' select='"object"'/>
    
    <xsl:message>
      <xsl:text>FIXME:  No template defined for </xsl:text>
      <xsl:choose>
        <xsl:when test='self::*'>
          <xsl:text>element </xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>attribute </xsl:text>
          <xsl:value-of select='concat(name(..), "/@")'/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:value-of select='name(.)'/>
    </xsl:message>
    
    <xsl:choose>
      <xsl:when test='$context = "array"'>
        <xsl:call-template name='simple-in-array'>
          <xsl:with-param name='indent' select='$indent'/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name='simple-in-object'>
          <xsl:with-param name='indent' select='$indent'/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Default template for text nodes.  Throw them away if they
    are all blanks.  Report a problem otherwise.    -->
  <xsl:template match="text()" >
    <xsl:param name='indent' select='""'/>
    <xsl:param name='context' select='"object"'/>
    
    <xsl:if test='normalize-space(.) != ""'>
      <xsl:message>
        <xsl:text>FIXME:  non-blank text node with no template match.  Parent element: </xsl:text>
        <xsl:value-of select='name(..)'/>
      </xsl:message>
      <xsl:choose>
        <xsl:when test='$context = "array"'>
          <xsl:call-template name='simple-in-array'>
            <xsl:with-param name='indent' select='$indent'/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name='simple-in-object'>
            <xsl:with-param name='indent' select='$indent'/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>
  
  
  
</xsl:stylesheet>