<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0"
                xmlns:np="http://ncbi.gov/portal/XSLT/namespace"
                extension-element-prefixes="np">
  

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
    <xsl:param name="context" select="'unknown'"/>

    <o>
      <xsl:if test='$context = "o"'>
        <xsl:attribute name='name'>
          <xsl:value-of select='np:translate-name()'/>
        </xsl:attribute>
      </xsl:if>

      <xsl:apply-templates select='@*'>
        <xsl:with-param name="context" select="'o'"/>
      </xsl:apply-templates>
      
      <xsl:variable name='value'>
        <xsl:apply-templates select='node()' mode='markup-to-string'/>
      </xsl:variable>
      <xsl:call-template name='s-in-o'>
        <xsl:with-param name='k' select='"value"'/>
        <xsl:with-param name='value' select='$value'/>
      </xsl:call-template>
    
    </o>
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
    <xsl:param name="context" select="'unknown'"/>

    <xsl:variable name='value'>
      <xsl:apply-templates select='node()' mode='markup-to-string'/>
    </xsl:variable>
    <xsl:call-template name='s'>
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