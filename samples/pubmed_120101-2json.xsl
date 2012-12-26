<?xml version="1.0" encoding="UTF-8"?>
<x:stylesheet xmlns:np="http://ncbi.gov/portal/XSLT/namespace"
              xmlns:x="http://www.w3.org/1999/XSL/Transform"
              xmlns:xs="http://www.w3.org/2001/XMLSchema"
              version="1.0">
   <x:import href="xml2json.xsl"/>
   <x:import href="efetch.pubmed.xsl"/>
   <x:output method="text"
             version="1.0"
             encoding="UTF-8"
             indent="yes"
             omit-xml-declaration="yes"/>
   <x:param name="pretty" select="true()"/>
   <x:param name="lcnames" select="true()"/>
   <x:template match="PubMedPubDate | Chemical | DataBank | PersonalNameSubject | ContributionDate | DateRevised | Publisher | CommentsCorrections | PubmedArticle | BeginningDate | Grant | PubmedData | EndingDate | PubmedBookData | Journal | MedlineJournalInfo | DateCreated | ArticleDate | JournalIssue | DateCompleted | PubmedBookArticle">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:param name="trailing-comma" select="position() != last()"/>
      <x:call-template name="object">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
         <x:with-param name="trailing-comma" select="$trailing-comma"/>
      </x:call-template>
   </x:template>
   <x:template match="LastName | Issue | CopyrightInformation | Country | MedlineTA | Second | EndPage | ForeName | ISSNLinking | ISOAbbreviation | CitationSubset | Volume | Note | Title | RegistryNumber | RefSource | Hour | Edition | Minute | DataBankName | MedlinePgn | MedlineDate | Language | Isbn | NlmUniqueID | Month | ReportNumber | NumberOfReferences | Season | GrantID | Acronym | PublisherLocation | StartPage | AccessionNumber | Agency | SpaceFlightMission | Day | Year | NameOfSubstance | PublicationType | Medium | PublicationStatus | GeneSymbol | Initials | @IssnType | @VersionID | @RefType | @DateType | @VersionDate | @NlmCategory | @PubModel | @CitedMedium | @EIdType | @Label | @part | @PubStatus | @Version | @Source | @Type | @lang | @Owner | @IdType | @Name | @Status | @sec | @book">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:param name="trailing-comma" select="position() != last()"/>
      <x:call-template name="string">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
         <x:with-param name="trailing-comma" select="$trailing-comma"/>
      </x:call-template>
   </x:template>
   <x:template match="BookDocument">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>

      <!--json annotation for content model: object-->
      <x:choose>
         <x:when test="$context = &#34;array&#34;">
            <x:value-of select="np:start-object(concat($indent, $iu0))"/>
         </x:when>
         <x:otherwise>
            <x:variable name="key" select="np:to-lower(name(.))"/>
            <x:value-of select="np:key-start-object(concat($indent, $iu0), $key)"/>
         </x:otherwise>
      </x:choose>

      <!--json annotation for content model: 'members'-->
      <x:apply-templates select="PMID | ArticleIdList | Book | ArticleTitle | VernacularTitle |                      Pagination | GroupList | Abstract | Sections |                       ContributionDate | DateRevised | CitationString | GrantList">
         <x:with-param name="indent" select="concat($indent, $iu1)"/>
         <x:with-param name="context" select="&#34;object&#34;"/>
         <x:with-param name="trailing-comma" select="true()"/>
      </x:apply-templates>

      <!--json annotation for content model: 'array'-->
      <x:value-of select="np:key-start-array(concat($indent, $iu1), &#34;locationlabels&#34;)"/>
      <x:apply-templates select="LocationLabel">
         <x:with-param name="indent" select="concat($indent, $iu1, $iu)"/>
         <x:with-param name="context" select="&#34;array&#34;"/>
      </x:apply-templates>
      <x:value-of select="np:end-array(concat($indent, $iu1), true())"/>
      <!-- done: 'array' -->

