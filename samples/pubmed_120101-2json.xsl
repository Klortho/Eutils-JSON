<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:np="http://ncbi.gov/portal/XSLT/namespace"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0"
                exclude-result-prefixes="np">
   <xsl:import href="xml2json.xsl"/>
   <xsl:import href="efetch.pubmed.xsl"/>
   <xsl:output method="text" encoding="UTF-8"/>
   <xsl:param name="pretty" select="true()"/>
   <xsl:param name="lcnames" select="true()"/>
   <xsl:param name="dtd-annotation">
      <json type="efetch.pubmed" version="0.3">
         <config lcnames="true" import="efetch.pubmed.xsl"/>
      </json>
   </xsl:param>
   <xsl:template match="PubMedPubDate | Chemical | DataBank | PersonalNameSubject | ContributionDate | DateRevised | Publisher | CommentsCorrections | PubmedArticle | BeginningDate | Grant | PubmedData | Object | EndingDate | PubmedBookData | Journal | MedlineJournalInfo | DateCreated | ArticleDate | JournalIssue | DateCompleted | PubmedBookArticle">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="o">
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="LastName | Issue | CopyrightInformation | Country | MedlineTA | Second | EndPage | ForeName | ISSNLinking | ISOAbbreviation | CitationSubset | Volume | Note | Title | RegistryNumber | RefSource | Hour | Edition | Minute | DataBankName | MedlinePgn | MedlineDate | Language | Isbn | NlmUniqueID | Month | ReportNumber | NumberOfReferences | Season | GrantID | Acronym | PublisherLocation | StartPage | AccessionNumber | Agency | SpaceFlightMission | Day | Year | NameOfSubstance | PublicationType | Medium | PublicationStatus | GeneSymbol | Initials | @IssnType | @VersionID | @RefType | @DateType | @VersionDate | @NlmCategory | @PubModel | @CitedMedium | @EIdType | @Label | @part | @PubStatus | @Version | @Source | @Type | @lang | @Owner | @IdType | @Name | @Status | @sec | @book">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="s">
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="BookDocument">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <!--Handling itemspec <o>-->
<o>
         <xsl:if test="$context = &#34;o&#34;">
            <xsl:attribute name="k">
               <xsl:value-of select="np:translate-name()"/>
            </xsl:attribute>
         </xsl:if>
         <!--Handling itemspec <m>-->
<xsl:apply-templates select="PMID | ArticleIdList | Book | ArticleTitle | VernacularTitle |                      Pagination | GroupList | Abstract | Sections |                       ContributionDate | DateRevised | CitationString | GrantList">
            <xsl:with-param name="context" select="'o'"/>
         </xsl:apply-templates>
         <!--Handling itemspec <a>-->
<a k="{&#34;locationlabels&#34;}">
            <xsl:apply-templates select="LocationLabel">
               <xsl:with-param name="context" select="&#34;a&#34;"/>
            </xsl:apply-templates>
         </a>
         <!--Handling itemspec <a>-->
<a k="{&#34;languages&#34;}">
            <xsl:apply-templates select="Language">
               <xsl:with-param name="context" select="&#34;a&#34;"/>
            </xsl:apply-templates>
         </a>
         <!--Handling itemspec <a>-->
<a k="{&#34;authorlists&#34;}">
            <xsl:apply-templates select="AuthorList">
               <xsl:with-param name="context" select="&#34;a&#34;"/>
            </xsl:apply-templates>
         </a>
         <!--Handling itemspec <a>-->
<a k="{&#34;publicationtypes&#34;}">
            <xsl:apply-templates select="PublicationType">
               <xsl:with-param name="context" select="&#34;a&#34;"/>
            </xsl:apply-templates>
         </a>
         <!--Handling itemspec <a>-->
