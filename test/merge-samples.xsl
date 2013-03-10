<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs"
  version="2.0">

  <xsl:variable name='new-samples' select='document("esummary-random-samples.xml")'/>
  
  <xsl:template match='/'>
    <xsl:apply-templates select='*'/>
  </xsl:template>

  <xsl:template match='@*|node()'>
    <xsl:copy>
      <xsl:apply-templates select='@*|node()'/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match='samplegroup'>
    <xsl:variable name='dtd' select='@dtd'/>
    <xsl:variable name='nsg' select='$new-samples//samplegroup[@dtd=$dtd]'/>
    
    <xsl:copy>
      <xsl:apply-templates select='@*|node()'/>
      <xsl:apply-templates select='$nsg/node()'/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>