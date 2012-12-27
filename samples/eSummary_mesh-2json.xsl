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
   <x:template match="DS_HeadingMappedToList | DS_PaList | DS_Subheading | DS_PreviousIndexing | DS_MeshTerms | DS_PaPx | DS_SeeRelated | DS_IdxLinks | Children">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:param name="trailing-comma" select="position() != last()"/>
      <x:call-template name="array">
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
   <x:template match="Parent | TreeNum | DS_RevisionDate | DS_ScopeNote | string | DS_HeadingMappedTo | DS_YearIntroduced | DS_EntryDate | DS_RegistryNumber | @uid | @status">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:param name="trailing-comma" select="position() != last()"/>
      <x:call-template name="string">
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
   <x:template match="int">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:param name="trailing-comma" select="position() != last()"/>
      <x:call-template name="number">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
         <x:with-param name="trailing-comma" select="$trailing-comma"/>
      </x:call-template>
   </x:template>
   <x:template match="LinksType">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:param name="trailing-comma" select="position() != last()"/>
      <x:call-template name="object">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
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