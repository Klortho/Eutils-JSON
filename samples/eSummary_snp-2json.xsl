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
   <x:template match="LOCSNPID | SUSPECTED | CHRPOS | GTYPE | CHRRPT | Organism | GLOBAL_MAF | UPD_BUILD | HANDLE | ACC | LINKOUT | SORT_PRIORITY | WEIGHT | METHOD_CLASS | SRATE | LOOKUP | SNP3D | CREATEDATE | DOCSUM | SNP_CLASS | ALLELE | FXN_CLASS | TAX_ID | HET | GENE | NONREF | CONTIGPOS | VALIDATED | ALLELE_ORIGIN | UPDATEDATE | GLOBAL_SAMPLESIZE | SS | POP_CLASS | GLOBAL_POPULATION | TEXT | CHR | SNP_ID | CLINICAL_SIGNIFICANCE | ORIG_BUILD | LOCUS_ID | @uid | @status">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:call-template name="string">
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
   <x:template match="DocumentSummary">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:call-template name="object">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
         <x:with-param name="key" select="@uid"/>
      </x:call-template>
   </x:template>
   <x:template match="DocumentSummarySet">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:call-template name="object">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
      </x:call-template>
   </x:template>
</x:stylesheet>