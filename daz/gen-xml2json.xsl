<?xml version="1.0" encoding="UTF-8"?>
<x:stylesheet xmlns:x="http://www.w3.org/1999/XSL/Transform"
                xmlns:xsl="dummy-namespace-for-the-generated-xslt"
                exclude-result-prefixes="xsl"
                version="1.0">

  <x:namespace-alias stylesheet-prefix="xsl" result-prefix="x"/>
  <x:output encoding="UTF-8" method="xml" indent="yes" />
  
  <x:variable name='nl' select='"&#10;"'/>
  
  <x:template match="/">
    <!-- Generate the structure of the XSL stylesheet -->
    <xsl:stylesheet version="1.0">

      <xsl:import href='../XML2JSON.xsl'/>
      <xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>

      <x:apply-templates select='declarations/elements/element'>
        <x:sort select='@name'/>
      </x:apply-templates>
    </xsl:stylesheet>
  </x:template>

  <x:template match='element'>
    <x:variable name='content-type' select='string(annotations/annotation[@type="json"]/type)'/>
    <x:variable name='key' select='string(annotations/annotation[@type="json"]/key)'/>

    <x:choose>
      <x:when test='@root="true"'>
        <x:value-of select='$nl'/>
        <x:comment> Root element. </x:comment>
        <xsl:template match='{@name}'>
          <xsl:call-template name='result-start'/>
          <xsl:apply-templates select='*'>
            <xsl:with-param name='indent' select='$iu'/>
            <xsl:with-param name='context' select='"object"'/>
          </xsl:apply-templates>
          <xsl:value-of select='concat("}}", $nl)'/>
        </xsl:template>
      </x:when>

      <!-- simple-obj -->
      <x:when test='$content-type = "simple-obj"'>
        <x:value-of select='$nl'/>
        <x:comment> 
          <x:text> content-type override:  simple-obj </x:text>
        </x:comment>
        <xsl:template match='{@name}'>
          <xsl:param name='indent' select='""'/>
          <xsl:param name='context' select='"unknown"'/>
          <xsl:call-template name='simple-obj-in-array'>
            <xsl:with-param name='indent' select='$indent'/>
            <xsl:with-param name='context' select='$context'/>
            <x:if test='$key != ""'>
              <xsl:with-param name='key' select='$key'/>
            </x:if>
          </xsl:call-template>
        </xsl:template>
      </x:when>
      
      <!-- simple -->
      <x:when test='$content-type = "simple" or
                    content-model/@spec = "text"'>
        <x:value-of select='$nl'/>

        <x:comment> 
          <x:choose>
            <x:when test='$content-type="simple"'>
              <x:text> content-type override:  simple </x:text>
            </x:when>
            <x:otherwise>
              Text content 
            </x:otherwise>
          </x:choose>          
        </x:comment>
        
        <xsl:template match='{@name}'>
          <xsl:param name='indent' select='""'/>
          <xsl:param name='context' select='"unknown"'/>
          <xsl:call-template name='simple'>
            <xsl:with-param name='indent' select='$indent'/>
            <xsl:with-param name='context' select='$context'/>
            <x:if test='$key != ""'>
              <xsl:with-param name='key' select='{$key}'/>
            </x:if>
          </xsl:call-template>
        </xsl:template>
      </x:when>
      
      <!-- array -->
      <x:when test='$content-type = "array" or (
                      content-model/@spec = "element" and 
                      count(content-model/choice/child) = 1 )'>
        <x:value-of select='$nl'/>

        <x:comment> 
          <x:choose>
            <x:when test='$content-type="array"'>
              <x:text> content-type override:  array </x:text>
            </x:when>
            <x:otherwise>
              Element content with exactly one child (homogenous content).
              FIXME:  need to check quantifier; if absent or '?', then this could be
              simple content.
            </x:otherwise>
          </x:choose>          
        </x:comment>
        
        <xsl:template match='{@name}'>
          <xsl:param name='indent' select='""'/>
          <xsl:param name='context' select='"unknown"'/>
          <xsl:call-template name='array'>
            <xsl:with-param name='indent' select='$indent'/>
            <xsl:with-param name='context' select='$context'/>
            <x:if test='$key != ""'>
              <xsl:with-param name='key' select='$key'/>
            </x:if>
          </xsl:call-template>
        </xsl:template>
      </x:when>
      
      <!-- object -->
      <x:when test='$content-type = "object" or (
                      content-model/@spec = "element" and
                      not( content-model//child[@q="+" or @q="*"] |
                           content-model//choice[@q="+" or @q="*"] |
                           content-model//seq[@q="+" or @q="*"] )
                    )'>
        <x:value-of select='$nl'/>
        <x:comment> 
          <x:choose>
            <x:when test='$content-type="object"'>
              <x:text> content-type override:  object </x:text>
            </x:when>
            <x:otherwise>
              Element content with more than one child, and each child can
              appear at most once.
            </x:otherwise>
          </x:choose>          
        </x:comment>
        <xsl:template match='{@name}'>
          <xsl:param name='indent' select='""'/>
          <xsl:param name='context' select='"unknown"'/>
          <xsl:call-template name='object'>
            <xsl:with-param name='indent' select='$indent'/>
            <xsl:with-param name='context' select='$context'/>
            <x:if test='$key != ""'>
              <xsl:with-param name='key' select='$key'/>
            </x:if>
          </xsl:call-template>
        </xsl:template>
      </x:when>
      
      <x:otherwise>
        <x:message>
          <x:text>Need to implement a template for </x:text> 
          <x:value-of select='@name'/>
        </x:message>
      </x:otherwise>
    </x:choose>
  </x:template>
</x:stylesheet>