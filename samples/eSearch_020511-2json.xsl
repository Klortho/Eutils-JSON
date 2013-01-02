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
      <json type="esearch" version="0.3">
         <config lcnames="true"/>
      </json>
   </xsl:param>
   <xsl:template match="RetMax | To | Term | QueryKey | Explode | FieldNotFound | From | OP | PhraseIgnored | RetStart | WebEnv | OutputMessage | QuotedPhraseNotFound | Id | Field | Count | PhraseNotFound | QueryTranslation">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="s">
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="eSearchResult | Translation | TermSet">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="o">
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="ERROR">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="s">
         <xsl:with-param name="context" select="$context"/>
         <xsl:with-param name="k" select="&#34;ERROR&#34;"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="ErrorList">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <!--Handling itemspec <o>-->
<o>
         <xsl:if test="$context = &#34;o&#34;">
            <xsl:attribute name="k">
               <xsl:value-of select="np:translate-name()"/>
            </xsl:attribute>
         </xsl:if>
         <!--Handling itemspec <a>-->
<a k="{&#34;phrasesnotfound&#34;}">
            <xsl:apply-templates select="PhraseNotFound">
               <xsl:with-param name="context" select="&#34;a&#34;"/>
            </xsl:apply-templates>
         </a>
         <!--Handling itemspec <a>-->
<a k="{&#34;fieldsnotfound&#34;}">
            <xsl:apply-templates select="FieldsNotFound">
               <xsl:with-param name="context" select="&#34;a&#34;"/>
            </xsl:apply-templates>
         </a>
      </o>
   </xsl:template>
   <xsl:template match="IdList | TranslationSet | TranslationStack">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="a">
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="WarningList">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <!--Handling itemspec <o>-->
<o>
         <xsl:if test="$context = &#34;o&#34;">
            <xsl:attribute name="k">
               <xsl:value-of select="np:translate-name()"/>
            </xsl:attribute>
         </xsl:if>
         <!--Handling itemspec <a>-->
<a k="{&#34;phrasesignored&#34;}">
            <xsl:apply-templates select="PhraseIgnored">
               <xsl:with-param name="context" select="&#34;a&#34;"/>
            </xsl:apply-templates>
         </a>
         <!--Handling itemspec <a>-->
<a k="{&#34;quotedphrasesnotfound&#34;}">
            <xsl:apply-templates select="QuotedPhraseNotFound">
               <xsl:with-param name="context" select="&#34;a&#34;"/>
            </xsl:apply-templates>
         </a>
         <!--Handling itemspec <a>-->
<a k="{&#34;outputmessages&#34;}">
            <xsl:apply-templates select="OutputMessage">
               <xsl:with-param name="context" select="&#34;a&#34;"/>
            </xsl:apply-templates>
         </a>
      </o>
   </xsl:template>
</xsl:stylesheet>