<a k="{&#34;keywordlists&#34;}">
            <xsl:apply-templates select="KeywordList">
               <xsl:with-param name="context" select="&#34;a&#34;"/>
            </xsl:apply-templates>
         </a>
      </o>
   </xsl:template>
   <xsl:template match="PersonalNameSubjectList | InvestigatorList | PubDate | ChemicalList | Pagination | ArticleIdList | AccessionNumberList | Sections | ObjectList | CommentsCorrectionsList | GeneSymbolList | History | SupplMeshList | PublicationTypeList | MeshHeadingList">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="a">
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="MedlineCitation">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <!--Handling itemspec <o>-->
<o>
         <xsl:if test="$context = &#34;o&#34;">
            <xsl:attribute name="k">
               <xsl:value-of select="np:translate-name()"/>
            </xsl:attribute>
         </xsl:if>
         <!--Handling itemspec <m>-->
<xsl:apply-templates select="PMID | DateCreated | DateCompleted | DateRevised |                      Article | MedlineJournalInfo | ChemicalList |                       SupplMeshList | CommentsCorrectionsList | GeneSymbolList |                      MeshHeadingList | NumberOfReferences |                      PersonalNameSubjectList | InvestigatorList">
            <xsl:with-param name="context" select="'o'"/>
         </xsl:apply-templates>
         <!--Handling itemspec <a>-->
<a k="{&#34;citationsubsets&#34;}">
            <xsl:apply-templates select="CitationSubset">
               <xsl:with-param name="context" select="&#34;a&#34;"/>
            </xsl:apply-templates>
         </a>
         <!--Handling itemspec <a>-->
<a k="{&#34;otherids&#34;}">
            <xsl:apply-templates select="OtherID">
               <xsl:with-param name="context" select="&#34;a&#34;"/>
            </xsl:apply-templates>
         </a>
         <!--Handling itemspec <a>-->
<a k="{&#34;otherabstracts&#34;}">
            <xsl:apply-templates select="OtherAbstract">
               <xsl:with-param name="context" select="&#34;a&#34;"/>
            </xsl:apply-templates>
         </a>
         <!--Handling itemspec <a>-->
<a k="{&#34;keywordlists&#34;}">
            <xsl:apply-templates select="KeywordList">
               <xsl:with-param name="context" select="&#34;a&#34;"/>
            </xsl:apply-templates>
         </a>
         <!--Handling itemspec <a>-->
<a k="{&#34;spaceflightmissions&#34;}">
            <xsl:apply-templates select="SpaceFlightMission">
               <xsl:with-param name="context" select="&#34;a&#34;"/>
            </xsl:apply-templates>
         </a>
         <!--Handling itemspec <a>-->
<a k="{&#34;generalnotes&#34;}">
            <xsl:apply-templates select="GeneralNote">
               <xsl:with-param name="context" select="&#34;a&#34;"/>
            </xsl:apply-templates>
         </a>
      </o>
   </xsl:template>
   <xsl:template match="DataBankList | AuthorList | GrantList">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <!--Handling itemspec <a>-->
<a>
         <xsl:if test="$context = &#34;o&#34;">
            <xsl:attribute name="k">
               <xsl:value-of select="np:translate-name()"/>
            </xsl:attribute>
         </xsl:if>
         <!--Handling itemspec <o>-->
<o>
            <xsl:apply-templates select="@*">
               <xsl:with-param name="context" select="&#34;o&#34;"/>
            </xsl:apply-templates>
         </o>
         <!--Handling itemspec <m>-->
<xsl:apply-templates select="*">
            <xsl:with-param name="context" select="'a'"/>
         </xsl:apply-templates>
      </a>
   </xsl:template>
   <xsl:template match="Book">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <!--Handling itemspec <o>-->
<o>
         <xsl:if test="$context = &#34;o&#34;">
            <xsl:attribute name="k">
               <xsl:value-of select="np:translate-name()"/>
            </xsl:attribute>
         </xsl:if>
         <!--Handling itemspec <m>-->
<xsl:apply-templates select="Publisher | BookTitle | PubDate | BeginningDate | EndingDate | Volume |                      VolumeTitle | Edition | CollectionTitle | Medium | ReportNumber">
            <xsl:with-param name="context" select="'o'"/>
         </xsl:apply-templates>
         <!--Handling itemspec <a>-->
