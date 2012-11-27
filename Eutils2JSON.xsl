<!--
  XSLT 1.0 stylesheet for conversion of E-Utilities XML to JSON.

  This work is in the public domain and may be reproduced, published or
  otherwise used without the permission of the National Library of Medicine (NLM).

  We request only that the NLM is cited as the source of the work.

  Although all reasonable efforts have been taken to ensure the accuracy and
  reliability of the software and data, the NLM and the U.S. Government  do
  not and cannot warrant the performance or results that may be obtained  by
  using this software or data. The NLM and the U.S. Government disclaim all
  warranties, express or implied, including warranties of performance,
  merchantability or fitness for any particular purpose.
-->

<xsl:stylesheet version="1.0" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:np="http://ncbi.gov/portal/XSLT/namespace"
                xmlns:f="http://exslt.org/functions"
                extension-element-prefixes="np f">
  
  <xsl:import href='XML2JSON.xsl'/>
  <xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>

  
  
  <xsl:template match='ERROR'>
    <xsl:param name='indent' select='""'/>
    <xsl:param name='context' select='"object"'/>
    
    <xsl:call-template name='simple-in-object'>
      <xsl:with-param name='indent' select='$indent'/>
      <xsl:with-param name='context' select='$context'/>
      <xsl:with-param name='key' select='"ERROR"'/>
    </xsl:call-template>        
  </xsl:template>

  
  <!--============================================================
    einfo-specific
  -->
  
  <xsl:template match='eInfoResult'>
    <xsl:call-template name='result-start'/>
    <xsl:apply-templates select='*'>
      <xsl:with-param name='indent' select='$iu'/>
      <xsl:with-param name='context' select='"object"'/>
    </xsl:apply-templates>
    <xsl:text>}</xsl:text>
  </xsl:template>
  
  <xsl:template match="DbList">
    <xsl:param name='indent' select='""'/>
    
    <xsl:call-template name='array-in-object'>
      <xsl:with-param name='indent' select='$indent'/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match='DbList/DbName'>
    <xsl:param name='indent' select='""'/>
    
    <xsl:call-template name='simple-in-array'>
      <xsl:with-param name='indent' select='$indent'/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="DbInfo">
    <xsl:param name='indent' select='""'/>
    
    <xsl:call-template name='object-in-object'>
      <xsl:with-param name='indent' select='$indent'/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match='DbInfo/DbName |
                       MenuName |
                       Description |
                       Count |
                       LastUpdate |
                       FullName |
                       TermCount |
                       IsDate |
                       IsNumerical |
                       SingleToken |
                       Hierarchy |
                       IsHidden |
                       Menu |
                       DbTo'>
    <xsl:param name='indent' select='""'/>

    <xsl:call-template name='simple-in-object'>
      <xsl:with-param name='indent' select='$indent'/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match='FieldList |
                       LinkList'>
    <xsl:param name='indent' select='""'/>
    
    <xsl:call-template name='array-in-object'>
      <xsl:with-param name='indent' select='$indent'/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match='Field |
                       Link'>
    <xsl:param name='indent' select='""'/>
    
    <xsl:call-template name='object-in-array'>
      <xsl:with-param name='indent' select='$indent'/>
    </xsl:call-template>
  </xsl:template>

  <!--============================================================
      Esummary version 2.0 specific
  -->
  <xsl:template match='eSummaryResult'>
    <xsl:call-template name='result-start'/>
    <xsl:apply-templates select='*'>
      <xsl:with-param name='indent' select='$iu'/>
      <xsl:with-param name='context' select='"object"'/>
    </xsl:apply-templates>
    <xsl:text>}</xsl:text>
  </xsl:template>
  
  <xsl:template match='DocumentSummarySet[@status="OK"]'>
    <xsl:param name='indent' select='""'/>
    
    <xsl:value-of select='concat(
      $indent, np:dq("docsums"), ": {", $nl, $indent, $iu)'/>
    
    <!-- Output the uids as an array -->
    <xsl:value-of select='concat(np:dq("uids"), ": [", $nl)'/>
    <xsl:apply-templates select='DocumentSummary/@uid'>
      <xsl:with-param name='indent' select='concat($indent, $iu2)'/>
    </xsl:apply-templates>
    <xsl:value-of select='concat($indent, $iu, "],", $nl)'/>
    
    <xsl:apply-templates select='DocumentSummary' >
      <xsl:with-param name='indent' select='concat($indent, $iu)'/>
    </xsl:apply-templates>
    
    <xsl:value-of select='concat($indent, "}", $nl)'/>
  </xsl:template>
  
  <xsl:template match='DocumentSummary/@uid'>
    <xsl:param name='indent' select='""'/>
    
    <xsl:call-template name='simple-in-array'>
      <xsl:with-param name='indent' select='$indent'/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match='DocumentSummary'>
    <xsl:param name='indent' select='""'/>
    
    <xsl:call-template name='object-in-object'>
      <xsl:with-param name='indent' select='$indent'/>
      <xsl:with-param name='key' select='@uid'/>
    </xsl:call-template>
  </xsl:template>

  <!-- simple-in-array -->
  <xsl:template match='string | 
                       flag'>
    <xsl:param name='indent' select='""'/>
    
    <xsl:call-template name='simple-in-array'>
      <xsl:with-param name='indent' select='$indent'/>
    </xsl:call-template>
  </xsl:template>
  
  <!-- simple-in-object -->
  <xsl:template match='PubDate | 
                       EPubDate | 
                       Source | 
                       LastAuthor | 
                       Title | 
                       SortTitle | 
                       Volume |
                       Issue |
                       Pages |
                       NlmUniqueID |
                       ISSN |
                       ESSN |
                       PubStatus |
                       PmcRefCount |
                       FullJournalName |
                       ELocationID |
                       ViewCount |
                       DocType |
                       BookTitle |
                       Medium |
                       Edition |
                       PublisherLocation |
                       PublisherName |
                       SrcDate |
                       ReportNumber |
                       AvailableFromURL |
                       LocationLabel |
                       DocDate |
                       BookName |
                       Chapter |
                       SortPubDate |
                       SortFirstAuthor |
                       Name |
                       AuthType |
                       ClusterID |
                       RecordStatus |
                       IdType |
                       IdTypeN |
                       Value | 
                       Date |
                       Marker_Name |
                       Org |
                       Chr |
                       Locus |
                       Polymorphic |
                       EPCR_Summary |
                       Gene_ID |
                       SortDate |
                       PmcLiveDate |
                       DocumentSummary/error'>
    <xsl:param name='indent' select='""'/>
    
    <xsl:call-template name='simple-in-object'>
      <xsl:with-param name="indent" select='$indent'/>
    </xsl:call-template>
  </xsl:template>
  
  <!-- array-in-object -->
  <xsl:template match='Authors | 
                       Lang | 
                       PubType |
                       ArticleIds |
                       History |
                       References |
                       Attributes |
                       SrcContribList |
                       DocContribList |
                       Map_Gene_Summary_List'>
    <xsl:param name='indent' select='""'/>
    
    <xsl:call-template name='array-in-object'>
      <xsl:with-param name='indent' select='$indent'/>
    </xsl:call-template>
  </xsl:template>

  <!-- object-in-array -->
  <xsl:template match='Author | 
                       ArticleId |
                       PubMedPubDate |
                       Map_Gene_Summary'>
    <xsl:param name='indent' select='""'/>
    
    <xsl:call-template name='object-in-array'>
      <xsl:with-param name='indent' select='$indent'/>
    </xsl:call-template>
  </xsl:template>

  <!--============================================================
    ESearch 
  -->

  <xsl:template match='eSearchResult'>
    <xsl:call-template name='result-start'/>
    <xsl:apply-templates select='*'>
      <xsl:with-param name='indent' select='$iu'/>
      <xsl:with-param name='context' select='"object"'/>
    </xsl:apply-templates>
    <xsl:text>}</xsl:text>
  </xsl:template>

  <!-- simple-in-object -->
  <xsl:template match='RetMax |
                       RetStart |
                       QueryKey |
                       WebEnv |
                       From |
                       To |
                       Term |
                       TermSet/Field |
                       Explode |
                       QueryTranslation'>
    <xsl:param name='indent' select='""'/>
    
    <xsl:call-template name='simple-in-object'>
      <xsl:with-param name="indent" select='$indent'/>
    </xsl:call-template>
  </xsl:template>

  <!-- simple-in-array -->
  <xsl:template match='Id |
                       OP'>
    <xsl:param name='indent' select='""'/>
    
    <xsl:call-template name='simple-in-array'>
      <xsl:with-param name='indent' select='$indent'/>
    </xsl:call-template>
  </xsl:template>
  
  <!-- array-in-object -->
  <xsl:template match='IdList |
                       TranslationSet |
                       ErrorList'>
    <xsl:param name='indent' select='""'/>
    
    <xsl:call-template name='array-in-object'>
      <xsl:with-param name='indent' select='$indent'/>
    </xsl:call-template>
  </xsl:template>
  
  <!-- object-in-array -->
  <xsl:template match='Translation |
                       TermSet'>
    <xsl:param name='indent' select='""'/>
    
    <xsl:call-template name='object-in-array'>
      <xsl:with-param name='indent' select='$indent'/>
    </xsl:call-template>
  </xsl:template>
  
  <!-- simple-obj-in-array -->
  <xsl:template match='PhraseNotFound |
                       FieldNotFound'>
    <xsl:param name='indent' select='""'/>
    
    <xsl:call-template name='simple-obj-in-array'>
      <xsl:with-param name='indent' select='$indent'/>
    </xsl:call-template>
  </xsl:template>
  
  <!-- 
    For the TranslationStack, just for fun, I took on the challenge of converting it
    into a JSON tree structure.  The stack is a sequence of TermSet objects and 
    binary operators, in reverse-polish notation.  It is tricky to convert this into
    a tree structure, using recursion within XSLT.
    
    This is experimental, not thoroughly tested, and optional.  Just set the 
    $parse-translation-stack parameter (at the top) to
    false() to turn this off, in which case it will be treated as a run-of-the-mill
    array.
  -->
  <xsl:template match='TranslationStack'>
    <xsl:param name='indent' select='""'/>
    
    <xsl:choose>
      <xsl:when test='$parse-translation-stack'>
        <xsl:value-of select='$indent'/>
        <xsl:text>"translationstack": </xsl:text>
        <xsl:value-of select='$nl'/>
        <xsl:call-template name='term-tree'>
          <xsl:with-param name='indent' select='concat($indent, $iu)'/>
          <xsl:with-param name='elems' select='*'/>
          <xsl:with-param name='trailing-comma' select='position() != last()'/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name='array-in-object'>
          <xsl:with-param name='indent' select='$indent'/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- term-tree is the entry point for the recursion.  It prints out one node of
      the tree.  When the $elems is a single TermSet, it prints it as a JSON object.
      When it is a list, with an operator at the end, it prints it as an array of
      three elements, e.g.,   [ "AND", { ... }, { ... } ]
  -->
  <xsl:template name='term-tree'>
    <xsl:param name='indent' select='""'/>
    <xsl:param name='elems'/>
    <xsl:param name='trailing-comma' select='false()'/>
    
    <xsl:variable name='numelems' select='count($elems)'/>
    <xsl:variable name='lastelem' select='$elems[last()]'/>

    <xsl:choose>
      <!-- If there's only one element, it better be a TermSet.  Render this
        as an object inside an array.  -->
      <xsl:when test='$numelems = 1'>
        <xsl:for-each select='$elems[1]'>
          <xsl:call-template name='object-in-array'>
            <xsl:with-param name='indent' select='$indent'/>
            <xsl:with-param name='force-comma' select='$trailing-comma'/>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:when>
      
      <!-- We ignore the "GROUP" operator - not sure what it is for. -->
      <xsl:when test='$lastelem[self::OP] and string($lastelem) = "GROUP"'>
        <xsl:call-template name='term-tree'>
          <xsl:with-param name='indent' select='$indent'/>
          <xsl:with-param name='elems' select='$elems[position() &lt; last()]'/>
          <xsl:with-param name='trailing-comma' select='$trailing-comma'/>
        </xsl:call-template>
      </xsl:when>
      
      <!-- If the last thing on the stack is a binary operator, then put out
          an array. -->
      <xsl:when test='$lastelem[self::OP]'>
        <xsl:value-of select='$indent'/>
        <xsl:value-of select='concat(
            "[", $nl, $indent, $iu, np:dq($lastelem), ",", $nl
        )'/>
        
        <!-- Count how many elements compose the second of my operands -->
        <xsl:variable name='num-top-elems'>
          <xsl:call-template name='count-top-elems'>
            <xsl:with-param name='elems' 
                select='$elems[position() &lt; last()]'/>
          </xsl:call-template>
        </xsl:variable>

        <!-- Recurse for the first operand.  -->
        <xsl:call-template name='term-tree'>
          <xsl:with-param name='indent' select='concat($indent, $iu)'/>
          <xsl:with-param name='elems'
              select='$elems[position() &lt; $numelems - $num-top-elems]'/>
          <xsl:with-param name='trailing-comma' select='true()'/>
        </xsl:call-template>

        <!-- Recurse for the second operand. -->
        <xsl:call-template name='term-tree'>
          <xsl:with-param name='indent' select='concat($indent, $iu)'/>
          <xsl:with-param name='elems'
              select='$elems[position() >= $numelems - $num-top-elems and position() &lt; last()]'/>
        </xsl:call-template>
        <xsl:value-of select='concat($indent, "]")'/>
        <xsl:if test='$trailing-comma'>,</xsl:if>
        <xsl:value-of select='$nl'/>
      </xsl:when>
      <xsl:otherwise>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- This template just counts the number of XML elements that make up the
      branch of the term tree at the top of the stack (counting backwards
      from the end). -->
  <xsl:template name='count-top-elems'>
    <xsl:param name='elems'/>
    <xsl:choose>
      <!-- If the thing on top is a TermSet, then the answer is 1. -->
      <xsl:when test='$elems[last()][self::TermSet]'>1</xsl:when>
      
      <!-- If the top is the "GROUP" OP, then pop it off and recurse.
        Basically, the "GROUP" operator is ignored.  -->
      <xsl:when test='$elems[last()][self::OP][.="GROUP"]'>
        <xsl:variable name='num-top-elems'>
          <xsl:call-template name='count-top-elems'>
            <xsl:with-param name='elems'
                select='$elems[position() &lt; last()]'/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select='1 + $num-top-elems'/>
      </xsl:when>
      
      <!-- Otherwise the top is a binary OP, such as "OR", "AND", or
          "RANGE".  -->
      <xsl:otherwise>
        <xsl:variable name='num-top-elems'>
          <xsl:call-template name='count-top-elems'>
            <xsl:with-param name='elems'
                select='$elems[position() &lt; last()]'/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name='num-next-elems'>
          <xsl:call-template name='count-top-elems'>
            <xsl:with-param name='elems'
                  select='$elems[position() &lt; last() - $num-top-elems]'/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select='1 + $num-top-elems + $num-next-elems'/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--============================================================
    ESummary protein
  -->

  <!-- simple-in-object -->
  <xsl:template match='Caption |
                       Extra |
                       Gi |
                       CreateDate |
                       UpdateDate |
                       Flags |
                       TaxId |
                       Slen |
                       Biomol |
                       MolType |
                       Topology |
                       SourceDb |
                       SegSetSize |
                       ProjectId |
                       Genome |
                       SubType |
                       SubName |
                       AssemblyGi |
                       AssemblyAcc |
                       Tech |
                       Completeness |
                       GeneticCode |
                       Strand |
                       Organism |
                       Stat/@count |
                       Stat/@subtype |
                       Stat/@value |
                       Stat/@source |
                       Stat/@type |
                       Properties/@na |
                       Properties/@aa |
                       Properties/@est |
                       Properties/@gss |
                       Properties/@trace |
                       Properties/@qual |
                       Properties/@genome |
                       Properties/@popset |
                       Properties/text() |
                       OSLT/@indexed |
                       OSLT/text() |
                       AccessionVersion'>
    <xsl:param name='indent' select='""'/>
    
    <xsl:call-template name='simple-in-object'>
      <xsl:with-param name="indent" select='$indent'/>
    </xsl:call-template>
  </xsl:template>

  <!-- array-in-object -->
  <xsl:template match='Statistics'>
    <xsl:param name='indent' select='""'/>
    
    <xsl:call-template name='array-in-object'>
      <xsl:with-param name='indent' select='$indent'/>
    </xsl:call-template>
  </xsl:template>

  <!-- Stat - special object-in-array -->
  <xsl:template match='Stat'>
    <xsl:param name='indent' select='""'/>
    
    <xsl:value-of select='$indent'/>
    <xsl:text>{</xsl:text>
    <xsl:value-of select='$nl'/>
    <xsl:apply-templates select='@*'>
      <xsl:with-param name='indent' select='concat($indent, $iu)'/>
      <xsl:with-param name='context' select='"object"'/>
    </xsl:apply-templates>
    <xsl:value-of select='$indent'/>
    <xsl:text>}</xsl:text>
    <xsl:if test='position() != last()'>,</xsl:if>
    <xsl:value-of select='$nl'/>
  </xsl:template>
  
  <!-- Properties, OSLT - special object-in-object -->
  <xsl:template match="Properties |
                       OSLT">
    <xsl:param name='indent' select='""'/>
    <xsl:param name='key' select='np:to-lower(name(.))'/>
    
    <xsl:value-of select='$indent'/>
    <xsl:value-of select="np:dq($key)"/>
    <xsl:text>: {</xsl:text>
    <xsl:value-of select='$nl'/>
    <xsl:apply-templates select='@*|text()'>
      <xsl:with-param name='indent' select='concat($indent, $iu)'/>
      <xsl:with-param name='context' select='"object"'/>
    </xsl:apply-templates>
    <xsl:value-of select='$indent'/>
    <xsl:text>}</xsl:text>
    <xsl:if test='position() != last()'>,</xsl:if>
    <xsl:value-of select='$nl'/>
  </xsl:template>
  
  <!--====================================================================
    EFetch PubMed
  -->
  <xsl:template match='PubmedArticleSet'>
    <xsl:call-template name='result-start'/>
    <xsl:value-of select='concat($iu, np:dq("articles"), ": [", $nl)'/>
    <xsl:apply-templates select='*'>
      <xsl:with-param name='indent' select='$iu2'/>
      <xsl:with-param name='context' select='"object"'/>
    </xsl:apply-templates>
    <xsl:value-of select='concat($iu, "]", $nl, "}")'/>
  </xsl:template>
  
  <!-- simple-in-object -->
  <xsl:template match='MedlineCitation/@Owner |
                       MedlineCitation/@Status |
                       PMID/@Version |
                       PMID/text() |
                       ISSN/@IssnType |
                       ISSN/text() |
                       Year |
                       Month |
                       Day |
                       Article/@PubModel |
                       JournalIssue/@CitedMedium |
                       ISOAbbreviation |
                       ArticleTitle |
                       StartPage |
                       EndPage |
                       MedlinePgn |
                       AbstractText |
                       CopyrightInformation |
                       Affiliation |
                       LastName |
                       ForeName |
                       Initials |
                       Author/@ValidYN |
                       Language |
                       Agency |
                       Country |
                       ArticleDate/@DateType |
                       MedlineTA |
                       ISSNLinking |
                       CitationSubset |
                       CommentsCorrections/@RefType |
                       RefSource |
                       DescriptorName/@MajorTopicYN |
                       DescriptorName/text() |
                       QualifierName/@MajorTopicYN |
                       QualifierName/text() |
                       OtherID/@Source |
                       OtherID/text() |
                       PubMedPubDate/@PubStatus |
                       Hour |
                       Minute |
                       PublicationStatus |
                       ArticleId/@IdType |
                       ArticleId/text() |
                       RegistryNumber |
                       NameOfSubstance'>
    <xsl:param name='indent' select='""'/>
    
    <xsl:call-template name='simple-in-object'>
      <xsl:with-param name='indent' select='$indent'/>
    </xsl:call-template>
  </xsl:template> 

  <!-- simple-in-array -->
  <xsl:template match='PublicationType'>
    <xsl:param name='indent' select='""'/>
    
    <xsl:call-template name='simple-in-array'>
      <xsl:with-param name='indent' select='$indent'/>
    </xsl:call-template>
  </xsl:template>
  
  
  <!-- array-in-object -->
  <xsl:template match='AuthorList |
                       GrantList |
                       PublicationTypeList |
                       CommentsCorrectionsList |
                       MeshHeadingList |
                       ArticleIdList |
                       ChemicalList'>
    <xsl:param name='indent' select='""'/>
    
    <xsl:call-template name='array-in-object'>
      <xsl:with-param name='indent' select='$indent'/>
    </xsl:call-template>
  </xsl:template>
  
  <!-- object-in-array -->
  <xsl:template match='PubmedArticle |
                       Grant |
                       CommentsCorrections |
                       MeshHeading |
                       Chemical'>
    <xsl:param name='indent' select='""'/>
    
    <xsl:call-template name='object-in-array'>
      <xsl:with-param name='indent' select='$indent'/>
    </xsl:call-template>
  </xsl:template>
  
  <!-- object-in-object -->
  <xsl:template match='MedlineCitation |
                       DateCreated |
                       DateCompleted |
                       DateRevised |
                       Article |
                       Journal |
                       JournalIssue |
                       PubDate |
                       Pagination |
                       Abstract |
                       ArticleDate |
                       MedlineJournalInfo |
                       PubmedData'>
    <xsl:param name='indent' select='""'/>

    <xsl:call-template name='object-in-object'>
      <xsl:with-param name='indent' select='$indent'/>
    </xsl:call-template>
  </xsl:template>

  <!-- object-in-object with significant text node children -->
  <xsl:template match='PMID |
                       ISSN |
                       DescriptorName |
                       QualifierName |
                       OtherID'>
    <xsl:param name='indent' select='""'/>
    
    <xsl:call-template name='object-in-object'>
      <xsl:with-param name='indent' select='$indent'/>
      <xsl:with-param name='kids' select='@*|text()'/>
    </xsl:call-template>
  </xsl:template>

  <!-- object-in-array with significant text node children -->
  <xsl:template match='ArticleId'>
    <xsl:param name='indent' select='""'/>
    
    <xsl:call-template name='object-in-array'>
      <xsl:with-param name='indent' select='$indent'/>
      <xsl:with-param name='kids' select='@*|text()'/>
    </xsl:call-template>
  </xsl:template>
  
  
</xsl:stylesheet>