<!--json annotation for content model: 'array'-->
      <x:value-of select="np:key-start-array(concat($indent, $iu1), &#34;languages&#34;)"/>
      <x:apply-templates select="Language">
         <x:with-param name="indent" select="concat($indent, $iu1, $iu)"/>
         <x:with-param name="context" select="&#34;array&#34;"/>
      </x:apply-templates>
      <x:value-of select="np:end-array(concat($indent, $iu1), true())"/>
      <!-- done: 'array' -->

<!--json annotation for content model: 'array'-->
      <x:value-of select="np:key-start-array(concat($indent, $iu1), &#34;authorlists&#34;)"/>
      <x:apply-templates select="AuthorList">
         <x:with-param name="indent" select="concat($indent, $iu1, $iu)"/>
         <x:with-param name="context" select="&#34;array&#34;"/>
      </x:apply-templates>
      <x:value-of select="np:end-array(concat($indent, $iu1), true())"/>
      <!-- done: 'array' -->

<!--json annotation for content model: 'array'-->
      <x:value-of select="np:key-start-array(concat($indent, $iu1), &#34;publicationtypes&#34;)"/>
      <x:apply-templates select="PublicationType">
         <x:with-param name="indent" select="concat($indent, $iu1, $iu)"/>
         <x:with-param name="context" select="&#34;array&#34;"/>
      </x:apply-templates>
      <x:value-of select="np:end-array(concat($indent, $iu1), true())"/>
      <!-- done: 'array' -->

<!--json annotation for content model: 'array'-->
      <x:value-of select="np:key-start-array(concat($indent, $iu1), &#34;keywordlists&#34;)"/>
      <x:apply-templates select="KeywordList">
         <x:with-param name="indent" select="concat($indent, $iu1, $iu)"/>
         <x:with-param name="context" select="&#34;array&#34;"/>
      </x:apply-templates>
      <x:value-of select="np:end-array(concat($indent, $iu1), false())"/>
      <!-- done: 'array' --><x:value-of select="np:end-object(concat($indent, $iu0),  position() != last())"/>
      <!-- done: 'object' --></x:template>
   <x:template match="PersonalNameSubjectList | InvestigatorList | PubDate | ChemicalList | Pagination | ArticleIdList | AccessionNumberList | Sections | ObjectList | CommentsCorrectionsList | GeneSymbolList | History | SupplMeshList | PublicationTypeList | MeshHeadingList">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:param name="trailing-comma" select="position() != last()"/>
      <x:call-template name="array">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
         <x:with-param name="trailing-comma" select="$trailing-comma"/>
      </x:call-template>
   </x:template>
   <x:template match="MedlineCitation">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>

      <!--json annotation for content model: object-->
      <x:choose>
         <x:when test="$context = &#34;array&#34;">
            <x:value-of select="np:start-object(concat($indent, $iu0))"/>
         </x:when>
         <x:otherwise>
            <x:variable name="key" select="np:to-lower(name(.))"/>
            <x:value-of select="np:key-start-object(concat($indent, $iu0), $key)"/>
         </x:otherwise>
      </x:choose>

      <!--json annotation for content model: 'members'-->
      <x:apply-templates select="PMID | DateCreated | DateCompleted | DateRevised |                      Article | MedlineJournalInfo | ChemicalList |                       SupplMeshList | CommentsCorrectionsList | GeneSymbolList |                      MeshHeadingList | NumberOfReferences |                      PersonalNameSubjectList | InvestigatorList">
         <x:with-param name="indent" select="concat($indent, $iu1)"/>
         <x:with-param name="context" select="&#34;object&#34;"/>
         <x:with-param name="trailing-comma" select="true()"/>
      </x:apply-templates>

      <!--json annotation for content model: 'array'-->
      <x:value-of select="np:key-start-array(concat($indent, $iu1), &#34;citationsubsets&#34;)"/>
      <x:apply-templates select="CitationSubset">
         <x:with-param name="indent" select="concat($indent, $iu1, $iu)"/>
         <x:with-param name="context" select="&#34;array&#34;"/>
      </x:apply-templates>
      <x:value-of select="np:end-array(concat($indent, $iu1), true())"/>
      <!-- done: 'array' -->

