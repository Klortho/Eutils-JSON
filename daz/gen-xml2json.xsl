<?xml version="1.0" encoding="UTF-8"?>
<x:stylesheet xmlns:x="http://www.w3.org/1999/XSL/Transform"
                xmlns:xsl="dummy-namespace-for-the-generated-xslt"
                exclude-result-prefixes="xsl"
                version="1.0">

  <x:namespace-alias stylesheet-prefix="xsl" result-prefix="x"/>
  <x:output encoding="UTF-8" method="xml" indent="yes" />
  
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
    <x:variable name='key' select='string(annotations/annotation[@type="json"]/key)'/>

    <x:choose>
      <x:when test='@root="true"'>
        <xsl:template match='{@name}'>
          <xsl:call-template name='result-start'/>
          <xsl:apply-templates select='*'>
            <xsl:with-param name='indent' select='$iu'/>
            <xsl:with-param name='context' select='"object"'/>
          </xsl:apply-templates>
          <xsl:value-of select='concat("}}", $nl)'/>
        </xsl:template>
      </x:when>
      <x:when test='content-model/@spec = "text"'>
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
      <x:when test='content-model/@spec = "element" and 
        count(content-model/choice/child) = 1'>
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
      <x:when test='content-model/@spec = "element" and
        not(content-model//child[@q="+" or @q="*"])'>
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