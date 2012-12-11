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
        <th>Status</th>
        <th>Local files</th>
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
        <xsl:if test='@dtd'>
          <a href="{@dtd}">
            <xsl:text>dtd</xsl:text>
          </a>,
        </xsl:if>
        <a href="../../blob/master/samples/{@name}.xml">
          <xsl:text>xml</xsl:text>
        </a>,
        <a href="../../blob/master/samples/{@name}.json">
          <xsl:text>json</xsl:text>
        </a>
      </td>
      <td>
        <xsl:value-of select='desc'/>
      </td>
      <td>
        <a href="{eutils-url}">
          <xsl:text>get xml</xsl:text>
        </a>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match='text()'/>
</xsl:stylesheet>
