<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0"
                xmlns:np="http://ncbi.gov/portal/XSLT/namespace"
                extension-element-prefixes="np">
  
  <xsl:template match="PubmedArticleSet">
    <xsl:call-template name="result-start">
      <xsl:with-param name="dtd-annotation">
        <json type="efetch.pubmed" version="0.3">
          <config lcnames="true" import="pubmed.xsl"/>
        </json>
      </xsl:with-param>
    </xsl:call-template>

    <xsl:call-template name='array-in-object'>
      <xsl:with-param name="indent" select="$iu"/>
      <xsl:with-param name='key' select='"pubmedarticles"'/>
      <xsl:with-param name='kids' select='PubmedArticle'/>
      <xsl:with-param name='trailing-comma' select='true()'/>
    </xsl:call-template>
    
    <xsl:call-template name='array-in-object'>
      <xsl:with-param name="indent" select="$iu"/>
      <xsl:with-param name='key' select='"pubmedbookarticles"'/>
      <xsl:with-param name='kids' select='PubmedBookArticle'/>
    </xsl:call-template>
    
    <xsl:value-of select="np:end-object(&#34;&#34;, false())"/>
  </xsl:template>


  <!-- 
    Elements from nlmmedlinecitationset that have "%text;"
    content, and have attributes.  These are converted into an object
    with one member for each attribute, and one member named "value" for
    the content.
  -->
  <xsl:template match='AbstractText | 
                       BookTitle |
                       CollectionTitle |
                       Keyword |
                       SectionTitle'>
    <xsl:param name="indent" select="''"/>
    <xsl:param name="context" select="'unknown'"/>
    <xsl:param name='trailing-comma' select='position() != last()'/>

    <xsl:choose>
      <xsl:when test='$context = "array"'>
        <xsl:value-of select='np:start-object($indent)'/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="key" select="np:to-lower(name(.))"/>
        <xsl:value-of select="np:key-start-object($indent, $key)"/>
      </xsl:otherwise>
    </xsl:choose>
    
    <xsl:apply-templates select='@*'>
      <xsl:with-param name="indent" select="concat($indent, $iu)"/>
      <xsl:with-param name="context" select="'object'"/>
      <xsl:with-param name='trailing-comma' select='true()'/>
    </xsl:apply-templates>
    
    <xsl:variable name='value'>
      <xsl:apply-templates select='node()' mode='markup-to-string'/>
    </xsl:variable>
    <xsl:call-template name='string-in-object'>
      <xsl:with-param name="indent" select="concat($indent, $iu)"/>
      <xsl:with-param name='key' select='"value"'/>
      <xsl:with-param name='value' select='$value'/>
      <xsl:with-param name='trailing-comma' select='false()'/>
    </xsl:call-template>
    
    <xsl:value-of select='np:end-object($indent, $trailing-comma)'/>
  </xsl:template>

  <!-- 
    Elements from nlmmedlinecitationset that have %text; content, but
    no attributes.  The content of these is serialized, and inserted into
    a JSON string.
  -->
  <xsl:template match='ArticleTitle | 
                       Affiliation | 
                       CitationString |
                       CollectiveName |
                       PublisherName |
                       Suffix | 
                       VernacularTitle |
                       VolumeTitle' >
    <xsl:param name="indent" select="''"/>
    <xsl:param name="context" select="'unknown'"/>

    <xsl:variable name='value'>
      <xsl:apply-templates select='node()' mode='markup-to-string'/>
    </xsl:variable>
    <xsl:call-template name='string'>
      <xsl:with-param name="indent" select="$indent"/>
      <xsl:with-param name="context" select="$context"/>
      <xsl:with-param name='value' select='$value'/>
    </xsl:call-template>
  </xsl:template>

  <!-- 
    This serializes simple marked up content into a pseudo-HTML string.
  -->
  <xsl:template match='text()' mode='markup-to-string'>
    <xsl:copy-of select='.'/>
  </xsl:template>

  <xsl:template match='b|i|sup|sub|u' mode='markup-to-string'>
    <xsl:value-of select='concat("&lt;", name(.), "&gt;")'/>
    <xsl:apply-templates select='node()' mode='markup-to-string'/>
    <xsl:value-of select='concat("&lt;/", name(.), "&gt;")'/>
  </xsl:template>



</xsl:stylesheet>