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
  
  
  
</xsl:stylesheet>