<a k="{&#34;authorlists&#34;}">
            <xsl:apply-templates select="AuthorList">
               <xsl:with-param name="context" select="&#34;a&#34;"/>
            </xsl:apply-templates>
         </a>
         <!--Handling itemspec <a>-->
<a k="{&#34;isbn&#34;}">
            <xsl:apply-templates select="Isbn">
               <xsl:with-param name="context" select="&#34;a&#34;"/>
            </xsl:apply-templates>
         </a>
         <!--Handling itemspec <a>-->
<a k="{&#34;elocationid&#34;}">
            <xsl:apply-templates select="ELocationID">
               <xsl:with-param name="context" select="&#34;a&#34;"/>
            </xsl:apply-templates>
         </a>
      </o>
   </xsl:template>
   <xsl:template match="OtherID | LocationLabel | SupplMeshName | NameID | DescriptorName | ELocationID | GeneralNote | PMID | ArticleId | ISSN | QualifierName">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="o">
         <xsl:with-param name="context" select="$context"/>
         <xsl:with-param name="kids" select="@*|node()"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="OtherID/text()">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="s">
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="LocationLabel/text()">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="s">
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="SupplMeshName/text()">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="s">
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="NameID/text()">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="s">
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="DescriptorName/text()">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="s">
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="ELocationID/text()">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="s">
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="GeneralNote/text()">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="s">
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="PMID/text()">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="s">
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="ArticleId/text()">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="s">
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="ISSN/text()">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="s">
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="QualifierName/text()">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="s">
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="Author | Investigator">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <!--Handling itemspec <o>-->
<o>
         <xsl:if test="$context = &#34;o&#34;">
            <xsl:attribute name="k">
               <xsl:value-of select="np:translate-name()"/>
            </xsl:attribute>
         </xsl:if>
         <!--Handling itemspec <m>-->
<xsl:apply-templates select="@*|*[not(self::NameID)]">
            <xsl:with-param name="context" select="'o'"/>
         </xsl:apply-templates>
         <!--Handling itemspec <a>-->
<a k="{&#34;nameids&#34;}">
            <xsl:apply-templates select="NameID">
               <xsl:with-param name="context" select="&#34;a&#34;"/>
            </xsl:apply-templates>
         </a>
      </o>
   </xsl:template>
   <xsl:template match="MeshHeading">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <!--Handling itemspec <o>-->
<o>
         <xsl:if test="$context = &#34;o&#34;">
            <xsl:attribute name="k">
               <xsl:value-of select="np:translate-name()"/>
            </xsl:attribute>
         </xsl:if>
         <!--Handling itemspec <m>-->
<xsl:apply-templates select="DescriptorName">
            <xsl:with-param name="context" select="'o'"/>
         </xsl:apply-templates>
         <!--Handling itemspec <a>-->
<a k="{&#34;qualifiernames&#34;}">
            <xsl:apply-templates select="QualifierName">
               <xsl:with-param name="context" select="&#34;a&#34;"/>
            </xsl:apply-templates>
         </a>
      </o>
   </xsl:template>
   <xsl:template match="Article">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <!--Handling itemspec <o>-->
<o>
         <xsl:if test="$context = &#34;o&#34;">
            <xsl:attribute name="k">
               <xsl:value-of select="np:translate-name()"/>
            </xsl:attribute>
         </xsl:if>
         <!--Handling itemspec <m>-->
<xsl:apply-templates select="Journal | ArticleTitle | Pagination | Abstract | Affiliation |                      AuthorList | DataBankList | GrantList |                      PublicationTypeList | VernacularTitle">
            <xsl:with-param name="context" select="'o'"/>
         </xsl:apply-templates>
         <!--Handling itemspec <a>-->
<a k="{&#34;elocationids&#34;}">
            <xsl:apply-templates select="ELocationID">
               <xsl:with-param name="context" select="&#34;a&#34;"/>
            </xsl:apply-templates>
         </a>
         <!--Handling itemspec <a>-->
