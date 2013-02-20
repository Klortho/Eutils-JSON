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
   <xsl:template match="d_dataset_embargo_date | d_disease_name | d_parent_id | d_study_type | d_document_description | d_ancestor_id | d_study_name | d_project_name | d_study_archive | d_dataset_name | d_variable_embargo_date | d_variable_id | d_dataset_description | d_variable_dataset_id | d_document_name | d_study_has_sra | d_analysis_id | d_type | d_analysis_name | d_genotype_platform | d_study_release_date | d_document_id | d_study_embargo_date | d_variable_dataset_description | d_parent_name | d_study_id | d_genotype_vendor | d_dataset_id | d_variable_has_phenx | d_variable_type | d_variable_description | d_study_status | d_variable_dataset_name | d_analysis_description | d_variable_phenx | d_ancestor_name | d_variable_name | @uid | @status">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="s">
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="d_analysis_ancestor | d_disease_info | d_document_ancestor | d_variable_parent | d_analysis_parent | d_dataset_parent | d_study_project_list | d_project_info | d_study_disease_list | d_dataset_ancestor | d_study_genotype_platform_list | d_type_info | d_study_type_list | d_document_parent | d_variable_ancestor | d_study_ancestor">
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
   <xsl:template match="d_variable_dataset | d_study_results | d_dataset_results | d_variable_results | d_ancestor_id_and_name | d_parent_id_and_name | d_genotype_platform_info | d_document_results | d_analysis_results">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="o">
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="d_num_variables_in_subtree | d_num_analyses_in_subtree | d_num_participants_in_subtree | d_num_descendants_in_subtree | d_num_documents_in_subtree">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="n">
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
            <xsl:attribute name="k">result</xsl:attribute>
         </xsl:if>
         <!--Handling itemspec <a>-->
<a k="uids">
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