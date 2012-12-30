<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:np="http://ncbi.gov/portal/XSLT/namespace"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                version="1.0"
                exclude-result-prefixes="np xs">
   <xsl:import href="xml2json.xsl"/>
   <xsl:output method="text" encoding="UTF-8"/>
   <xsl:param name="pretty" select="true()"/>
   <xsl:param name="lcnames" select="true()"/>
   <xsl:param name="dtd-annotation">
      <json type="esummary" version="0.3">
         <config lcnames="true"/>
      </json>
   </xsl:param>
   <xsl:template match="eSummaryResult">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="array">
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="ERROR | Id | @Type | @Name">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="string">
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
</xsl:stylesheet>