<!--json annotation for content model: 'array'-->
      <x:value-of select="np:key-start-array(concat($indent, $iu1), &#34;otherids&#34;)"/>
      <x:apply-templates select="OtherID">
         <x:with-param name="indent" select="concat($indent, $iu1, $iu)"/>
         <x:with-param name="context" select="&#34;array&#34;"/>
      </x:apply-templates>
      <x:value-of select="np:end-array(concat($indent, $iu1), true())"/>
      <!-- done: 'array' -->

<!--json annotation for content model: 'array'-->
      <x:value-of select="np:key-start-array(concat($indent, $iu1), &#34;otherabstracts&#34;)"/>
      <x:apply-templates select="OtherAbstract">
         <x:with-param name="indent" select="concat($indent, $iu1, $iu)"/>
         <x:with-param name="context" select="&#34;array&#34;"/>
      </x:apply-templates>
      <x:value-of select="np:end-array(concat($indent, $iu1), true())"/>
      <!-- done: 'array' -->

<!--json annotation for content model: 'array'-->
      <x:value-of select="np:key-start-array(concat($indent, $iu1), &#34;keywordlists&#34;)"/>
      <x:apply-templates select="KeywordList">
         <x:with-param name="indent" select="concat($indent, $iu1, $iu)"/>
         <x:with-param name="context" select="&#34;array&#34;"/>
      </x:apply-templates>
      <x:value-of select="np:end-array(concat($indent, $iu1), true())"/>
      <!-- done: 'array' -->

<!--json annotation for content model: 'array'-->
      <x:value-of select="np:key-start-array(concat($indent, $iu1), &#34;spaceflightmissions&#34;)"/>
      <x:apply-templates select="SpaceFlightMission">
         <x:with-param name="indent" select="concat($indent, $iu1, $iu)"/>
         <x:with-param name="context" select="&#34;array&#34;"/>
      </x:apply-templates>
      <x:value-of select="np:end-array(concat($indent, $iu1), true())"/>
      <!-- done: 'array' -->

<!--json annotation for content model: 'array'-->
      <x:value-of select="np:key-start-array(concat($indent, $iu1), &#34;generalnotes&#34;)"/>
      <x:apply-templates select="GeneralNote">
         <x:with-param name="indent" select="concat($indent, $iu1, $iu)"/>
         <x:with-param name="context" select="&#34;array&#34;"/>
      </x:apply-templates>
      <x:value-of select="np:end-array(concat($indent, $iu1), false())"/>
      <!-- done: 'array' --><x:value-of select="np:end-object(concat($indent, $iu0),  position() != last())"/>
      <!-- done: 'object' --></x:template>
   <x:template match="DataBankList | AuthorList | Object | GrantList">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>

      <!--json annotation for content model: 'array'-->
      <x:choose>
         <x:when test="$context = &#34;array&#34;">
            <x:value-of select="np:start-array(concat($indent, $iu0))"/>
         </x:when>
         <x:otherwise>
            <x:variable name="key" select="np:to-lower(name(.))"/>
            <x:value-of select="np:key-start-array(concat($indent, $iu0), $key)"/>
         </x:otherwise>
      </x:choose>

      <!--json annotation for content model: object-->
      <x:value-of select="np:start-object(concat($indent, $iu1))"/>
      <x:apply-templates select="@*">
         <x:with-param name="indent" select="concat($indent, $iu1, $iu)"/>
         <x:with-param name="context" select="&#34;object&#34;"/>
      </x:apply-templates>
      <x:value-of select="np:end-object(concat($indent, $iu1),  true())"/>
      <!-- done: 'object' -->

