<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:x="http://www.w3.org/1999/XSL/Transform" version="1.0">
   <xsl:import href="../XML2JSON.xsl"/>
   <xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>
   <xsl:template match="Count">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="simple">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="DbInfo">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="object">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="DbList">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="array">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="DbName">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="simple">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="DbTo">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="simple">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="Description">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="simple">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="eInfoResult">
      <xsl:call-template name="result-start"/>
      <xsl:apply-templates select="*">
         <xsl:with-param name="indent" select="$iu"/>
         <xsl:with-param name="context" select="&#34;object&#34;"/>
      </xsl:apply-templates>
      <xsl:value-of select="concat(&#34;}&#34;, $nl)"/>
   </xsl:template>
   <xsl:template match="ERROR">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="simple">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
         <xsl:with-param name="key" select="&#34;ERROR&#34;"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="Field">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="object">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="FieldList">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="array">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="FullName">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="simple">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="Hierarchy">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="simple">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="IsDate">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="simple">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="IsHidden">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="simple">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="IsNumerical">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="simple">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="IsRangable">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="simple">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="IsTruncatable">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="simple">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="LastUpdate">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="simple">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="Link">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="object">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="LinkList">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="array">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="Menu">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="simple">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="MenuName">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="simple">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="Name">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="simple">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="SingleToken">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="simple">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="TermCount">
      <xsl:param name="indent" select="&#34;&#34;"/>
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="simple">
         <xsl:with-param name="indent" select="$indent"/>
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
</xsl:stylesheet>