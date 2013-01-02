<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:np="http://ncbi.gov/portal/XSLT/namespace"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0"
                exclude-result-prefixes="np">
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
      <!--Handling itemspec <m>-->
<xsl:choose>
         <xsl:when test="$context = &#34;a&#34;">
            <xsl:apply-templates select="*">
               <xsl:with-param name="context" select="$context"/>
            </xsl:apply-templates>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates select="@*|*">
               <xsl:with-param name="context" select="$context"/>
            </xsl:apply-templates>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="MedAbbr | IsoAbbr | Country | Publisher | PublicationEndYear | NlmId | ContinuationNotes | Title | string | Language | PublicationStartYear | eISSN | pISSN | @uid | @status">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="s">
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="DocumentSummary">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="o">
         <xsl:with-param name="context" select="$context"/>
         <xsl:with-param name="k" select="@uid"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="BroadHeading">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="a">
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="DocumentSummarySet">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <!--Handling itemspec <o>-->
<o>
         <xsl:if test="$context = &#34;o&#34;">
            <xsl:attribute name="k">
               <xsl:value-of select="&#34;result&#34;"/>
            </xsl:attribute>
         </xsl:if>
         <!--Handling itemspec <a>-->
<a k="{&#34;uids&#34;}">
            <xsl:apply-templates select="DocumentSummary/@uid">
               <xsl:with-param name="context" select="&#34;a&#34;"/>
            </xsl:apply-templates>
         </a>
         <!--Handling itemspec <m>-->
<xsl:apply-templates select="DocumentSummary">
            <xsl:with-param name="context" select="'o'"/>
         </xsl:apply-templates>
      </o>
   </xsl:template>
</xsl:stylesheet>