<!--json annotation for content model: 'members'-->
      <x:apply-templates select="*">
         <x:with-param name="indent" select="concat($indent, $iu1)"/>
         <x:with-param name="context" select="&#34;array&#34;"/>
      </x:apply-templates>
      <x:value-of select="np:end-array(concat($indent, $iu0), position() != last())"/>
      <!-- done: 'array' --></x:template>
   <x:template match="Book">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>

      <!--json annotation for content model: object-->
      <x:choose>
         <x:when test="$context = &#34;array&#34;">
            <x:value-of select="np:start-object(concat($indent, $iu0))"/>
         </x:when>
         <x:otherwise>
            <x:variable name="key" select="np:to-lower(name(.))"/>
            <x:value-of select="np:key-start-object(concat($indent, $iu0), $key)"/>
         </x:otherwise>
      </x:choose>

      <!--json annotation for content model: 'members'-->
      <x:apply-templates select="Publisher | BookTitle | PubDate | BeginningDate | EndingDate | Volume |                      VolumeTitle | Edition | CollectionTitle | Medium | ReportNumber">
         <x:with-param name="indent" select="concat($indent, $iu1)"/>
         <x:with-param name="context" select="&#34;object&#34;"/>
         <x:with-param name="trailing-comma" select="true()"/>
      </x:apply-templates>

      <!--json annotation for content model: 'array'-->
      <x:value-of select="np:key-start-array(concat($indent, $iu1), &#34;authorlists&#34;)"/>
      <x:apply-templates select="AuthorList">
         <x:with-param name="indent" select="concat($indent, $iu1, $iu)"/>
         <x:with-param name="context" select="&#34;array&#34;"/>
      </x:apply-templates>
      <x:value-of select="np:end-array(concat($indent, $iu1), true())"/>
      <!-- done: 'array' -->

<!--json annotation for content model: 'array'-->
      <x:value-of select="np:key-start-array(concat($indent, $iu1), &#34;isbn&#34;)"/>
      <x:apply-templates select="Isbn">
         <x:with-param name="indent" select="concat($indent, $iu1, $iu)"/>
         <x:with-param name="context" select="&#34;array&#34;"/>
      </x:apply-templates>
      <x:value-of select="np:end-array(concat($indent, $iu1), true())"/>
      <!-- done: 'array' -->

