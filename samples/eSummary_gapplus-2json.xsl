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
   <xsl:template match="phenotype_category_list | snp_gene_info_list | study_list | mesh_category | mesh_category_list | phenotype_category_info | phenotype_list">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="a">
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="gene_2_start | pha | participant_set | total_discovery_sample | pos | dist_1 | phs | dist_2 | gene_stop | gwas_study_id | pmid | distance | study_version | gene_2_stop | gene_start | gene_1_stop | gene_1 | gene_2 | total_sample | marker_rs | chr | gene_1_start | total_replication_sample | analysis_version | pvalue_log | studies_snp_id">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="n">
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="initial_sample_desc | in_gene | human_enhancer | create_date | gwas_ancestry_desc | phenotype_desc | platform | gene_1_name | phenotype | study_name | analysis_name | position | phenotype_category | dbsnp_alleles_het_se | title | dbsnp_clinstatus | pvalue_string | replication_sample_desc | current_snp | ls_snp | dbsnp_maf | cited_snp | dbsnp_validation | chromosome | uni_prot_annot | poly_phen2 | key | sift | gene_id | in_mi_rnabs | in_linc_rna | mesh_category_name | last_modified_date | omim_info_list | gene_2_name | mesh_term | journal | rna_edit | oreganno | functional_class | gene_symbol | pub_date | conserved_pred_tfbs | source | in_mi_rna | location_within_paper | @uid | @status">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="s">
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="gene_info | sample_info | study | snp_gene_info | phenotype_info | snp_info | publication">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="o">
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
   <xsl:template match="exclusively_male_female | incl_male_female_only">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="b">
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
</xsl:stylesheet>