<a k="{&#34;languages&#34;}">
            <xsl:apply-templates select="Language">
               <xsl:with-param name="context" select="&#34;a&#34;"/>
            </xsl:apply-templates>
         </a>
         <!--Handling itemspec <a>-->
<a k="{&#34;articledates&#34;}">
            <xsl:apply-templates select="ArticleDate">
               <xsl:with-param name="context" select="&#34;a&#34;"/>
            </xsl:apply-templates>
         </a>
      </o>
   </xsl:template>
   <xsl:template match="Abstract">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <!--Handling itemspec <o>-->
<o>
         <xsl:if test="$context = &#34;o&#34;">
            <xsl:attribute name="k">
               <xsl:value-of select="np:translate-name()"/>
            </xsl:attribute>
         </xsl:if>
         <!--Handling itemspec <m>-->
<xsl:apply-templates select="CopyrightInformation">
            <xsl:with-param name="context" select="'o'"/>
         </xsl:apply-templates>
         <!--Handling itemspec <a>-->
<a k="{&#34;abstracttexts&#34;}">
            <xsl:apply-templates select="AbstractText">
               <xsl:with-param name="context" select="&#34;a&#34;"/>
            </xsl:apply-templates>
         </a>
      </o>
   </xsl:template>
   <xsl:template match="KeywordList">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <!--Handling itemspec <o>-->
<o>
         <xsl:if test="$context = &#34;o&#34;">
            <xsl:attribute name="k">
               <xsl:value-of select="np:translate-name()"/>
            </xsl:attribute>
         </xsl:if>
         <!--Handling itemspec <o>-->
<o k="{&#34;attrs&#34;}">
            <xsl:apply-templates select="@*">
               <xsl:with-param name="context" select="&#34;o&#34;"/>
            </xsl:apply-templates>
         </o>
         <!--Handling itemspec <o>-->
<o k="{&#34;keywords&#34;}">
            <xsl:apply-templates select="Keyword">
               <xsl:with-param name="context" select="&#34;o&#34;"/>
            </xsl:apply-templates>
         </o>
      </o>
   </xsl:template>
   <xsl:template match="OtherAbstract">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <!--Handling itemspec <o>-->
<o>
         <xsl:if test="$context = &#34;o&#34;">
            <xsl:attribute name="k">
               <xsl:value-of select="np:translate-name()"/>
            </xsl:attribute>
         </xsl:if>
         <!--Handling itemspec <m>-->
<xsl:apply-templates select="@*|CopyrightInformation">
            <xsl:with-param name="context" select="'o'"/>
         </xsl:apply-templates>
         <!--Handling itemspec <a>-->
<a k="{&#34;abstracttexts&#34;}">
            <xsl:apply-templates select="AbstractText">
               <xsl:with-param name="context" select="&#34;a&#34;"/>
            </xsl:apply-templates>
         </a>
      </o>
   </xsl:template>
   <xsl:template match="Param">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="s">
         <xsl:with-param name="context" select="$context"/>
         <xsl:with-param name="k" select="@Name"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="PubmedArticleSet">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="a">
         <xsl:with-param name="context" select="$context"/>
         <xsl:with-param name="k" select="&#34;result&#34;"/>
         <xsl:with-param name="kids" select="PubmedArticle | PubmedBookArticle"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="Section">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <!--Handling itemspec <o>-->
<o>
         <xsl:if test="$context = &#34;o&#34;">
            <xsl:attribute name="k">
               <xsl:value-of select="np:translate-name()"/>
            </xsl:attribute>
         </xsl:if>
         <!--Handling itemspec <m>-->
<xsl:apply-templates select="LocationLabel | SectionTitle">
            <xsl:with-param name="context" select="'o'"/>
         </xsl:apply-templates>
         <!--Handling itemspec <a>-->
<a k="{&#34;sections&#34;}">
            <xsl:apply-templates select="Section">
               <xsl:with-param name="context" select="&#34;a&#34;"/>
            </xsl:apply-templates>
         </a>
      </o>
   </xsl:template>
   <xsl:template match="@CompleteYN | @ValidYN | @MajorTopicYN">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="b">
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
</xsl:stylesheet>