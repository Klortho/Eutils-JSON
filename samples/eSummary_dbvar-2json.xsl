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
   <xsl:template match="Chr_inner_end | Chr_end | Sample_count | Project_ID | Tax_ID | Support_variant_count | Variant_count | tax_id | Validation_status | Chr_start | Chr_outer_start | id | Chr_outer_end | PMID | Subject_Phenotype_status | Chr_inner_start | Variant_size">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="number">
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="Chr | Study_DisplayName | Study_type | Organism | Assembly_accession | Publication_Date | Chr_accession_version | species | string | Assembly_tax_ID | Study_Description | Validation_status_weight | Project_Name | Contig_accession_version | Method_type_category | SV | ST | OBJ_TYPE | name | Method_type_weight | Placement_type | Assembly | @uid | @status">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="string">
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="eSummaryResult">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <!--Handling itemspec <member> or <members>--><xsl:apply-templates select="@*|*">
         <xsl:with-param name="context" select="$context"/>
      </xsl:apply-templates>
   </xsl:template>
   <xsl:template match="dbVarPlacement | dbVarStudyOrg | dbVarGene">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="object">
         <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="dbVarEvidenceList | dbVarSampleList | dbVarMethodList | dbVarRemappedAssemblyList | dbVarAlleleTypeList | dbVarStudyOrgList | dbVarVariantTypeList | dbVarGeneList | dbVarSubmittedAssemblyList | dbVarClinicalSignificanceList | dbVarPlacementList | dbVarAlleleOriginList">
      <xsl:param name="context" select="&#34;unknown&#34;"/>
      <xsl:call-template name="array">
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
</xsl:stylesheet>