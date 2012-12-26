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
    content, and have attributes.
  -->
  <xsl:template match='AbstractText | 
                       BookTitle |
                       CollectionTitle |
                       Keyword |
                       SectionTitle'>
    <xsl:param name="indent" select="''"/>
    <xsl:param name="context" select="'unknown'"/>

    <xsl:value-of select='np:start-object($indent)'/>
    
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
    </xsl:call-template>
    
    <xsl:value-of select='np:end-object($indent, position() != last())'/>
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


  <!-- 
    AuthorList, DataBankList, Object.  Inside an object.  These are almost normal array-types,
    but they each take some attributes.   We'll create a JSON object at the front of
    the array to hold the attribute values.
  -->
  <xsl:template match='AuthorList | DataBankList | Object'>
    <xsl:param name="indent" select="''"/>
    
    <xsl:value-of select='np:key-start-array($indent, "np:to-lower(name(.))'/>
    
    <xsl:call-template name='object-in-array'>
      <xsl:with-param name="indent" select="concat($indent, $iu)"/>
      <xsl:with-param name='kids' select='@CompleteYN'/>
      <xsl:with-param name='trailing-comma' select='not(not(*))'/>
    </xsl:call-template>

    <xsl:apply-templates select='*'>
      <xsl:with-param name='indent' select='concat($indent, $iu)'/>
      <xsl:with-param name='context' select='"array"'/>
    </xsl:apply-templates>

    <xsl:value-of select='np:end-array()'/>
  </xsl:template>

  <!--
    Author.  Context is array.  This will be a normal object with the exception that the
    NameID (zero-to-many) kids will be turned into an embedded array. 
  -->
  <xsl:template match='Author'>
    <xsl:param name='indent' select='""'/>
    
    <!-- "ci" = current indent.  This will illustrate a formulaic way of incrementing 
      the indent each time we start a new embedded item. Start with "0", which will
      be the indent that we were given as a parameter.    --> 
    <xsl:variable name='ci0' select='$indent'/>  
    
    <xsl:value-of select='np:start-object($ci0)'/>
    <xsl:variable name='ci1' select='concat($ci0, $iu)'/>
    
    <xsl:apply-templates select='@*|*[not(self::NameID)]'>
      <xsl:with-param name='indent' select='$ci1'/>
      <xsl:with-param name="context" select="'object'"/>
      <xsl:with-param name="trailing-comma" select="true()"/>
    </xsl:apply-templates>

    <xsl:call-template name='array-in-object'>
      <xsl:with-param name="indent" select="$ci1"/>
      <xsl:with-param name='key' select='"nameids"'/>
      <xsl:with-param name='kids' select='NameID'
      <xsl:with-param name="trailing-comma" select="false()"/>
    </xsl:call-template>
    
    <xsl:value-of select='np:end-object($ci0, position() != last())'/>
  </xsl:template>



  <!--
    Book.  Context is object.  This will be a normal object with the exception that the
    AuthorList*, Isbn*, and ELocationID* kids will be turned into an embedded arrays. 
  -->
  <xsl:template match='Book'>
    <xsl:param name='indent' select='""'/>
    <xsl:variable name='ci0' select='$indent'/>  
    
    <xsl:value-of select='np:key-start-object($ci0, "book")'/>
    <xsl:variable name='ci1' select='concat($ci0, $iu)'/>
    
    <xsl:apply-templates select='@*|*[not(self::NameID or self::Isbn or self::ELocationID)]'>
      <xsl:with-param name='indent' select='$ci1'/>
      <xsl:with-param name="context" select="'object'"/>
      <xsl:with-param name="trailing-comma" select="true()"/>
    </xsl:apply-templates>
    
    <xsl:call-template name='array-in-object'>
      <xsl:with-param name="indent" select="$ci1"/>
      <xsl:with-param name='key' select='"authorlists"'/>
      <xsl:with-param name='kids' select='AuthorList'/>
      <xsl:with-param name="trailing-comma" select="true()"/>
    </xsl:call-template>
    
    <xsl:call-template name='array-in-object'>
      <xsl:with-param name="indent" select="$ci1"/>
      <xsl:with-param name='key' select='"isbns"'/>
      <xsl:with-param name='kids' select='Isbn'/>
      <xsl:with-param name="trailing-comma" select="true()"/>
    </xsl:call-template>
    
    <xsl:call-template name='array-in-object'>
      <xsl:with-param name="indent" select="$ci1"/>
      <xsl:with-param name='key' select='"elocationids"'/>
      <xsl:with-param name='kids' select='ELocationID'/>
      <xsl:with-param name="trailing-comma" select="false()"/>
    </xsl:call-template>

    <xsl:value-of select='np:end-object($ci0, position() != last())'/>
  </xsl:template>
  

</xsl:stylesheet>