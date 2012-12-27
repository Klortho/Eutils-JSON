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
   <x:param name="pretty" select="true()"/>
   <x:param name="lcnames" select="true()"/>
   <x:param name="dtd-annotation">
      <json type="esummary" version="0.3">
         <config lcnames="true"/>
      </json>
   </x:param>
   <x:template match="phenotype_category_list | snp_gene_info_list | study_list | mesh_category | mesh_category_list | phenotype_category_info | phenotype_list">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:param name="trailing-comma" select="position() != last()"/>
      <x:call-template name="array">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
         <x:with-param name="trailing-comma" select="$trailing-comma"/>
      </x:call-template>
   </x:template>
   <x:template match="gene_2_start | pha | participant_set | total_discovery_sample | pos | dist_1 | phs | dist_2 | gene_stop | gwas_study_id | pmid | distance | study_version | gene_2_stop | gene_start | gene_1_stop | gene_1 | gene_2 | total_sample | marker_rs | chr | gene_1_start | total_replication_sample | analysis_version | pvalue_log | studies_snp_id">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:param name="trailing-comma" select="position() != last()"/>
      <x:call-template name="number">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
         <x:with-param name="trailing-comma" select="$trailing-comma"/>
      </x:call-template>
   </x:template>
   <x:template match="initial_sample_desc | in_gene | human_enhancer | create_date | gwas_ancestry_desc | phenotype_desc | platform | gene_1_name | phenotype | study_name | analysis_name | position | phenotype_category | dbsnp_alleles_het_se | title | dbsnp_clinstatus | pvalue_string | replication_sample_desc | current_snp | ls_snp | dbsnp_maf | cited_snp | dbsnp_validation | chromosome | uni_prot_annot | poly_phen2 | key | sift | gene_id | in_mi_rnabs | in_linc_rna | mesh_category_name | last_modified_date | omim_info_list | gene_2_name | mesh_term | journal | rna_edit | oreganno | functional_class | gene_symbol | pub_date | conserved_pred_tfbs | source | in_mi_rna | location_within_paper | @uid | @status">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:param name="trailing-comma" select="position() != last()"/>
      <x:call-template name="string">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
         <x:with-param name="trailing-comma" select="$trailing-comma"/>
      </x:call-template>
   </x:template>
   <x:template match="gene_info | sample_info | study | snp_gene_info | phenotype_info | snp_info | publication">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:param name="trailing-comma" select="position() != last()"/>
      <x:call-template name="object">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
         <x:with-param name="trailing-comma" select="$trailing-comma"/>
      </x:call-template>
   </x:template>
   <x:template match="eSummaryResult">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>

      <!--json annotation for content model: 'members'-->
      <x:apply-templates select="@*|*">
         <x:with-param name="indent" select="concat($indent, $iu0)"/>
         <x:with-param name="context" select="&#34;&#34;"/>
      </x:apply-templates>
   </x:template>
   <x:template match="exclusively_male_female | incl_male_female_only">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:param name="trailing-comma" select="position() != last()"/>
      <x:call-template name="boolean">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
         <x:with-param name="trailing-comma" select="$trailing-comma"/>
      </x:call-template>
   </x:template>
   <x:template match="DocumentSummary">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:param name="trailing-comma" select="position() != last()"/>
      <x:call-template name="object">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
         <x:with-param name="key" select="@uid"/>
         <x:with-param name="trailing-comma" select="$trailing-comma"/>
      </x:call-template>
   </x:template>
   <x:template match="DocumentSummarySet">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>

      <!--json annotation for content model: object-->
      <x:choose>
         <x:when test="$context = &#34;array&#34;">
            <x:value-of select="np:start-object(concat($indent, $iu0))"/>
         </x:when>
         <x:otherwise>
            <x:variable name="key" select="&#34;result&#34;"/>
            <x:value-of select="np:key-start-object(concat($indent, $iu0), $key)"/>
         </x:otherwise>
      </x:choose>

      <!--json annotation for content model: 'array'-->
      <x:value-of select="np:key-start-array(concat($indent, $iu1), &#34;uids&#34;)"/>
      <x:apply-templates select="DocumentSummary/@uid">
         <x:with-param name="indent" select="concat($indent, $iu1, $iu)"/>
         <x:with-param name="context" select="&#34;array&#34;"/>
      </x:apply-templates>
      <x:value-of select="np:end-array(concat($indent, $iu1), true())"/>
      <!-- done: 'array' -->

<!--json annotation for content model: 'members'-->
      <x:apply-templates select="DocumentSummary">
         <x:with-param name="indent" select="concat($indent, $iu1)"/>
         <x:with-param name="context" select="&#34;object&#34;"/>
      </x:apply-templates>
      <x:value-of select="np:end-object(concat($indent, $iu0),  position() != last())"/>
      <!-- done: 'object' --></x:template>
</x:stylesheet>