<!--json annotation for content model: 'array'-->
      <x:value-of select="np:key-start-array(concat($indent, $iu1), &#34;elocationid&#34;)"/>
      <x:apply-templates select="ELocationID">
         <x:with-param name="indent" select="concat($indent, $iu1, $iu)"/>
         <x:with-param name="context" select="&#34;array&#34;"/>
      </x:apply-templates>
      <x:value-of select="np:end-array(concat($indent, $iu1), false())"/>
      <!-- done: 'array' --><x:value-of select="np:end-object(concat($indent, $iu0),  position() != last())"/>
      <!-- done: 'object' --></x:template>
   <x:template match="OtherID | LocationLabel | SupplMeshName | NameID | DescriptorName | Param | ELocationID | GeneralNote | PMID | ArticleId | ISSN | QualifierName">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:param name="trailing-comma" select="position() != last()"/>
      <x:call-template name="object">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
         <x:with-param name="kids" select="@*|node()"/>
         <x:with-param name="trailing-comma" select="$trailing-comma"/>
      </x:call-template>
   </x:template>
   <x:template match="OtherID/text()">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:call-template name="string">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
      </x:call-template>
   </x:template>
   <x:template match="LocationLabel/text()">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:call-template name="string">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
      </x:call-template>
   </x:template>
   <x:template match="SupplMeshName/text()">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:call-template name="string">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
      </x:call-template>
   </x:template>
   <x:template match="NameID/text()">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:call-template name="string">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
      </x:call-template>
   </x:template>
   <x:template match="DescriptorName/text()">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:call-template name="string">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
      </x:call-template>
   </x:template>
   <x:template match="Param/text()">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:call-template name="string">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
      </x:call-template>
   </x:template>
   <x:template match="ELocationID/text()">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:call-template name="string">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
      </x:call-template>
   </x:template>
   <x:template match="GeneralNote/text()">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:call-template name="string">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
      </x:call-template>
   </x:template>
   <x:template match="PMID/text()">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:call-template name="string">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
      </x:call-template>
   </x:template>
   <x:template match="ArticleId/text()">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:call-template name="string">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
      </x:call-template>
   </x:template>
   <x:template match="ISSN/text()">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:call-template name="string">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
      </x:call-template>
   </x:template>
   <x:template match="QualifierName/text()">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:call-template name="string">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
      </x:call-template>
   </x:template>
   <x:template match="Author | Investigator">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>

      <!--json annotation for content model: object-->
      <x:choose>
         <x:when test="$context = &#34;array&#34;">
            <x:value-of select="np:start-object(concat($indent, $iu0))"/>
         </x:when>
         <x:otherwise>
            <x:variable name="key" select="np:to-lower(name(.))"/>
            <x:value-of select="np:key-start-object(concat($indent, $iu0), $key)"/>
         </x:otherwise>
      </x:choose>

      <!--json annotation for content model: 'members'-->
      <x:apply-templates select="@*|*[not(self::NameID)]">
         <x:with-param name="indent" select="concat($indent, $iu1)"/>
         <x:with-param name="context" select="&#34;object&#34;"/>
         <x:with-param name="trailing-comma" select="true()"/>
      </x:apply-templates>

      <!--json annotation for content model: 'array'-->
      <x:value-of select="np:key-start-array(concat($indent, $iu1), &#34;nameids&#34;)"/>
      <x:apply-templates select="NameID">
         <x:with-param name="indent" select="concat($indent, $iu1, $iu)"/>
         <x:with-param name="context" select="&#34;array&#34;"/>
      </x:apply-templates>
      <x:value-of select="np:end-array(concat($indent, $iu1), false())"/>
      <!-- done: 'array' --><x:value-of select="np:end-object(concat($indent, $iu0),  position() != last())"/>
      <!-- done: 'object' --></x:template>
   <x:template match="MeshHeading">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>

      <!--json annotation for content model: object-->
      <x:choose>
         <x:when test="$context = &#34;array&#34;">
            <x:value-of select="np:start-object(concat($indent, $iu0))"/>
         </x:when>
         <x:otherwise>
            <x:variable name="key" select="np:to-lower(name(.))"/>
            <x:value-of select="np:key-start-object(concat($indent, $iu0), $key)"/>
         </x:otherwise>
      </x:choose>

      <!--json annotation for content model: 'members'-->
      <x:apply-templates select="DescriptorName">
         <x:with-param name="indent" select="concat($indent, $iu1)"/>
         <x:with-param name="context" select="&#34;object&#34;"/>
         <x:with-param name="trailing-comma" select="true()"/>
      </x:apply-templates>

      <!--json annotation for content model: 'array'-->
      <x:value-of select="np:key-start-array(concat($indent, $iu1), &#34;qualifiernames&#34;)"/>
      <x:apply-templates select="QualifierName">
         <x:with-param name="indent" select="concat($indent, $iu1, $iu)"/>
         <x:with-param name="context" select="&#34;array&#34;"/>
      </x:apply-templates>
      <x:value-of select="np:end-array(concat($indent, $iu1), false())"/>
      <!-- done: 'array' --><x:value-of select="np:end-object(concat($indent, $iu0),  position() != last())"/>
      <!-- done: 'object' --></x:template>
   <x:template match="Article">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>

      <!--json annotation for content model: object-->
      <x:choose>
         <x:when test="$context = &#34;array&#34;">
            <x:value-of select="np:start-object(concat($indent, $iu0))"/>
         </x:when>
         <x:otherwise>
            <x:variable name="key" select="np:to-lower(name(.))"/>
            <x:value-of select="np:key-start-object(concat($indent, $iu0), $key)"/>
         </x:otherwise>
      </x:choose>

      <!--json annotation for content model: 'members'-->
      <x:apply-templates select="Journal | ArticleTitle | Pagination | Abstract | Affiliation |                      AuthorList | DataBankList | GrantList |                      PublicationTypeList | VernacularTitle">
         <x:with-param name="indent" select="concat($indent, $iu1)"/>
         <x:with-param name="context" select="&#34;object&#34;"/>
         <x:with-param name="trailing-comma" select="true()"/>
      </x:apply-templates>

      <!--json annotation for content model: 'array'-->
      <x:value-of select="np:key-start-array(concat($indent, $iu1), &#34;elocationids&#34;)"/>
      <x:apply-templates select="ELocationID">
         <x:with-param name="indent" select="concat($indent, $iu1, $iu)"/>
         <x:with-param name="context" select="&#34;array&#34;"/>
      </x:apply-templates>
      <x:value-of select="np:end-array(concat($indent, $iu1), true())"/>
      <!-- done: 'array' -->

