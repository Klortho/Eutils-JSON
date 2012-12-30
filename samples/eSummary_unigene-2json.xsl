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
      <!--Handling itemspec <member> or <members>--><xsl:apply-templates select="@*|*">
         <xsl:with-param name="context" select="$context"/>
      </xsl:apply-templates>
   </xsl:template>
   <xsl:template match="GENEID | CHROMOSOME | CLUSTERID | RECORDTYPE | GENE | ORGANISM | TITLE | @uid | @status">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="string">
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="TAXID | SEQ_COUNT | EST_COUNT">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="number">
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="DocumentSummary">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="object">
         <xsl:with-param name="context" select="$context"/>
         <xsl:with-param name="key" select="@uid"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="DocumentSummarySet">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <!--Handling itemspec <object>--><o>
         <xsl:if test="$context = &#34;object&#34;">
            <xsl:attribute name="name">
               <xsl:value-of select="&#34;result&#34;"/>
            </xsl:attribute>
         </xsl:if>
         <!--Handling itemspec <array>--><a name="{&#34;uids&#34;}">
            <xsl:apply-templates select="DocumentSummary/@uid">
               <xsl:with-param name="context" select="&#34;array&#34;"/>
            </xsl:apply-templates>
         </a>
         <!--Handling itemspec <member> or <members>--><xsl:apply-templates select="DocumentSummary">
            <xsl:with-param name="context" select="'object'"/>
         </xsl:apply-templates>
      </o>
   </xsl:template>
</xsl:stylesheet>