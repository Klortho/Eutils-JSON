<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" 
                exclude-result-prefixes="xd" 
                version="1.0">

  <xsl:output indent="yes" method="html" />

  <xsl:template match="samples">
    <table>
      <xsl:apply-templates select="*"/>
    </table>
  </xsl:template>

  <xsl:template match="samplegroup">
    <tr>
      <th colspan="4">
        <xsl:value-of select="@header"/>
      </th>
    </tr>
    <xsl:apply-templates/>
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
        <a href="{eutils-url}">
          <xsl:text>eutils</xsl:text>
        </a>
      </td>
      <td>
        <a href="{@name}.xml">
          <xsl:text>xml</xsl:text>
        </a>
      </td>
      <td>
        <a href="{@name}.json">
          <xsl:text>json</xsl:text>
        </a>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match='text()'/>
</xsl:stylesheet>