<!--json annotation for content model: 'array'-->
      <x:value-of select="np:key-start-array(concat($indent, $iu1), &#34;languages&#34;)"/>
      <x:apply-templates select="Language">
         <x:with-param name="indent" select="concat($indent, $iu1, $iu)"/>
         <x:with-param name="context" select="&#34;array&#34;"/>
      </x:apply-templates>
      <x:value-of select="np:end-array(concat($indent, $iu1), true())"/>
      <!-- done: 'array' -->

<!--json annotation for content model: 'array'-->
      <x:value-of select="np:key-start-array(concat($indent, $iu1), &#34;articledates&#34;)"/>
      <x:apply-templates select="ArticleDate">
         <x:with-param name="indent" select="concat($indent, $iu1, $iu)"/>
         <x:with-param name="context" select="&#34;array&#34;"/>
      </x:apply-templates>
      <x:value-of select="np:end-array(concat($indent, $iu1), false())"/>
      <!-- done: 'array' --><x:value-of select="np:end-object(concat($indent, $iu0),  position() != last())"/>
      <!-- done: 'object' --></x:template>
   <x:template match="Abstract">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>

      <!--json annotation for content model: object-->
      <x:choose>
         <x:when test="$context = &#34;array&#34;">
            <x:value-of select="np:start-object(concat($indent, $iu0))"/>
         </x:when>
         <x:otherwise>
            <x:variable name="key" select="np:to-lower(name(.))"/>
            <x:value-of select="np:key-start-object(concat($indent, $iu0), $key)"/>
         </x:otherwise>
      </x:choose>

      <!--json annotation for content model: 'members'-->
      <x:apply-templates select="CopyrightInformation">
         <x:with-param name="indent" select="concat($indent, $iu1)"/>
         <x:with-param name="context" select="&#34;object&#34;"/>
         <x:with-param name="trailing-comma" select="true()"/>
      </x:apply-templates>

      <!--json annotation for content model: 'array'-->
      <x:value-of select="np:key-start-array(concat($indent, $iu1), &#34;abstracttexts&#34;)"/>
      <x:apply-templates select="AbstractText">
         <x:with-param name="indent" select="concat($indent, $iu1, $iu)"/>
         <x:with-param name="context" select="&#34;array&#34;"/>
      </x:apply-templates>
      <x:value-of select="np:end-array(concat($indent, $iu1), false())"/>
      <!-- done: 'array' --><x:value-of select="np:end-object(concat($indent, $iu0),  position() != last())"/>
      <!-- done: 'object' --></x:template>
   <x:template match="KeywordList">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>

      <!--json annotation for content model: object-->
      <x:choose>
         <x:when test="$context = &#34;array&#34;">
            <x:value-of select="np:start-object(concat($indent, $iu0))"/>
         </x:when>
         <x:otherwise>
            <x:variable name="key" select="np:to-lower(name(.))"/>
            <x:value-of select="np:key-start-object(concat($indent, $iu0), $key)"/>
         </x:otherwise>
      </x:choose>

      <!--json annotation for content model: object-->
      <x:value-of select="np:key-start-object(concat($indent, $iu1), &#34;attrs&#34;)"/>
      <x:apply-templates select="@*">
         <x:with-param name="indent" select="concat($indent, $iu1, $iu)"/>
         <x:with-param name="context" select="&#34;object&#34;"/>
      </x:apply-templates>
      <x:value-of select="np:end-object(concat($indent, $iu1),  true())"/>
      <!-- done: 'object' -->

