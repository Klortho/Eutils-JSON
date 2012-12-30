<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:np="http://ncbi.gov/portal/XSLT/namespace"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                version="1.0"
                exclude-result-prefixes="np xs">
   <xsl:import href="xml2json.xsl"/>
   <xsl:output method="text" encoding="UTF-8"/>
   <xsl:param name="pretty" select="true()"/>
   <xsl:param name="lcnames" select="true()"/>
   <xsl:param name="dtd-annotation">
      <json type="esummary" version="0.3">
         <config lcnames="true"/>
      </json>
   </xsl:param>
   <xsl:template match="Extra | Reviewed_status | Replicon_type | Organism | ProjectID | Comment | Total_count | SetType | GenomeExtra | Refseq_accession | RNA_count | Gene_count | Caption | Strand | ReplacedBy | Replicon_name | TraceGi | Biomol | Title | ContigNum | GC_content | Sequencing_centers | SubType | NeighborNum | OtherReplicons | SourceDb | Genome | CreateDate | GenBank_accession | GeneticCode | Organelle | Protein_count | Subtype | AccessionVersion | ViewerIdx | BioMol | DNA_length | Topology | Completeness | SubName | MoleculeType | MolType | error | Tech | Status | Meta | PubMedIds | UpdateDate | AssemblyAcc | @gi_state | @repr | @est | @gss | @mol | @sat | @subtype | @popset | @extfeatmask | @length | @sat_key | @na | @defdiv | @qual | @uid | @owner_name | @type | @value | @db | @status | @sat_name | @genome | @owner | @trace | @source | @term | @aa">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="string">
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="Statistics | Warning">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="array">
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="eSummaryResult">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <!--Handling itemspec <member> or <members>--><xsl:apply-templates select="@*|*">
         <xsl:with-param name="context" select="$context"/>
      </xsl:apply-templates>
   </xsl:template>
   <xsl:template match="Otherdb | IdGiClass | Stat">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="object">
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="SegSetSize | AssemblyGi | ProjectId | TaxId | Flags | Gi | Slen | @count">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="number">
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="Properties | OSLT">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="object">
         <xsl:with-param name="context" select="$context"/>
         <xsl:with-param name="kids" select="@*|node()"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="Properties/text()">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="string">
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="OSLT/text()">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="string">
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="DocumentSummary">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="object">
         <xsl:with-param name="context" select="$context"/>
         <xsl:with-param name="key" select="@uid"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="DocumentSummarySet">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <!--Handling itemspec <object>--><o>
         <xsl:if test="$context = &#34;object&#34;">
            <xsl:attribute name="name">
               <xsl:value-of select="&#34;result&#34;"/>
            </xsl:attribute>
         </xsl:if>
         <!--Handling itemspec <array>--><a name="{&#34;uids&#34;}">
            <xsl:apply-templates select="DocumentSummary/@uid">
               <xsl:with-param name="context" select="&#34;array&#34;"/>
            </xsl:apply-templates>
         </a>
         <!--Handling itemspec <member> or <members>--><xsl:apply-templates select="DocumentSummary">
            <xsl:with-param name="context" select="'object'"/>
         </xsl:apply-templates>
      </o>
   </xsl:template>
   <xsl:template match="@indexed">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="boolean">
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
</xsl:stylesheet>