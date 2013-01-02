<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:np="http://ncbi.gov/portal/XSLT/namespace"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0"
                exclude-result-prefixes="np">
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
      <xsl:call-template name="s">
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="Statistics | Warning">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="a">
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="eSummaryResult">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <!--Handling itemspec <m>-->
<xsl:choose>
         <xsl:when test="$context = &#34;a&#34;">
            <xsl:apply-templates select="*">
               <xsl:with-param name="context" select="$context"/>
            </xsl:apply-templates>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates select="@*|*">
               <xsl:with-param name="context" select="$context"/>
            </xsl:apply-templates>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="Otherdb | IdGiClass | Stat">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="o">
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="SegSetSize | AssemblyGi | ProjectId | TaxId | Flags | Gi | Slen | @count">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="n">
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="Properties | OSLT">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="o">
         <xsl:with-param name="context" select="$context"/>
         <xsl:with-param name="kids" select="@*|node()"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="Properties/text()">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="s">
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="OSLT/text()">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="s">
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="DocumentSummary">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="o">
         <xsl:with-param name="context" select="$context"/>
         <xsl:with-param name="k" select="@uid"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="DocumentSummarySet">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <!--Handling itemspec <o>-->
<o>
         <xsl:if test="$context = &#34;o&#34;">
            <xsl:attribute name="k">
               <xsl:value-of select="&#34;result&#34;"/>
            </xsl:attribute>
         </xsl:if>
         <!--Handling itemspec <a>-->
<a k="{&#34;uids&#34;}">
            <xsl:apply-templates select="DocumentSummary/@uid">
               <xsl:with-param name="context" select="&#34;a&#34;"/>
            </xsl:apply-templates>
         </a>
         <!--Handling itemspec <m>-->
<xsl:apply-templates select="DocumentSummary">
            <xsl:with-param name="context" select="'o'"/>
         </xsl:apply-templates>
      </o>
   </xsl:template>
   <xsl:template match="@indexed">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="b">
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
</xsl:stylesheet>