<!--json annotation for content model: object-->
      <x:value-of select="np:key-start-object(concat($indent, $iu1), &#34;keywords&#34;)"/>
      <x:apply-templates select="Keyword">
         <x:with-param name="indent" select="concat($indent, $iu1, $iu)"/>
         <x:with-param name="context" select="&#34;object&#34;"/>
      </x:apply-templates>
      <x:value-of select="np:end-object(concat($indent, $iu1),  false())"/>
      <!-- done: 'object' --><x:value-of select="np:end-object(concat($indent, $iu0),  position() != last())"/>
      <!-- done: 'object' --></x:template>
   <x:template match="OtherAbstract">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>

      <!--json annotation for content model: object-->
      <x:choose>
         <x:when test="$context = &#34;array&#34;">
            <x:value-of select="np:start-object(concat($indent, $iu0))"/>
         </x:when>
         <x:otherwise>
            <x:variable name="key" select="np:to-lower(name(.))"/>
            <x:value-of select="np:key-start-object(concat($indent, $iu0), $key)"/>
         </x:otherwise>
      </x:choose>

      <!--json annotation for content model: 'members'-->
      <x:apply-templates select="@*|CopyrightInformation">
         <x:with-param name="indent" select="concat($indent, $iu1)"/>
         <x:with-param name="context" select="&#34;object&#34;"/>
         <x:with-param name="trailing-comma" select="true()"/>
      </x:apply-templates>

      <!--json annotation for content model: 'array'-->
      <x:value-of select="np:key-start-array(concat($indent, $iu1), &#34;abstracttexts&#34;)"/>
      <x:apply-templates select="AbstractText">
         <x:with-param name="indent" select="concat($indent, $iu1, $iu)"/>
         <x:with-param name="context" select="&#34;array&#34;"/>
      </x:apply-templates>
      <x:value-of select="np:end-array(concat($indent, $iu1), false())"/>
      <!-- done: 'array' --><x:value-of select="np:end-object(concat($indent, $iu0),  position() != last())"/>
      <!-- done: 'object' --></x:template>
   <x:template match="Section">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>

      <!--json annotation for content model: object-->
      <x:choose>
         <x:when test="$context = &#34;array&#34;">
            <x:value-of select="np:start-object(concat($indent, $iu0))"/>
         </x:when>
         <x:otherwise>
            <x:variable name="key" select="np:to-lower(name(.))"/>
            <x:value-of select="np:key-start-object(concat($indent, $iu0), $key)"/>
         </x:otherwise>
      </x:choose>

      <!--json annotation for content model: 'members'-->
      <x:apply-templates select="LocationLabel | SectionTitle">
         <x:with-param name="indent" select="concat($indent, $iu1)"/>
         <x:with-param name="context" select="&#34;object&#34;"/>
         <x:with-param name="trailing-comma" select="true()"/>
      </x:apply-templates>

      <!--json annotation for content model: 'array'-->
      <x:value-of select="np:key-start-array(concat($indent, $iu1), &#34;sections&#34;)"/>
      <x:apply-templates select="Section">
         <x:with-param name="indent" select="concat($indent, $iu1, $iu)"/>
         <x:with-param name="context" select="&#34;array&#34;"/>
      </x:apply-templates>
      <x:value-of select="np:end-array(concat($indent, $iu1), false())"/>
      <!-- done: 'array' --><x:value-of select="np:end-object(concat($indent, $iu0),  position() != last())"/>
      <!-- done: 'object' --></x:template>
   <x:template match="@CompleteYN | @ValidYN | @MajorTopicYN">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:param name="trailing-comma" select="position() != last()"/>
      <x:call-template name="boolean">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
         <x:with-param name="trailing-comma" select="$trailing-comma"/>
      </x:call-template>
   </x:template>
</x:stylesheet>