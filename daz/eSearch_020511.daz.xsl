<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:x="http://www.w3.org/1999/XSL/Transform" version="1.0">
   <xsl:import href="../XML2JSON.xsl"/>
   <xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>
<!--
              Text content 
            -->
   <xsl:template match="Count">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="simple">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
<!--
              Text content 
            -->
   <xsl:template match="ERROR">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="simple">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
         <xsl:with-param name="key" select="&#34;ERROR&#34;"/>
      </xsl:call-template>
   </xsl:template>
<!-- content-type override:  array -->
   <xsl:template match="ErrorList">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="array">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
<!-- Root element. -->
   <xsl:template match="eSearchResult">
      <xsl:call-template name="result-start"/>
      <xsl:apply-templates select="*">
         <xsl:with-param name="indent" select="$iu"/>
         <xsl:with-param name="context" select="&#34;object&#34;"/>
      </xsl:apply-templates>
      <xsl:value-of select="concat(&#34;}&#34;, $nl)"/>
   </xsl:template>
<!--
              Text content 
            -->
   <xsl:template match="Explode">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="simple">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
<!--
              Text content 
            -->
   <xsl:template match="Field">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="simple">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
<!-- content-type override:  simple-obj -->
   <xsl:template match="FieldNotFound">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="simple-obj-in-array">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
<!--
              Text content 
            -->
   <xsl:template match="From">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="simple">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
<!--
              Text content 
            -->
   <xsl:template match="Id">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="simple">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
<!--
              Element content with exactly one child (homogenous content).
              FIXME:  need to check quantifier; if absent or '?', then this could be
              simple content.
            -->
   <xsl:template match="IdList">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="array">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
<!--
              Text content 
            -->
   <xsl:template match="OP">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="simple">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
<!-- content-type override:  simple-obj -->
   <xsl:template match="OutputMessage">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="simple-obj-in-array">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
<!-- content-type override:  simple-obj -->
   <xsl:template match="PhraseIgnored">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="simple-obj-in-array">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
<!-- content-type override:  simple-obj -->
   <xsl:template match="PhraseNotFound">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="simple-obj-in-array">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
<!--
              Text content 
            -->
   <xsl:template match="QueryKey">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="simple">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
<!--
              Text content 
            -->
   <xsl:template match="QueryTranslation">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="simple">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
<!-- content-type override:  simple-obj -->
   <xsl:template match="QuotedPhraseNotFound">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="simple-obj-in-array">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
<!--
              Text content 
            -->
   <xsl:template match="RetMax">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="simple">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
<!--
              Text content 
            -->
   <xsl:template match="RetStart">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="simple">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
<!--
              Text content 
            -->
   <xsl:template match="Term">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="simple">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
<!--
              Element content with more than one child, and each child can
              appear at most once.
            -->
   <xsl:template match="TermSet">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="object">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
<!--
              Text content 
            -->
   <xsl:template match="To">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="simple">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
<!--
              Element content with more than one child, and each child can
              appear at most once.
            -->
   <xsl:template match="Translation">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="object">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
<!--
              Element content with exactly one child (homogenous content).
              FIXME:  need to check quantifier; if absent or '?', then this could be
              simple content.
            -->
   <xsl:template match="TranslationSet">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="array">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
<!-- content-type override:  array -->
   <xsl:template match="TranslationStack">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="array">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
<!-- content-type override:  array -->
   <xsl:template match="WarningList">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="array">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
<!--
              Text content 
            -->
   <xsl:template match="WebEnv">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="simple">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
</xsl:stylesheet>