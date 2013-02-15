<?xml version="1.0" encoding="UTF-8"?>

<!--
  This stylesheet converts samples.xml into an HTML fragment that
  can then be inserted into the README.md file here.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
                exclude-result-prefixes="xd"
                version="1.0">

  <xsl:output indent="yes" method="xml" omit-xml-declaration='yes'/>

  <xsl:template match="samples">
    <div>
      <xsl:apply-templates select="*"/>
    </div>
  </xsl:template>

  <xsl:template match="samplegroup">
    <h2>
      <xsl:value-of select='@header'/>
    </h2>
    <table>
      <tr>
        <th></th>
        <th>✓</th>
        <th>Description / Notes</th>
        <th>Links</th>
      </tr>
      <xsl:apply-templates/>
    </table>
  </xsl:template>

  <xsl:template match="sample">
    <tr>
      <th>
        <xsl:value-of select="@title"/>
      </th>
      <td>
        <xsl:value-of select="@status"/>
      </td>
      <td>
        <xsl:apply-templates select='notes/*'/>
      </td>
      <td>
        <xsl:if test='@dtd'>
          <a href="{@dtd}">DTD</a>
          <xsl:text>,&#160;</xsl:text>
          <!-- Assume the DTD filename always ends in ".dtd" -->
          <xsl:variable name='xslName'
            select='concat(substring(@dtd, 1, string-length(@dtd) - 4), "-2json.xsl")'/>
          <a href='{$xslName}'>XSLT</a>
          <xsl:text>;</xsl:text>
          <br/>
        </xsl:if>
        <xsl:text>XML:&#160;</xsl:text>
        <a href="{@name}.xml">local</a>
        <xsl:text>,&#160;</xsl:text>
        <a href="{eutils-url}">eutils;</a>
        <br/>
        <a href="{@name}.json">JSON</a>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match='desc'>
    <em>
      <xsl:apply-templates/>
    </em>
    <xsl:if test='position() != last()'>
      <br/>
    </xsl:if>
  </xsl:template>

  <xsl:template match='note'>
    <xsl:choose>
      <xsl:when test='@rid'>
        <xsl:variable name='target'>
          <xsl:choose>
            <xsl:when test='@rid = "①"'>
              <xsl:text>-all-esummary-dtds-use-the-same-public-identifier</xsl:text>
            </xsl:when>
            <xsl:when test='@rid = "②"'>
              <xsl:text>-xml-results-that-fail-to-validate-bad-dtds</xsl:text>
            </xsl:when>
            <xsl:when test='@rid = "③"'>
              <xsl:text>-dtds-elements-that-are-under-specified</xsl:text>
            </xsl:when>
            <xsl:when test='@rid = "④"'>
              <xsl:text>-errors-in-dtds</xsl:text>
            </xsl:when>
            <xsl:when test='@rid = "⑤"'>
              <xsl:text>-escaped-markup</xsl:text>
            </xsl:when>
            <xsl:when test='@rid = "⑥"'>
              <xsl:text>-miscellaneous-problems--questions--suggestions</xsl:text>
            </xsl:when>
          </xsl:choose>
        </xsl:variable>
        <a href='{concat("#", $target)}'><xsl:value-of select='@rid'/></a>
        <xsl:text> </xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>⇒ </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test='normalize-space(.) != ""'>
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:when test='@rid = "①"'>
        <xsl:text>Each ESummary DTD should have a unique public identifier.</xsl:text>
      </xsl:when>      
      <xsl:when test='@rid = "③"'>
        <xsl:text>All of the ESummary DTDs have elements that are underspecified.</xsl:text>
      </xsl:when>
    </xsl:choose>
    <xsl:if test='position() != last()'>
      <br/>
    </xsl:if>
  </xsl:template>

  <xsl:template match='@*|*|text()'>
    <xsl:copy>
      <xsl:apply-templates select='@*|*|text()'/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
