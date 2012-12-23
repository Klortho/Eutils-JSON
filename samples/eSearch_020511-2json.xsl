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
   <x:template match="RetMax | To | Term | QueryKey | Explode | FieldNotFound | From | OP | PhraseIgnored | RetStart | WebEnv | OutputMessage | QuotedPhraseNotFound | Id | Field | Count | PhraseNotFound | QueryTranslation">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:call-template name="string">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
      </x:call-template>
   </x:template>
   <x:template match="eSearchResult">
      <x:call-template name="result-start">
         <x:with-param name="dtd-annotation">
            <json type="esearch" version="0.3">
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
   <x:template match="ERROR">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:call-template name="string">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
         <x:with-param name="key" select="&#34;ERROR&#34;"/>
      </x:call-template>
   </x:template>
   <x:template match="ErrorList">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>

      <!--json annotation for content model: object-->
      <x:choose>
         <x:when test="$context = &#34;array&#34;">
            <x:value-of select="np:start-object(concat($indent, $iu0))"/>
         </x:when>
         <x:otherwise>
            <x:variable name="key" select="np:to-lower(name(.))"/>
            <x:value-of select="np:key-start-object(concat($indent, $iu0), $key)"/>
         </x:otherwise>
      </x:choose>

      <!--json annotation for content model: 'array'-->
      <x:value-of select="np:key-start-array(concat($indent, $iu1), &#34;phrasesnotfound&#34;)"/>
      <x:apply-templates select="PhraseNotFound">
         <x:with-param name="indent" select="concat($indent, $iu1, $iu)"/>
         <x:with-param name="context" select="&#34;array&#34;"/>
      </x:apply-templates>
      <x:value-of select="np:end-array(concat($indent, $iu1), true())"/>
      <!-- done: 'array' -->

<!--json annotation for content model: 'array'-->
      <x:value-of select="np:key-start-array(concat($indent, $iu1), &#34;fieldsnotfound&#34;)"/>
      <x:apply-templates select="FieldsNotFound">
         <x:with-param name="indent" select="concat($indent, $iu1, $iu)"/>
         <x:with-param name="context" select="&#34;array&#34;"/>
      </x:apply-templates>
      <x:value-of select="np:end-array(concat($indent, $iu1), false())"/>
      <!-- done: 'array' --><x:value-of select="np:end-object(concat($indent, $iu0),  position() != last())"/>
      <!-- done: 'object' --></x:template>
   <x:template match="IdList | TranslationSet | TranslationStack">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:call-template name="array">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
      </x:call-template>
   </x:template>
   <x:template match="Translation | TermSet">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>
      <x:call-template name="object">
         <x:with-param name="indent" select="$indent"/>
         <x:with-param name="context" select="$context"/>
      </x:call-template>
   </x:template>
   <x:template match="WarningList">
      <x:param name="indent" select="&#34;&#34;"/>
      <x:param name="context" select="&#34;unknown&#34;"/>

      <!--json annotation for content model: object-->
      <x:choose>
         <x:when test="$context = &#34;array&#34;">
            <x:value-of select="np:start-object(concat($indent, $iu0))"/>
         </x:when>
         <x:otherwise>
            <x:variable name="key" select="np:to-lower(name(.))"/>
            <x:value-of select="np:key-start-object(concat($indent, $iu0), $key)"/>
         </x:otherwise>
      </x:choose>

      <!--json annotation for content model: 'array'-->
      <x:value-of select="np:key-start-array(concat($indent, $iu1), &#34;phrasesignored&#34;)"/>
      <x:apply-templates select="PhraseIgnored">
         <x:with-param name="indent" select="concat($indent, $iu1, $iu)"/>
         <x:with-param name="context" select="&#34;array&#34;"/>
      </x:apply-templates>
      <x:value-of select="np:end-array(concat($indent, $iu1), true())"/>
      <!-- done: 'array' -->

<!--json annotation for content model: 'array'-->
      <x:value-of select="np:key-start-array(concat($indent, $iu1), &#34;quotedphrasesnotfound&#34;)"/>
      <x:apply-templates select="QuotedPhraseNotFound">
         <x:with-param name="indent" select="concat($indent, $iu1, $iu)"/>
         <x:with-param name="context" select="&#34;array&#34;"/>
      </x:apply-templates>
      <x:value-of select="np:end-array(concat($indent, $iu1), true())"/>
      <!-- done: 'array' -->

<!--json annotation for content model: 'array'-->
      <x:value-of select="np:key-start-array(concat($indent, $iu1), &#34;outputmessages&#34;)"/>
      <x:apply-templates select="OutputMessage">
         <x:with-param name="indent" select="concat($indent, $iu1, $iu)"/>
         <x:with-param name="context" select="&#34;array&#34;"/>
      </x:apply-templates>
      <x:value-of select="np:end-array(concat($indent, $iu1), false())"/>
      <!-- done: 'array' --><x:value-of select="np:end-object(concat($indent, $iu0),  position() != last())"/>
      <!-- done: 'object' --></x:template>
</x:stylesheet>