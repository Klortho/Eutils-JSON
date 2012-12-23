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
   <x:template match="Project_Target_Material | Project_Target_Capture | Project_Acc | Relevance_Agricultural | Project_Id | Project_Data_Type | Relevance_Industrial | TaxId | Project_Subtype | Sequencing_Status | Project_Title | Supergroup | string | Project_Method | Project_ObjectivesType | Relevance_Other | Relevance_Model | Project_Type_Order | Project_Objectives | Submitter_Organization | Organism_Label | Project_Description | Relevance_Environmental | Organism_Name | Registration_Date | Project_Type | Project_Name | Relevance_Medical | Keyword | Project_Target_Scope | Relevance_Evolution | Organism_Strain | Project_MethodType | @uid | @status">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:call-template name="string">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
      </x:call-template>
   </x:template>
   <x:template match="Submitter_Organization_List | Project_Objectives_List">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:call-template name="array">
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
   <x:template match="DocumentSummarySet | Project_Objectives_Struct">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:call-template name="object">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
      </x:call-template>
   </x:template>
</x:stylesheet>