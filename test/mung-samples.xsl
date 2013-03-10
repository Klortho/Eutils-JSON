<?xml version="1.0" encoding="UTF-8"?>
<!--
  This XSLT takes the old samples/samples.xml file, and creates a new version,
  with the following modifications:
    - <samplegroup>s are rearranged by DTD - every DTD has its own group
    - A lot of annotations and notes fields are removed.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="2.0">
  
  <xsl:output indent="yes"/>
  
  <xsl:template match='/'>
    <samples>
      <xsl:for-each-group select="//sample"
                          group-by='@dtd'>
        <xsl:variable name='dtd' select='current-grouping-key()'/>
        <xsl:variable name='eutil'>
          <xsl:choose>
            <xsl:when test="contains($dtd, 'eInfo')">
              <xsl:value-of select='"einfo"'/>
            </xsl:when>
            <xsl:when test="contains($dtd, 'eSearch')">
              <xsl:value-of select='"esearch"'/>
            </xsl:when>
            <xsl:when test="contains($dtd, 'eSummary')">
              <xsl:value-of select='"esummary"'/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select='"efetch"'/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <samplegroup dtd='{@dtd}' eutil='{$eutil}'>
          <xsl:for-each select='current-group()'>
            <xsl:variable name='db'>
              <xsl:choose>
                <xsl:when test='@name="einfo.pubmed" or
                  @name="esearch.pubmed" or
                  @name="efetch.pubmed" or
                  @name="efetch.pubmedbook"'>
                  <xsl:value-of select='"pubmed"'/>
                </xsl:when>
                <xsl:when test='starts-with(@name, "esummary.") and
                  @name != "esummary.error"'>
                  <xsl:value-of select='substring-after(@name, ".")'/>
                </xsl:when>
              </xsl:choose>
            </xsl:variable>
            <sample name='{@name}'>
              <xsl:if test='string-length($db)'>
                <xsl:attribute name='db'>
                  <xsl:value-of select='$db'/>
                </xsl:attribute>
              </xsl:if>
              <xsl:copy-of select='eutils-url'/>
            </sample>
          </xsl:for-each>
        </samplegroup>
      </xsl:for-each-group>
    </samples>
  </xsl:template>
  
</xsl:stylesheet>