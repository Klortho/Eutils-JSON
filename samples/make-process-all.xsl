<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  exclude-result-prefixes="xd"
  version="1.0">

  <xsl:output method="text"/>
  <xsl:variable name='nl' select='"&#10;"'/>
  
  <xsl:template match='/'>
    <xsl:for-each select='//sample'>
      <xsl:variable name='dtd' select='@dtd'/>
      <xsl:variable name='jsonxsl' 
        select='concat(substring(@dtd, 1, string-length(@dtd) - 4), "-2json.xsl")'/>
      
      <xsl:if test='not(preceding-sibling::sample[@dtd=$dtd])'>
        <xsl:value-of select='concat($nl, "#dtd2xml2json ", $dtd, " ", $jsonxsl, $nl)'/>
      </xsl:if>
      <xsl:value-of select='concat(
          "#xsltproc ", $jsonxsl, " ", @name, ".xml > ", @name, ".json", $nl
        )'/>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>