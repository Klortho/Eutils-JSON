<?xml version="1.0" encoding="UTF-8"?>
<x:stylesheet xmlns:np="http://ncbi.gov/portal/XSLT/namespace"
              xmlns:x="http://www.w3.org/1999/XSL/Transform"
              xmlns:xs="http://www.w3.org/2001/XMLSchema"
              version="1.0">
   <x:import href="xml2json.xsl"/>
   <x:output method="text"
             version="1.0"
             encoding="UTF-8"
             indent="yes"
             omit-xml-declaration="yes"/>
   <x:param name="lcnames" select="true()"/>
   <x:template match="AbstractText | PubMedPubDate | Chemical | DataBank | PersonalNameSubject | ContributionDate | DateRevised | Publisher | CommentsCorrections | PubmedArticle | BeginningDate | Grant | PubmedData | EndingDate | PubmedBookData | Journal | MedlineJournalInfo | DateCreated | ArticleDate | JournalIssue | DateCompleted | PubmedBookArticle">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:call-template name="object">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
      </x:call-template>
   </x:template>
   <x:template match="ArticleTitle | LastName | Issue | CopyrightInformation | Country | MedlineTA | Second | EndPage | ForeName | ISSNLinking | ISOAbbreviation | CitationSubset | Volume | Note | Title | RegistryNumber | RefSource | Hour | Edition | Minute | DataBankName | MedlinePgn | MedlineDate | Language | Isbn | NlmUniqueID | Month | ReportNumber | NumberOfReferences | Season | GrantID | Acronym | PublisherLocation | StartPage | AccessionNumber | Agency | SpaceFlightMission | Day | ContractNumber | Year | NameOfSubstance | PublicationType | Medium | PublicationStatus | GeneSymbol | Initials | @CompleteYN | @IssnType | @VersionID | @RefType | @DateType | @VersionDate | @NlmCategory | @PubModel | @CitedMedium | @EIdType | @Label | @part | @PubStatus | @Version | @Source | @Type | @lang | @ValidYN | @MajorTopicYN | @Owner | @IdType | @Name | @Status | @sec | @book">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:call-template name="string">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
      </x:call-template>
   </x:template>
   <x:template match="PersonalNameSubjectList | InvestigatorList | PubDate | ChemicalList | Pagination | ArticleIdList | AccessionNumberList | Sections | DeleteDocument | ObjectList | DeleteCitation | CommentsCorrectionsList | GeneSymbolList | History | SupplMeshList | PublicationTypeList | PubmedBookArticleSet | PubmedArticleSet | MeshHeadingList">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:call-template name="array">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
      </x:call-template>
   </x:template>

   <!-- Element OtherID, type:  object-->
   <x:template match="OtherID">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:call-template name="object">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
         <x:with-param name="kids-param" select="true()"/>
         <x:with-param name="kids" select="@*|node()"/>
      </x:call-template>
   </x:template>

   <!-- Element URL, type:  object-->
   <x:template match="URL">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:call-template name="object">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
         <x:with-param name="kids-param" select="true()"/>
         <x:with-param name="kids" select="@*|node()"/>
      </x:call-template>
   </x:template>

   <!-- Element LocationLabel, type:  object-->
   <x:template match="LocationLabel">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:call-template name="object">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
         <x:with-param name="kids-param" select="true()"/>
         <x:with-param name="kids" select="@*|node()"/>
      </x:call-template>
   </x:template>

   <!-- Element SupplMeshName, type:  object-->
   <x:template match="SupplMeshName">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:call-template name="object">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
         <x:with-param name="kids-param" select="true()"/>
         <x:with-param name="kids" select="@*|node()"/>
      </x:call-template>
   </x:template>

   <!-- Element NameID, type:  object-->
   <x:template match="NameID">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:call-template name="object">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
         <x:with-param name="kids-param" select="true()"/>
         <x:with-param name="kids" select="@*|node()"/>
      </x:call-template>
   </x:template>

   <!-- Element DescriptorName, type:  object-->
   <x:template match="DescriptorName">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:call-template name="object">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
         <x:with-param name="kids-param" select="true()"/>
         <x:with-param name="kids" select="@*|node()"/>
      </x:call-template>
   </x:template>

   <!-- Element Param, type:  object-->
   <x:template match="Param">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:call-template name="object">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
         <x:with-param name="kids-param" select="true()"/>
         <x:with-param name="kids" select="@*|node()"/>
      </x:call-template>
   </x:template>

   <!-- Element ELocationID, type:  object-->
   <x:template match="ELocationID">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:call-template name="object">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
         <x:with-param name="kids-param" select="true()"/>
         <x:with-param name="kids" select="@*|node()"/>
      </x:call-template>
   </x:template>

   <!-- Element GeneralNote, type:  object-->
   <x:template match="GeneralNote">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:call-template name="object">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
         <x:with-param name="kids-param" select="true()"/>
         <x:with-param name="kids" select="@*|node()"/>
      </x:call-template>
   </x:template>

   <!-- Element PMID, type:  object-->
   <x:template match="PMID">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:call-template name="object">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
         <x:with-param name="kids-param" select="true()"/>
         <x:with-param name="kids" select="@*|node()"/>
      </x:call-template>
   </x:template>

   <!-- Element ArticleId, type:  object-->
   <x:template match="ArticleId">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:call-template name="object">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
         <x:with-param name="kids-param" select="true()"/>
         <x:with-param name="kids" select="@*|node()"/>
      </x:call-template>
   </x:template>

   <!-- Element ISSN, type:  object-->
   <x:template match="ISSN">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:call-template name="object">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
         <x:with-param name="kids-param" select="true()"/>
         <x:with-param name="kids" select="@*|node()"/>
      </x:call-template>
   </x:template>

   <!-- Element QualifierName, type:  object-->
   <x:template match="QualifierName">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:call-template name="object">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
         <x:with-param name="kids-param" select="true()"/>
         <x:with-param name="kids" select="@*|node()"/>
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
   <x:template match="URL/text()">
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
</x:stylesheet>