<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" 
                exclude-result-prefixes="xd" 
                version="1.0">

  <xsl:output indent="yes" method="html" />

  <xsl:template match="samples">
    <xsl:apply-templates select="*"/>
  </xsl:template>

  <xsl:template match="samplegroup">
    <h2>
      <xsl:value-of select='@header'/>
    </h2>
    <table>
      <tr>
        <th></th>
        <th>Status</th>
        <th rowspan='2'>Local files</th>
        <th>Comment</th>
        <th>NCBI EUtils</th>
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
        <a href="../../blob/master/samples/{@name}.xml">
          <xsl:text>xml</xsl:text>
        </a>
      </td>
      <td>
        <a href="../../blob/master/samples/{@name}.json">
          <xsl:text>json</xsl:text>
        </a>
      </td>
      <td>
        <xsl:value-of select='desc'/>
      </td>
      <td>
        <a href="{eutils-url}">
          <xsl:value-of select='eutils-url'/>
        </a>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match='text()'/>
</xsl:stylesheet>
