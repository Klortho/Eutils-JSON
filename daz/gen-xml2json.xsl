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

      <x:for-each select='declarations/elements/element'>
        <x:sort select='@name'/>
        
        <x:choose>
          <x:when test='@root="true"'>
            <xsl:template match='{@name}'>
              <xsl:call-template name='result-start'/>
              <xsl:apply-templates select='*'>
                <xsl:with-param name='indent' select='$iu'/>
                <xsl:with-param name='context' select='"object"'/>
              </xsl:apply-templates>
              <xsl:text>}</xsl:text>
            </xsl:template>
          </x:when>
          <x:otherwise>
            <x:message>
              <x:text>Need to implement a template for </x:text> 
              <x:value-of select='@name'/>
            </x:message>
          </x:otherwise>
        </x:choose>
      </x:for-each>
    </xsl:stylesheet>
  </x:template>

</x:stylesheet>