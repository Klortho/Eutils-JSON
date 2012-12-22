<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
                exclude-result-prefixes="xd"
                version="1.0">

  <xsl:template match='PdbAccSynList'>
    <xsl:param name="indent" select="&#34;&#34;"/>
    <xsl:param name="context" select="&#34;unknown&#34;"/>
    <xsl:call-template name="string">
      <xsl:with-param name="indent" select="$indent"/>
      <xsl:with-param name="context" select="$context"/>
    </xsl:call-template>
  </xsl:template>
</xsl:stylesheet>