# Samples / test cases

This directory has local copies of all the samples files.  The
[tables below](#sample-tables) list all of the file formats that we have
worked on so far.

The "Links" column gives, for each file format / sample, links to
* the local, modified DTD stored in this directory of the GitHub repository
* an XSLT that was auto-generated from that DTD, that converts XML into JSON
* the local, saved copy of an EUtils XML document
* the EUtils service, to retrieve a fresh (perhaps new and updated) XML
  response
* the JSON output produced from the local XML, using the aforementioned XSLT.

## Overview

We are using the [DtdAnalyzer](http://github.com/NCBITools/DtdAnalyzer)
utility to automatically generate XSLT files from the DTDs.  The DtdAnalyzer
includes a tool, `dtd2xml2json`, that reads a DTD, analyzes the content model
of each element, and determines, when possible, the optimal JSON structure
into which those elements should be mapped.
[The documentation page](https://github.com/NCBITools/DtdAnalyzer/wiki/Auto-generating-XML-to-JSON-conversion-XSLT)
for that tool gives a more detailed explanation.

The DTDs here were pulled from the NCBI servers, and then annotated in a special
format, as needed, to provide further instructions to the `dtd2xml2json`
utility.

The products of this effort are the set of annotated DTDs and the
set of auto-generated XSLT files.  Each sample also includes an instance
XML document, and the JSON into which that was transformed.

The generated XSLTs depend on a "base XSLT" that is part of the DtdAnalyzer
library, [xml2json.xsl](https://github.com/NCBITools/DtdAnalyzer/blob/master/xslt/xml2json.xsl).
This needs to be made available from wherever the generated XSLTs are to be run.

## Test setup

First, clone and build the DtdAnalyzer, and add it to your PATH
(this step depends on ant):

    git clone https://github.com/NCBITools/DtdAnalyzer.git
    cd DtdAnalzyer
    ant
    export PATH=$PATH:`pwd`

Next, clone this repository, and go to the samples directory:

    cd ..
    git clone https://github.com/Klortho/Eutils-JSON.git
    cd Eutils-JSON/samples

Set an environment variable needed by the
XML tools to resolve DTDs to the local copies:

    export XML_CATALOG_FILES=`pwd`/catalog.xml

Create a soft-link from the local samples directory to the DtdAnalyzer
version of the base XSLT:

    ln -s ../../DtdAnalyzer/xslt/xml2json.xsl

Next install NodeJS and JSON-Lint per the instructions
[here](https://github.com/zaach/jsonlint).

You should then be ready to run the script, `process-all.sh`, that generates
all of the XSLTs and then uses them to generate JSON files.  If you want to
run it verbosely so you can see the progress:

    bash -v process-all.sh

If there are any validation errors, the script will terminate.

## A sample in detail

First you should validate the XML instance document.  It's important that the
DTD is complete and up-to-date, and that the XML document validates:

    xmllint --valid --noout einfo.xml

(As a sanity check, to make sure you're using the local copy of the DTD, you
might temporarily introduce a syntax error into `eInfo_020511.dtd`, and make sure
that it fails to validate.  If that doesn't work, make sure you've set your
`XML_CATALOG_FILES` environment variable correctly, to point to the local `catalog.xml`
file.)

Next, to generate an XML-to-JSON conversion XSLT for the eInfo sample:

    dtd2xml2json eInfo_020511.dtd eInfo_020511-2json.xsl

Then, run that against any of the eInfo sample XML documents to generate
JSON output:

    xsltproc eInfo_020511-2json.xsl einfo.xml > einfo.json
    xsltproc eInfo_020511-2json.xsl einfo.pubmed.xml > einfo.pubmed.json
    xsltproc eInfo_020511-2json.xsl einfo.error.xml > einfo.error.json

Next you should validate the json output.  For example:

    jsonlint einfo.json

## Specifying the conversion

At the top-level of each DTD is a special annotation that defines a few
pieces of metadata and configuration information.  For example, in the
eSummary DTDs, this has been added:

    <!--~~ !dtd
    ~~json
        <json type='esummary' version='0.3'>
          <config lcnames='true'/>
        </json>
    ~~-->

This tells the `dtd2xml2json` utility that it should insert two bits of
metadata into the header of the resultant JSON, like so:

    {
        "header": {
            "type": "esummary",
            "version": "0.3"
        },
        "result": {
            ...
        }
    }

It also sets the configuration parameter "lcnames" to "true", which means that
element and attribute names, when they appear as keys inside JSON objects,
will be converted into lowercase.

The `dtd2xml2json` utility then reads the entire DTD, and tries to determine,
for each element and attribute, how to map that item into a JSON data type
(either object, array, string, boolean, or number).  In most cases, it
is able to figure out, without
any hints or special annotations, what JSON type to map to.
For example, one of the simplest cases is an XML element with
text content and no attributes:

    <!ELEMENT DbName (#PCDATA)>

This will, by default, result in an XSLT template that will convert these
elements, when they appear, into JSON strings.

Sometimes, the `dtd2xml2json` utility wouldn't pick the optimal JSON
type. In those cases, annotations can be added to the DTD to tell it
what to do.  For example, the following instructs `dtd2xml2json` that the
&lt;TAX_ID> element should be converted into a JSON number (not quoted):

    <!--~~ <TAX_ID>
    ~~json <number/>
    ~~-->
    <!ELEMENT TAX_ID    %T_int;>

For a slightly more elaborate example, all of the eSummary DTDs specify a
wrapper &lt;DocumentSummarySet> element, which contains possibly very many
&lt;DocumentSummary>s.  It would be nice if, in JavaScript, you could access
a particular docsum directly, by its UID.  That is, it would be nice if there
were a JSON object whose member keys were the UIDs.  However, it might also
be the case that the original order of the docsums is important, and needs
to be preserved.  JSON objects do not preserve the order of their members, so
that's a problem.

The following annotations instruct `dtd2xml2json` that the &lt;DocumentSummarySet>
element should be converted into a JSON object that has members that come from
the &lt;DocumentSummary>s.  It also causes the generation of one extra member of
that object, which is an array of uids.  The array preserves the order of the
docsums.  The second annotation, for the &lt;DocumentSummary> element, causes the
"uid" attribute to be used for the member key within the wrapper JSON object.
This allows the uids to be used directly to retrieve the docsums.

    <!--~~ <DocumentSummarySet>
    ~~json
      <object name='"result"'>
        <array name='"uids"' select='DocumentSummary/@uid'/>
        <members select='DocumentSummary'/>
      </object>
    ~~-->

    <!--~~ <DocumentSummary>
    ~~json <object name='@uid'/>
    ~~-->

This would result, for example, in JSON looking something like this:

    "result": {
        "uids": [
            "52770",
            "52771"
        ],
        "52770": { ... },
        "52771": { ... }
    }

In more complicated cases, however, even the DTD annotations are not adequate
to generate the best JSON for a particular type of XML content.  Among these
samples, there was only one where this was a problem, the eFetch PubMed DTD,
`pubmed_120101.dtd`.
In this case, we wrote a separate XSLT stylesheet by hand, `efetch.pubmed.xsl`,
with templates that
match the problem elements.  In the DTD, we added the "import" configuration
parameter, with a value that tells `dtd2xml2json` that its generated stylesheet
should import our hand-crafted one:

    <!--~~ !dtd
    ~~json
        <json type='efetch.pubmed' version='0.3'>
          <config lcnames='true' import='efetch.pubmed.xsl'/>
        </json>
    ~~-->

## Other scripts and utilities

We're keeping track of progress, notes, and problems in the `samples.xml` file here,
and then using that to generate the tables you see below.  The script `fixsamples.pl`
uses the XSLT stylesheet `fixsamples.xsl` to generate those HTML tables and merge
them into this README file.

The XSLT stylesheet `make-process-all.xsl` reads the list of all samples from
`samples.xml` file, and generates the `process-all.sh` script.

# Notes / Problems

## ① All ESummary DTDs use the same public identifier

All the esummary example files use the public id "-//NLM//DTD eSummaryResult//EN"
to refer to their DTDs, but different system identifiers.  This makes it more
difficult to use OASIS catalog files with them, which is important to prevent
external tools from hitting our servers every time they read an XML instance
document.

Every unique DTD should have its own public identifier.

## ② XML results that fail to validate (bad DTDs)

Many XML instance documents pulled from the eutilities interface failed to validate
against their respective DTDs.  These are all called out in the tables below.

One in particular is of concern: `esummary.pmcerror.xml`, [PMC eSummary with an erroroneous id](http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&version=2.0&db=pmc&id=254085,1,14900).
I had to add a declaration for the &lt;error&gt; element into the DTD.  I suspect
that this is a problem for all the other esummary DTDs as well, but I didn't try
them with erroneous IDs.

## ③ DTDs elements that are under-specified.

In all of the eSummary DTDs, the declarations of the elements are not optimal.
They are under-specified, meaning the content model is too loose.  This meant that
in order to produce good JSON, we often had to guess at
the actual schema that the data would conform to, based on the example instance
document.  Sometimes, we might have guessed wrong, and that would mean that
some instances might result in invalid JSON output.

For example, in eSummary_pmc.dtd, the following is the declaration for `<author>`:

    <!ENTITY   % T_Author "(
          Name
          | AuthType
          )*">
    <!-- Definition of List type: T_AuthorList -->
    <!ELEMENT Author  %T_Author;>

We guessed that this element probably always only has *at most* one of each of the
child elements &lt;Name> and &lt;AuthType>, but that's not the way it is written.  There
are many instances of this, and the &lt;DocumentSummary> element in each esummary DTD
is the most prominent example.

As mentioned, this is a very common pattern among the eSummary DTDs, and I suspect
that it's the result of an tool that automatically generates these DTDs from some
C++ structure.  Perhaps that tool could be improved.

## ④ Errors in DTDs

The eSummary DTDs use a set of entities to annotate the datatypes of some of the
elements and attributes, for example:  %T_string, %T_int, and %T_date.  We used
%T_int in many cases to decide that an item should be converted into a JSON number.
But, in at least one case (eSummary_gapplus.dtd) the instance document didn't agree,
and there was an instance of that data that was not a number.  If these DTDs are
autogenerated, as I suspect, then how can this be?  Should we worry about all of
the other cases where we used %T_int?

## ⑤ Escaped markup

In many places, escaped-XML is used inside elements.  Here are two examples:

In esummary.book.xml, in the &lt;BookInfo> element.  This uses a CDATA section:

```
<BookInfo><![CDATA[
  <Info>
    <Path>
      <Parent id="pdqcis" role="source" type="book" uid="2821524">
        <Title>PDQ Cancer Information Summaries</Title>
      </Parent>
  ....
]]></BookInfo>
```

In esummary.medgen.xml, in the &lt;ConceptMeta> element.  This does not use
a CDATA section, but the effect is exactly the same:

```
<ConceptMeta>&lt;Names&gt;&lt;Name SDUI=&quot;C048285&quot; SAB=&quot;MSH&quot;
  TTY=&quot;NM&quot; type=&quot;preferred&quot;&gt;5&apos;-chloroacetamido-5
  ...&lt;/SNOMEDCT&gt;</ConceptMeta>
```

These make the data very hard to extract
for other applications, and in particular for conversion into JSON.  These should
be eliminated as much as possible.  For example, in the books example, probably
this was only done because the &lt;Title> element can contain HTML.  If that's the
case, then only that element needs to contain escaped markup, and not the entire
&lt;BookInfo> element.  For medgen, I can't see any reason for it at all.

There's a note in the tables below for each DTD where we found this problem.

# Sample tables

<!--
  DO NOT MODIFY BELOW THIS LINE.
  The stuff from here down is auto-generated, and any changes you make
  will be lost.  See the fixsamples.pl script.
-->

<div>
  <h2>EInfo</h2>
  <table><tr><th/><th>✓</th><th>Description / Notes</th><th>Links</th></tr>
    <tr><th>EInfo</th><td>✓</td><td><em>Basic EInfo result, list of all databases.</em></td><td><a href="eInfo_020511.dtd">DTD</a>, <a href="eInfo_020511-2json.xsl">XSLT</a>;<br/>XML: <a href="einfo.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/einfo.fcgi">eutils;</a><br/><a href="einfo.json">JSON</a></td></tr>
    <tr><th>EInfo PubMed</th><td>✓</td><td><em>Information about the PubMed database.</em><br/><a href="#-xml-results-that-fail-to-validate-bad-dtds">②</a> 
          &lt;Field&gt; element in the instance document doesn't follow the DTD.
          I fixed the DTD by making &lt;IsRangable&gt; [sic] and &lt;IsTruncatable&gt;
          optional.
        </td><td><a href="eInfo_020511.dtd">DTD</a>, <a href="eInfo_020511-2json.xsl">XSLT</a>;<br/>XML: <a href="einfo.pubmed.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/einfo.fcgi?db=pubmed">eutils;</a><br/><a href="einfo.pubmed.json">JSON</a></td></tr>
    <tr><th>EInfo Error</th><td>✓</td><td><em>Test an error response: invalid database name.</em></td><td><a href="eInfo_020511.dtd">DTD</a>, <a href="eInfo_020511-2json.xsl">XSLT</a>;<br/>XML: <a href="einfo.error.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/einfo.fcgi?db=fleegle">eutils;</a><br/><a href="einfo.error.json">JSON</a></td></tr>
  </table>
  <h2>ESearch</h2>
  <table><tr><th/><th>✓</th><th>Description / Notes</th><th>Links</th></tr>
    <tr><th>ESearch PubMed</th><td>✓</td><td><em>List of search results from PubMed.</em></td><td><a href="eSearch_020511.dtd">DTD</a>, <a href="eSearch_020511-2json.xsl">XSLT</a>;<br/>XML: <a href="esearch.pubmed.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&amp;term=cancer&amp;reldate=60&amp;datetype=edat&amp;retmax=100&amp;usehistory=y">eutils;</a><br/><a href="esearch.pubmed.json">JSON</a></td></tr>
    <tr><th>ESearch Error</th><td>✓</td><td><em>Test an error response:  this query has a bad search term.</em></td><td><a href="eSearch_020511.dtd">DTD</a>, <a href="eSearch_020511-2json.xsl">XSLT</a>;<br/>XML: <a href="esearch.error.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=nlmcatalog&amp;term=obstetrics%5bMeSH%20Terms%5d+OR+fleegle%5bMeSH%20Terms%5d">eutils;</a><br/><a href="esearch.error.json">JSON</a></td></tr>
    <tr><th>ESearch Bad Error</th><td>✓</td><td><em>Test an even worse error:  invalid db name specified.</em></td><td><a href="eSearch_020511.dtd">DTD</a>, <a href="eSearch_020511-2json.xsl">XSLT</a>;<br/>XML: <a href="esearch.baderror.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=fleegle&amp;term=cat">eutils;</a><br/><a href="esearch.baderror.json">JSON</a></td></tr>
  </table>
  <h2>ESummary</h2>
  <table><tr><th/><th>✓</th><th>Description / Notes</th><th>Links</th></tr>
    <tr><th>pubmed</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.<br/><a href="#-errors-in-dtds">④</a> 
          &lt;PubStatus&gt; is marked as type "T_int", but its value is not always
          an integer.
        </td><td><a href="eSummary_pubmed.dtd">DTD</a>, <a href="eSummary_pubmed-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.pubmed.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=pubmed&amp;id=5683731,22144687">eutils;</a><br/><a href="esummary.pubmed.json">JSON</a></td></tr>
    <tr><th>protein</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.</td><td><a href="eSummary_protein.dtd">DTD</a>, <a href="eSummary_protein-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.protein.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=protein&amp;id=284822047">eutils;</a><br/><a href="esummary.protein.json">JSON</a></td></tr>
    <tr><th>nuccore</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.</td><td><a href="eSummary_nuccore.dtd">DTD</a>, <a href="eSummary_nuccore-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.nuccore.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=nuccore&amp;id=424386131">eutils;</a><br/><a href="esummary.nuccore.json">JSON</a></td></tr>
    <tr><th>nucleotide</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-xml-results-that-fail-to-validate-bad-dtds">②</a> 
          The instance document is invalid according to the DTD.  I fixed the DTD,
          by adding some elements and attributes that were declared in eSummary_nuccore.dtd.
        <br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.</td><td><a href="eSummary_nucleotide.dtd">DTD</a>, <a href="eSummary_nucleotide-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.nucleotide.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=nucleotide&amp;id=424386131">eutils;</a><br/><a href="esummary.nucleotide.json">JSON</a></td></tr>
    <tr><th>nucgss</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.</td><td><a href="eSummary_nucgss.dtd">DTD</a>, <a href="eSummary_nucgss-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.nucgss.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=nucgss&amp;id=371566079">eutils;</a><br/><a href="esummary.nucgss.json">JSON</a></td></tr>
    <tr><th>nucest</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.</td><td><a href="eSummary_nucest.dtd">DTD</a>, <a href="eSummary_nucest-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.nucest.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=nucest&amp;id=409212211">eutils;</a><br/><a href="esummary.nucest.json">JSON</a></td></tr>
    <tr><th>structure</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-xml-results-that-fail-to-validate-bad-dtds">②</a> 
          Instance document is not valid according to the DTD.  The element PdbAccSynList
          is not declared.  We fixed the DTD by adding it.
        <br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.</td><td><a href="eSummary_structure.dtd">DTD</a>, <a href="eSummary_structure-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.structure.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=structure&amp;id=52770">eutils;</a><br/><a href="esummary.structure.json">JSON</a></td></tr>
    <tr><th>genome</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-xml-results-that-fail-to-validate-bad-dtds">②</a> 
          Instance document is not valid according to the DTD.  
          The elements Organism_Group and Organism_Subgroup were not declared, so
          we added them as strings.
        <br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.</td><td><a href="eSummary_genome.dtd">DTD</a>, <a href="eSummary_genome-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.genome.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=genome&amp;id=2640">eutils;</a><br/><a href="esummary.genome.json">JSON</a></td></tr>
    <tr><th>assembly</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.<br/><a href="#-escaped-markup">⑤</a> 
          The element &lt;Meta&gt; contains some escaped markup, which makes it very hard to 
          extract into JSON.
        </td><td><a href="eSummary_assembly.dtd">DTD</a>, <a href="eSummary_assembly-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.assembly.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=assembly&amp;id=440818">eutils;</a><br/><a href="esummary.assembly.json">JSON</a></td></tr>
    <tr><th>gcassembly</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-xml-results-that-fail-to-validate-bad-dtds">②</a> 
          Instance document is not valid according to the DTD.  No definitions for
          &lt;SubmitterOrganization&gt; or &lt;AssemblyStatus&gt;.  I added the definitions for these from
          eSummary_assembly.dtd (which makes these two DTDs identical.)
        <br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.</td><td><a href="eSummary_gcassembly.dtd">DTD</a>, <a href="eSummary_gcassembly-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.gcassembly.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=gcassembly&amp;id=440818">eutils;</a><br/><a href="esummary.gcassembly.json">JSON</a></td></tr>
    <tr><th>genomeprj</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.</td><td><a href="eSummary_genomeprj.dtd">DTD</a>, <a href="eSummary_genomeprj-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.genomeprj.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=genomeprj&amp;id=54101">eutils;</a><br/><a href="esummary.genomeprj.json">JSON</a></td></tr>
    <tr><th>bioproject</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.</td><td><a href="eSummary_bioproject.dtd">DTD</a>, <a href="eSummary_bioproject-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.bioproject.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=bioproject&amp;id=171168">eutils;</a><br/><a href="esummary.bioproject.json">JSON</a></td></tr>
    <tr><th>biosample</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.</td><td><a href="eSummary_biosample.dtd">DTD</a>, <a href="eSummary_biosample-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.biosample.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=biosample&amp;id=182293">eutils;</a><br/><a href="esummary.biosample.json">JSON</a></td></tr>
    <tr><th>biosystems</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.</td><td><a href="eSummary_biosystems.dtd">DTD</a>, <a href="eSummary_biosystems-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.biosystems.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=biosystems&amp;id=493040">eutils;</a><br/><a href="esummary.biosystems.json">JSON</a></td></tr>
    <tr><th>blastdbinfo</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.</td><td><a href="eSummary_blastdbinfo.dtd">DTD</a>, <a href="eSummary_blastdbinfo-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.blastdbinfo.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=blastdbinfo&amp;id=645844">eutils;</a><br/><a href="esummary.blastdbinfo.json">JSON</a></td></tr>
    <tr><th>books</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.<br/><a href="#-escaped-markup">⑤</a> 
          The &lt;BookInfo&gt; element contains a lot of unfortunate escaped markup, in
          a CDATA section.
        </td><td><a href="eSummary_books.dtd">DTD</a>, <a href="eSummary_books-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.books.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=books&amp;id=2825746">eutils;</a><br/><a href="esummary.books.json">JSON</a></td></tr>
    <tr><th>cdd</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.</td><td><a href="eSummary_cdd.dtd">DTD</a>, <a href="eSummary_cdd-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.cdd.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=cdd&amp;id=201140">eutils;</a><br/><a href="esummary.cdd.json">JSON</a></td></tr>
    <tr><th>clone</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.</td><td><a href="eSummary_clone.dtd">DTD</a>, <a href="eSummary_clone-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.clone.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=clone&amp;id=29702171">eutils;</a><br/><a href="esummary.clone.json">JSON</a></td></tr>
    <tr><th>gap</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.</td><td><a href="eSummary_gap.dtd">DTD</a>, <a href="eSummary_gap-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.gap.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=gap&amp;id=195331">eutils;</a><br/><a href="esummary.gap.json">JSON</a></td></tr>
    <tr><th>gapplus</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-xml-results-that-fail-to-validate-bad-dtds">②</a> 
          Instance document is not valid according to the DTD.  
          This DTD looks like it doesn't match the content very well.  I fixed it by adding
          elements until the instance document validated, but I don't have much confidence that
          the DTD I created is correct.
        <br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.<br/><a href="#-errors-in-dtds">④</a> 
          Element &lt;source&gt; is marked as "T_int", but its values
          in instance documents are not numbers, they are text strings.
        </td><td><a href="eSummary_gapplus.dtd">DTD</a>, <a href="eSummary_gapplus-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.gapplus.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=gapplus&amp;id=5235996">eutils;</a><br/><a href="esummary.gapplus.json">JSON</a></td></tr>
    <tr><th>dbvar</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-xml-results-that-fail-to-validate-bad-dtds">②</a> 
          Instance document is not valid according to the DTD.  
          Assembly_accession was not defined.
        <br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.</td><td><a href="eSummary_dbvar.dtd">DTD</a>, <a href="eSummary_dbvar-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.dbvar.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=dbvar&amp;id=1272816">eutils;</a><br/><a href="esummary.dbvar.json">JSON</a></td></tr>
    <tr><th>epigenomics</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.</td><td><a href="eSummary_epigenomics.dtd">DTD</a>, <a href="eSummary_epigenomics-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.epigenomics.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=epigenomics&amp;id=16796">eutils;</a><br/><a href="esummary.epigenomics.json">JSON</a></td></tr>
    <tr><th>gencoll</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.<br/><a href="#-escaped-markup">⑤</a> 
          Escaped markup inside the &lt;Meta&gt; element.  This seems unnecessary in this
          case because the contents seem to be well-defined custom markup.
        </td><td><a href="eSummary_gencoll.dtd">DTD</a>, <a href="eSummary_gencoll-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.gencoll.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=gencoll&amp;id=320608">eutils;</a><br/><a href="esummary.gencoll.json">JSON</a></td></tr>
    <tr><th>gene</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.</td><td><a href="eSummary_gene.dtd">DTD</a>, <a href="eSummary_gene-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.gene.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=gene&amp;id=21803">eutils;</a><br/><a href="esummary.gene.json">JSON</a></td></tr>
    <tr><th>gds</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-xml-results-that-fail-to-validate-bad-dtds">②</a> 
          Instance document is not valid according to the DTD.  There was no declaration
          for &lt;ExtRelations&gt;.  I <em>guessed</em> that this should have the same content model as
          &lt;Relations&gt;.  No declaration for &lt;FTPLink&gt;, and based on the sample, I added this
          with text content.  No declaration for &lt;GEO2R&gt;.  The sample has value "yes", and I made
          this a JSON string, although boolean might be better.
        <br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.</td><td><a href="eSummary_gds.dtd">DTD</a>, <a href="eSummary_gds-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.gds.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=gds&amp;id=200040726">eutils;</a><br/><a href="esummary.gds.json">JSON</a></td></tr>
    <tr><th>geo</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.</td><td><a href="eSummary_geo.dtd">DTD</a>, <a href="eSummary_geo-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.geo.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=geo&amp;id=65685298">eutils;</a><br/><a href="esummary.geo.json">JSON</a></td></tr>
    <tr><th>geoprofiles</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-xml-results-that-fail-to-validate-bad-dtds">②</a> 
          Instance document is not valid.  Note that it <em>was</em> valid when I started this
          project, but as of 12/27/2012, something changed, and a new flavor of esummary was
          retrieved, which is no longer valid.  I found out about this through
          <a href="http://www.biostars.org/p/59755/">this Biostar</a> post.
        <br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.</td><td><a href="eSummary_geoprofiles.dtd">DTD</a>, <a href="eSummary_geoprofiles-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.geoprofiles.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=geoprofiles&amp;id=65526197">eutils;</a><br/><a href="esummary.geoprofiles.json">JSON</a></td></tr>
    <tr><th>homologene</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.</td><td><a href="eSummary_homologene.dtd">DTD</a>, <a href="eSummary_homologene-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.homologene.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=homologene&amp;id=20659">eutils;</a><br/><a href="esummary.homologene.json">JSON</a></td></tr>
    <tr><th>journals</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.</td><td><a href="eSummary_journals.dtd">DTD</a>, <a href="eSummary_journals-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.journals.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=journals&amp;id=35478">eutils;</a><br/><a href="esummary.journals.json">JSON</a></td></tr>
    <tr><th>medgen</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-xml-results-that-fail-to-validate-bad-dtds">②</a> 
          Can't find DTD; see EU-1908.
          I went ahead and created a DTD for this.  There's just enough detail to get
          the sample file to validate.  It might or might not be correct.
        <br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.<br/><a href="#-escaped-markup">⑤</a> 
          The &lt;ConceptMeta&gt; element has a lot of nice data that is inaccessible, because
          it is in escaped markup.
        </td><td><a href="eSummary_medgen.dtd">DTD</a>, <a href="eSummary_medgen-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.medgen.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=medgen&amp;id=122602">eutils;</a><br/><a href="esummary.medgen.json">JSON</a></td></tr>
    <tr><th>mesh</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.</td><td><a href="eSummary_mesh.dtd">DTD</a>, <a href="eSummary_mesh-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.mesh.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=mesh&amp;id=67414177">eutils;</a><br/><a href="esummary.mesh.json">JSON</a></td></tr>
    <tr><th>ncbisearch</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.</td><td><a href="eSummary_ncbisearch.dtd">DTD</a>, <a href="eSummary_ncbisearch-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.ncbisearch.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=ncbisearch&amp;id=1121">eutils;</a><br/><a href="esummary.ncbisearch.json">JSON</a></td></tr>
    <tr><th>nlmcatalog</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.</td><td><a href="eSummary_nlmcatalog.dtd">DTD</a>, <a href="eSummary_nlmcatalog-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.nlmcatalog.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=nlmcatalog&amp;id=101573253">eutils;</a><br/><a href="esummary.nlmcatalog.json">JSON</a></td></tr>
    <tr><th>omia</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.</td><td><a href="eSummary_omia.dtd">DTD</a>, <a href="eSummary_omia-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.omia.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=omia&amp;id=2615">eutils;</a><br/><a href="esummary.omia.json">JSON</a></td></tr>
    <tr><th>omim</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.</td><td><a href="eSummary_omim.dtd">DTD</a>, <a href="eSummary_omim-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.omim.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=omim&amp;id=609708">eutils;</a><br/><a href="esummary.omim.json">JSON</a></td></tr>
    <tr><th>pmc</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.</td><td><a href="eSummary_pmc.dtd">DTD</a>, <a href="eSummary_pmc-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.pmc.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=pmc&amp;id=254085,14900">eutils;</a><br/><a href="esummary.pmc.json">JSON</a></td></tr>

    <tr><th>pmc with error</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-xml-results-that-fail-to-validate-bad-dtds">②</a> 
          The XML results here were not valid according to the DTD.
          I added a declaration for the &lt;error&gt; element into the DTD. 
          I suspect that this is a problem for all the other esummary DTDs as 
          well, but I didn't try them with erroneous IDs.
        <br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.</td><td><a href="eSummary_pmc.dtd">DTD</a>, <a href="eSummary_pmc-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.pmcerror.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=pmc&amp;id=254085,1,14900">eutils;</a><br/><a href="esummary.pmcerror.json">JSON</a></td></tr>
    
    <tr><th>popset</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-xml-results-that-fail-to-validate-bad-dtds">②</a> 
          The instance document is invalid according to the DTD.
        <br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.</td><td><a href="eSummary_popset.dtd">DTD</a>, <a href="eSummary_popset-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.popset.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=popset&amp;id=418209882">eutils;</a><br/><a href="esummary.popset.json">JSON</a></td></tr>
    <tr><th>probe</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.</td><td><a href="eSummary_probe.dtd">DTD</a>, <a href="eSummary_probe-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.probe.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=probe&amp;id=156811">eutils;</a><br/><a href="esummary.probe.json">JSON</a></td></tr>
    <tr><th>proteinclusters</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.</td><td><a href="eSummary_proteinclusters.dtd">DTD</a>, <a href="eSummary_proteinclusters-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.proteinclusters.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=proteinclusters&amp;id=2516486">eutils;</a><br/><a href="esummary.proteinclusters.json">JSON</a></td></tr>
    <tr><th>pcassay</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.</td><td><a href="eSummary_pcassay.dtd">DTD</a>, <a href="eSummary_pcassay-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.pcassay.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=pcassay&amp;id=493206">eutils;</a><br/><a href="esummary.pcassay.json">JSON</a></td></tr>
    <tr><th>pccompound</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.</td><td><a href="eSummary_pccompound.dtd">DTD</a>, <a href="eSummary_pccompound-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.pccompound.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=pccompound&amp;id=10322165">eutils;</a><br/><a href="esummary.pccompound.json">JSON</a></td></tr>
    <tr><th>pcsubstance</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.</td><td><a href="eSummary_pcsubstance.dtd">DTD</a>, <a href="eSummary_pcsubstance-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.pcsubstance.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=pcsubstance&amp;id=127317050">eutils;</a><br/><a href="esummary.pcsubstance.json">JSON</a></td></tr>
    <tr><th>pubmedhealth</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-xml-results-that-fail-to-validate-bad-dtds">②</a> 
          Can't find DTD.  See EU-1908.  I created one by copying and hacking the books DTD.  Might or
          might not be correct.
        <br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.</td><td><a href="eSummary_pubmedhealth.dtd">DTD</a>, <a href="eSummary_pubmedhealth-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.pubmedhealth.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=pubmedhealth&amp;id=8625">eutils;</a><br/><a href="esummary.pubmedhealth.json">JSON</a></td></tr>
    <tr><th>seqannot</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.<br/><a href="#-escaped-markup">⑤</a> 
          The &lt;ExpXml&gt; element has a lot of very interesting data, which 
          unfortunately is inaccessible because it is in escaped markup.
        <br/>⇒ 
          The bulk of the data here is trapped inside the escaped-markup content
          of the &lt;ExpXml&gt; element.
        </td><td><a href="eSummary_seqannot.dtd">DTD</a>, <a href="eSummary_seqannot-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.seqannot.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=seqannot&amp;id=7232">eutils;</a><br/><a href="esummary.seqannot.json">JSON</a></td></tr>
    <tr><th>snp</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.</td><td><a href="eSummary_snp.dtd">DTD</a>, <a href="eSummary_snp-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.snp.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=snp&amp;id=206676795">eutils;</a><br/><a href="esummary.snp.json">JSON</a></td></tr>
    <tr><th>sra</th><td>✓</td><td><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.<br/><a href="#-escaped-markup">⑤</a> 
          Like seqannot, the bulk of the data here is trapped inside the escaped-markup content
          of the &lt;ExpXml&gt; element.  There is another escaped-markup element here, &lt;Runs&gt;, 
          which also has some nice but inaccessible data.
        </td><td><a href="eSummary_sra.dtd">DTD</a>, <a href="eSummary_sra-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.sra.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=sra&amp;id=30750">eutils;</a><br/><a href="esummary.sra.json">JSON</a></td></tr>
    <tr><th>taxonomy</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-xml-results-that-fail-to-validate-bad-dtds">②</a> 
          XML instance document is invalid.  Added &lt;Status&gt;, &lt;AkaTaxId&gt;, and
          &lt;ModificationDate&gt; to the DTD.
        <br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.</td><td><a href="eSummary_taxonomy.dtd">DTD</a>, <a href="eSummary_taxonomy-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.taxonomy.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=taxonomy&amp;id=9685">eutils;</a><br/><a href="esummary.taxonomy.json">JSON</a></td></tr>
    <tr><th>toolkit</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.<br/><a href="#-escaped-markup">⑤</a> 
          Has escaped markup inside an &lt;Xmlnote&gt; element.  I could understand this if the
          markup were HTML, designed to be injected into a web page, but it is not.  It appears
          to be a custom XML format, so, why not deliver it unescaped?
        </td><td><a href="eSummary_toolkit.dtd">DTD</a>, <a href="eSummary_toolkit-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.toolkit.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=toolkit&amp;id=149440">eutils;</a><br/><a href="esummary.toolkit.json">JSON</a></td></tr>
    <tr><th>unigene</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.</td><td><a href="eSummary_unigene.dtd">DTD</a>, <a href="eSummary_unigene-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.unigene.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=unigene&amp;id=1190943">eutils;</a><br/><a href="esummary.unigene.json">JSON</a></td></tr>
    <tr><th>unists</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-dtds-elements-that-are-under-specified">③</a> 
          In addition to the usual suspects,
          &lt;Map_Gene_Summary&gt; is under-specified.
        </td><td><a href="eSummary_unists.dtd">DTD</a>, <a href="eSummary_unists-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.unists.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=unists&amp;id=254085,254086">eutils;</a><br/><a href="esummary.unists.json">JSON</a></td></tr>
    <tr><th>error</th><td>✓</td><td><a href="#-all-esummary-dtds-use-the-same-public-identifier">①</a> Each ESummary DTD should have a unique public identifier.<br/><a href="#-dtds-elements-that-are-under-specified">③</a> All of the ESummary DTDs have elements that are underspecified.</td><td><a href="eSummary_041029.dtd">DTD</a>, <a href="eSummary_041029-2json.xsl">XSLT</a>;<br/>XML: <a href="esummary.error.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=error&amp;id=254088">eutils;</a><br/><a href="esummary.error.json">JSON</a></td></tr>
  </table>
  <h2>EFetch PubMed</h2>
  <table><tr><th/><th>✓</th><th>Description / Notes</th><th>Links</th></tr>
    <tr><th>PubMed</th><td>✓</td><td><em>This DTD is considerably more complicated than any of the ESummary DTDs.</em></td><td><a href="pubmed_120101.dtd">DTD</a>, <a href="pubmed_120101-2json.xsl">XSLT</a>;<br/>XML: <a href="efetch.pubmed.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&amp;id=17284678,9997&amp;retmode=xml">eutils;</a><br/><a href="efetch.pubmed.json">JSON</a></td></tr>
    <tr><th>Pubmed Book</th><td>✓</td><td/><td><a href="pubmed_120101.dtd">DTD</a>, <a href="pubmed_120101-2json.xsl">XSLT</a>;<br/>XML: <a href="efetch.pubmedbook.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&amp;id=20301295&amp;retmode=xml">eutils;</a><br/><a href="efetch.pubmedbook.json">JSON</a></td></tr>

    <tr><th>PubMed Example</th><td>✓</td><td><em>
          A contrived sample for testing.
        </em></td><td><a href="pubmed_120101.dtd">DTD</a>, <a href="pubmed_120101-2json.xsl">XSLT</a>;<br/>XML: <a href="efetch.pubmedexample.xml">local</a>, <a href="">eutils;</a><br/><a href="efetch.pubmedexample.json">JSON</a></td></tr>
    
  </table>
</div>
