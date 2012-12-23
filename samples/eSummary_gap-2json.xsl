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
   <x:template match="d_dataset_embargo_date | d_disease_name | d_parent_id | d_study_type | d_document_description | d_ancestor_id | d_study_name | d_project_name | d_study_archive | d_dataset_name | d_variable_embargo_date | d_variable_id | d_dataset_description | d_variable_dataset_id | d_document_name | d_study_has_sra | d_analysis_id | d_type | d_analysis_name | d_genotype_platform | d_study_release_date | d_document_id | d_study_embargo_date | d_variable_dataset_description | d_parent_name | d_study_id | d_genotype_vendor | d_dataset_id | d_variable_has_phenx | d_variable_type | d_variable_description | d_study_status | d_variable_dataset_name | d_analysis_description | d_variable_phenx | d_ancestor_name | d_variable_name | @uid | @status">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:call-template name="string">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
      </x:call-template>
   </x:template>
   <x:template match="d_analysis_ancestor | d_disease_info | d_document_ancestor | d_variable_parent | d_analysis_parent | d_dataset_parent | d_study_project_list | d_project_info | d_study_disease_list | d_dataset_ancestor | d_study_genotype_platform_list | d_type_info | d_study_type_list | d_document_parent | d_variable_ancestor | d_study_ancestor">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:call-template name="array">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
      </x:call-template>
   </x:template>
   <x:template match="eSummaryResult">
      <x:call-template name="result-start">
         <x:with-param name="dtd-annotation">
            <json type="esummary" version="0.3">
               <config lcnames="true"/>
            </json>
         </x:with-param>
      </x:call-template>
      <x:apply-templates select="@*|*">
         <x:with-param name="indent" select="$iu"/>
         <x:with-param name="context" select="&#34;object&#34;"/>
      </x:apply-templates>
      <x:value-of select="np:end-object(&#34;&#34;, false())"/>
   </x:template>
   <x:template match="d_variable_dataset | d_study_results | d_dataset_results | d_variable_results | d_ancestor_id_and_name | d_parent_id_and_name | DocumentSummarySet | d_genotype_platform_info | d_document_results | d_analysis_results">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:call-template name="object">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
      </x:call-template>
   </x:template>
   <x:template match="d_num_variables_in_subtree | d_num_analyses_in_subtree | d_num_participants_in_subtree | d_num_descendants_in_subtree | d_num_documents_in_subtree">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:call-template name="number">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
      </x:call-template>
   </x:template>
   <x:template match="DocumentSummary">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:call-template name="object">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
         <x:with-param name="key" select="@uid"/>
      </x:call-template>
   </x:template>
</x:stylesheet>