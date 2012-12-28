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
utility to automatically generate XSLT files from the DTDs.  See
[the documentation](https://github.com/NCBITools/DtdAnalyzer/wiki/Auto-generating-XML-to-JSON-conversion-XSLT)
for an explanation of the general idea.  The command that generates the
XSLT is `dtd2xml2json`.

The DTDs here were pulled from the NCBI servers, and then annotated as
needed to instruct the `dtd2xml2json` utility how instance XML documents
should be converted into JSON.

The "work products" of this effort are the set of annotated DTDs and the
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

## Other scripts and utilities

We're keeping track of progress, notes, and problems in the `samples.xml` file here,
and then using that to generate the tables you see below.  The script `fixsamples.pl`
uses the XSLT stylesheet `fixsamples.xsl` to generate those HTML tables and merge
them into this README file.

The XSLT stylesheet `make-process-all.xsl` reads the list of all samples from
`samples.xml` file, and generates the `process-all.sh` script.

# Notes / Problems

## ① All ESummary DTDs use the same public identifier

* All the esummary example files use the public id "-//NLM//DTD eSummaryResult//EN"
  to refer to their DTDs, but different system identifiers.  This makes it more
  difficult to use OASIS catalog files with them, which is important to prevent
  external tools from hitting our servers every time they read an XML instance
  document.

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
    <tr><th>EInfo</th><td>✓</td><td><em>Basic EInfo result, list of all databases.</em></td><td><a href="../../blob/master/samples/eInfo_020511.dtd">DTD</a>, <a href="../../blob/master/samples/eInfo_020511-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/einfo.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/einfo.fcgi">eutils;</a><br/><a href="../../blob/master/samples/einfo.json">JSON</a></td></tr>
    <tr><th>EInfo PubMed</th><td>✓</td><td><em>Information about the PubMed database.</em><br/><font size="5"><a href="#%E2%91%A1-xml-results-that-fail-to-validate-bad-dtds">②</a> </font>
          &lt;Field&gt; element in the instance document doesn't follow the DTD.
          I fixed the DTD by making &lt;IsRangable&gt; [sic] and &lt;IsTruncatable&gt;
          optional.
        </td><td><a href="../../blob/master/samples/eInfo_020511.dtd">DTD</a>, <a href="../../blob/master/samples/eInfo_020511-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/einfo.pubmed.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/einfo.fcgi?db=pubmed">eutils;</a><br/><a href="../../blob/master/samples/einfo.pubmed.json">JSON</a></td></tr>
    <tr><th>EInfo Error</th><td>✓</td><td><em>Test an error response: invalid database name.</em></td><td><a href="../../blob/master/samples/eInfo_020511.dtd">DTD</a>, <a href="../../blob/master/samples/eInfo_020511-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/einfo.error.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/einfo.fcgi?db=fleegle">eutils;</a><br/><a href="../../blob/master/samples/einfo.error.json">JSON</a></td></tr>
  </table>
  <h2>ESearch</h2>
  <table><tr><th/><th>✓</th><th>Description / Notes</th><th>Links</th></tr>
    <tr><th>ESearch PubMed</th><td>✓</td><td><em>List of search results from PubMed.</em></td><td><a href="../../blob/master/samples/eSearch_020511.dtd">DTD</a>, <a href="../../blob/master/samples/eSearch_020511-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esearch.pubmed.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&amp;term=cancer&amp;reldate=60&amp;datetype=edat&amp;retmax=100&amp;usehistory=y">eutils;</a><br/><a href="../../blob/master/samples/esearch.pubmed.json">JSON</a></td></tr>
    <tr><th>ESearch Error</th><td>✓</td><td><em>Test an error response:  this query has a bad search term.</em></td><td><a href="../../blob/master/samples/eSearch_020511.dtd">DTD</a>, <a href="../../blob/master/samples/eSearch_020511-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esearch.error.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=nlmcatalog&amp;term=obstetrics%5bMeSH%20Terms%5d+OR+fleegle%5bMeSH%20Terms%5d">eutils;</a><br/><a href="../../blob/master/samples/esearch.error.json">JSON</a></td></tr>
    <tr><th>ESearch Bad Error</th><td>✓</td><td><em>Test an even worse error:  invalid db name specified.</em></td><td><a href="../../blob/master/samples/eSearch_020511.dtd">DTD</a>, <a href="../../blob/master/samples/eSearch_020511-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esearch.baderror.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=fleegle&amp;term=cat">eutils;</a><br/><a href="../../blob/master/samples/esearch.baderror.json">JSON</a></td></tr>
  </table>
  <h2>ESummary</h2>
  <table><tr><th/><th>✓</th><th>Description / Notes</th><th>Links</th></tr>
    <tr><th>pubmed</th><td>✓</td><td><font size="5"><a href="#%E2%91%A3-errors-in-dtds">④</a> </font>
          &lt;PubStatus&gt; is marked as type "T_int", but its value is not always
          an integer.
        </td><td><a href="../../blob/master/samples/eSummary_pubmed.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_pubmed-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.pubmed.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=pubmed&amp;id=5683731,22144687">eutils;</a><br/><a href="../../blob/master/samples/esummary.pubmed.json">JSON</a></td></tr>
    <tr><th>protein</th><td>✓</td><td/><td><a href="../../blob/master/samples/eSummary_protein.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_protein-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.protein.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=protein&amp;id=284822047">eutils;</a><br/><a href="../../blob/master/samples/esummary.protein.json">JSON</a></td></tr>
    <tr><th>nuccore</th><td>✓</td><td/><td><a href="../../blob/master/samples/eSummary_nuccore.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_nuccore-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.nuccore.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=nuccore&amp;id=424386131">eutils;</a><br/><a href="../../blob/master/samples/esummary.nuccore.json">JSON</a></td></tr>
    <tr><th>nucleotide</th><td>✓</td><td><font size="5"><a href="#%E2%91%A1-xml-results-that-fail-to-validate-bad-dtds">②</a> </font>
          The instance document is invalid according to the DTD.  I fixed the DTD,
          by adding some elements and attributes that were declared in eSummary_nuccore.dtd.
        </td><td><a href="../../blob/master/samples/eSummary_nucleotide.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_nucleotide-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.nucleotide.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=nucleotide&amp;id=424386131">eutils;</a><br/><a href="../../blob/master/samples/esummary.nucleotide.json">JSON</a></td></tr>
    <tr><th>nucgss</th><td>✓</td><td/><td><a href="../../blob/master/samples/eSummary_nucgss.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_nucgss-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.nucgss.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=nucgss&amp;id=371566079">eutils;</a><br/><a href="../../blob/master/samples/esummary.nucgss.json">JSON</a></td></tr>
    <tr><th>nucest</th><td>✓</td><td/><td><a href="../../blob/master/samples/eSummary_nucest.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_nucest-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.nucest.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=nucest&amp;id=409212211">eutils;</a><br/><a href="../../blob/master/samples/esummary.nucest.json">JSON</a></td></tr>
    <tr><th>structure</th><td>✓</td><td><font size="5"><a href="#%E2%91%A1-xml-results-that-fail-to-validate-bad-dtds">②</a> </font>
          Instance document is not valid according to the DTD.  The element PdbAccSynList
          is not declared.  We fixed the DTD by adding it.
        </td><td><a href="../../blob/master/samples/eSummary_structure.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_structure-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.structure.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=structure&amp;id=52770">eutils;</a><br/><a href="../../blob/master/samples/esummary.structure.json">JSON</a></td></tr>
    <tr><th>genome</th><td>✓</td><td><font size="5"><a href="#%E2%91%A1-xml-results-that-fail-to-validate-bad-dtds">②</a> </font>
          Instance document is not valid according to the DTD.  
          The elements Organism_Group and Organism_Subgroup were not declared, so
          we added them as strings.
        </td><td><a href="../../blob/master/samples/eSummary_genome.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_genome-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.genome.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=genome&amp;id=2640">eutils;</a><br/><a href="../../blob/master/samples/esummary.genome.json">JSON</a></td></tr>
    <tr><th>assembly</th><td>✓</td><td><font size="5"><a href="#%E2%91%A4-escaped-markup">⑤</a> </font>
          The element &lt;Meta&gt; contains some escaped markup, which makes it very hard to 
          extract into JSON.
        </td><td><a href="../../blob/master/samples/eSummary_assembly.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_assembly-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.assembly.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=assembly&amp;id=440818">eutils;</a><br/><a href="../../blob/master/samples/esummary.assembly.json">JSON</a></td></tr>
    <tr><th>gcassembly</th><td>✓</td><td><font size="5"><a href="#%E2%91%A1-xml-results-that-fail-to-validate-bad-dtds">②</a> </font>
          Instance document is not valid according to the DTD.  No definitions for
          &lt;SubmitterOrganization&gt; or &lt;AssemblyStatus&gt;.  I added the definitions for these from
          eSummary_assembly.dtd (which makes these two DTDs identical.)
        </td><td><a href="../../blob/master/samples/eSummary_gcassembly.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_gcassembly-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.gcassembly.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=gcassembly&amp;id=440818">eutils;</a><br/><a href="../../blob/master/samples/esummary.gcassembly.json">JSON</a></td></tr>
    <tr><th>genomeprj</th><td>✓</td><td/><td><a href="../../blob/master/samples/eSummary_genomeprj.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_genomeprj-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.genomeprj.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=genomeprj&amp;id=54101">eutils;</a><br/><a href="../../blob/master/samples/esummary.genomeprj.json">JSON</a></td></tr>
    <tr><th>bioproject</th><td>✓</td><td/><td><a href="../../blob/master/samples/eSummary_bioproject.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_bioproject-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.bioproject.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=bioproject&amp;id=171168">eutils;</a><br/><a href="../../blob/master/samples/esummary.bioproject.json">JSON</a></td></tr>
    <tr><th>biosample</th><td>✓</td><td/><td><a href="../../blob/master/samples/eSummary_biosample.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_biosample-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.biosample.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=biosample&amp;id=182293">eutils;</a><br/><a href="../../blob/master/samples/esummary.biosample.json">JSON</a></td></tr>
    <tr><th>biosystems</th><td>✓</td><td/><td><a href="../../blob/master/samples/eSummary_biosystems.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_biosystems-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.biosystems.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=biosystems&amp;id=493040">eutils;</a><br/><a href="../../blob/master/samples/esummary.biosystems.json">JSON</a></td></tr>
    <tr><th>blastdbinfo</th><td>✓</td><td/><td><a href="../../blob/master/samples/eSummary_blastdbinfo.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_blastdbinfo-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.blastdbinfo.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=blastdbinfo&amp;id=645844">eutils;</a><br/><a href="../../blob/master/samples/esummary.blastdbinfo.json">JSON</a></td></tr>
    <tr><th>books</th><td>✓</td><td><font size="5"><a href="#%E2%91%A4-escaped-markup">⑤</a> </font>
          The &lt;BookInfo&gt; element contains a lot of unfortunate escaped markup, in
          a CDATA section.
        </td><td><a href="../../blob/master/samples/eSummary_books.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_books-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.books.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=books&amp;id=2825746">eutils;</a><br/><a href="../../blob/master/samples/esummary.books.json">JSON</a></td></tr>
    <tr><th>cdd</th><td>✓</td><td/><td><a href="../../blob/master/samples/eSummary_cdd.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_cdd-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.cdd.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=cdd&amp;id=201140">eutils;</a><br/><a href="../../blob/master/samples/esummary.cdd.json">JSON</a></td></tr>
    <tr><th>clone</th><td>✓</td><td/><td><a href="../../blob/master/samples/eSummary_clone.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_clone-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.clone.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=clone&amp;id=29702171">eutils;</a><br/><a href="../../blob/master/samples/esummary.clone.json">JSON</a></td></tr>
    <tr><th>gap</th><td>✓</td><td/><td><a href="../../blob/master/samples/eSummary_gap.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_gap-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.gap.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=gap&amp;id=195331">eutils;</a><br/><a href="../../blob/master/samples/esummary.gap.json">JSON</a></td></tr>
    <tr><th>gapplus</th><td>✓</td><td><font size="5"><a href="#%E2%91%A1-xml-results-that-fail-to-validate-bad-dtds">②</a> </font>
          Instance document is not valid according to the DTD.  
          This DTD looks like it doesn't match the content very well.  I fixed it by adding
          elements until the instance document validated, but I don't have much confidence that
          the DTD I created is correct.
        <br/><font size="5"><a href="#%E2%91%A3-errors-in-dtds">④</a> </font>
          Element &lt;source&gt; is marked as "T_int", but its values
          in instance documents are not numbers, they are text strings.
        </td><td><a href="../../blob/master/samples/eSummary_gapplus.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_gapplus-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.gapplus.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=gapplus&amp;id=5235996">eutils;</a><br/><a href="../../blob/master/samples/esummary.gapplus.json">JSON</a></td></tr>
    <tr><th>dbvar</th><td>✓</td><td><font size="5"><a href="#%E2%91%A1-xml-results-that-fail-to-validate-bad-dtds">②</a> </font>
          Instance document is not valid according to the DTD.  
          Assembly_accession was not defined.
        </td><td><a href="../../blob/master/samples/eSummary_dbvar.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_dbvar-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.dbvar.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=dbvar&amp;id=1272816">eutils;</a><br/><a href="../../blob/master/samples/esummary.dbvar.json">JSON</a></td></tr>
    <tr><th>epigenomics</th><td>✓</td><td/><td><a href="../../blob/master/samples/eSummary_epigenomics.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_epigenomics-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.epigenomics.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=epigenomics&amp;id=16796">eutils;</a><br/><a href="../../blob/master/samples/esummary.epigenomics.json">JSON</a></td></tr>
    <tr><th>gencoll</th><td/><td><font size="5"><a href="#%E2%91%A4-escaped-markup">⑤</a> </font>
          Escaped markup inside the &lt;Meta&gt; element.  This seems unnecessary in this
          case because the contents seem to be well-defined custom markup.
        </td><td><a href="../../blob/master/samples/eSummary_gencoll.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_gencoll-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.gencoll.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=gencoll&amp;id=320608">eutils;</a><br/><a href="../../blob/master/samples/esummary.gencoll.json">JSON</a></td></tr>
    <tr><th>gene</th><td>✓</td><td/><td><a href="../../blob/master/samples/eSummary_gene.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_gene-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.gene.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=gene&amp;id=21803">eutils;</a><br/><a href="../../blob/master/samples/esummary.gene.json">JSON</a></td></tr>
    <tr><th>gds</th><td>✓</td><td><font size="5"><a href="#%E2%91%A1-xml-results-that-fail-to-validate-bad-dtds">②</a> </font>
          Instance document is not valid according to the DTD.  There was no declaration
          for &lt;ExtRelations&gt;.  I <em>guessed</em> that this should have the same content model as
          &lt;Relations&gt;.  No declaration for &lt;FTPLink&gt;, and based on the sample, I added this
          with text content.  No declaration for &lt;GEO2R&gt;.  The sample has value "yes", and I made
          this a JSON string, although boolean might be better.
        </td><td><a href="../../blob/master/samples/eSummary_gds.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_gds-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.gds.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=gds&amp;id=200040726">eutils;</a><br/><a href="../../blob/master/samples/esummary.gds.json">JSON</a></td></tr>
    <tr><th>geo</th><td>✓</td><td/><td><a href="../../blob/master/samples/eSummary_geo.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_geo-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.geo.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=geo&amp;id=65685298">eutils;</a><br/><a href="../../blob/master/samples/esummary.geo.json">JSON</a></td></tr>
    <tr><th>geoprofiles</th><td>✓</td><td><font size="5"><a href="#%E2%91%A1-xml-results-that-fail-to-validate-bad-dtds">②</a> </font>
          Instance document is not valid.  Note that it <em>was</em> valid when I started this
          project, but as of 12/27/2012, something changed, and a new flavor of esummary was
          retrieved, which is no longer valid.  I found out about this through
          <a href="http://www.biostars.org/p/59755/">this Biostar</a> post.
        </td><td><a href="../../blob/master/samples/eSummary_geoprofiles.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_geoprofiles-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.geoprofiles.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=geoprofiles&amp;id=65526197">eutils;</a><br/><a href="../../blob/master/samples/esummary.geoprofiles.json">JSON</a></td></tr>
    <tr><th>homologene</th><td>✓</td><td/><td><a href="../../blob/master/samples/eSummary_homologene.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_homologene-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.homologene.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=homologene&amp;id=20659">eutils;</a><br/><a href="../../blob/master/samples/esummary.homologene.json">JSON</a></td></tr>
    <tr><th>journals</th><td>✓</td><td/><td><a href="../../blob/master/samples/eSummary_journals.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_journals-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.journals.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=journals&amp;id=35478">eutils;</a><br/><a href="../../blob/master/samples/esummary.journals.json">JSON</a></td></tr>
    <tr><th>medgen</th><td>✓</td><td><font size="5"><a href="#%E2%91%A1-xml-results-that-fail-to-validate-bad-dtds">②</a> </font>
          Can't find DTD; see EU-1908.
          I went ahead and created a DTD for this.  There's just enough detail to get
          the sample file to validate.  It might or might not be correct.
        <br/><font size="5"><a href="#%E2%91%A4-escaped-markup">⑤</a> </font>
          The &lt;ConceptMeta&gt; element has a lot of nice data that is inaccessible, because
          it is in escaped markup.
        </td><td><a href="../../blob/master/samples/eSummary_medgen.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_medgen-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.medgen.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=medgen&amp;id=122602">eutils;</a><br/><a href="../../blob/master/samples/esummary.medgen.json">JSON</a></td></tr>
    <tr><th>mesh</th><td>✓</td><td/><td><a href="../../blob/master/samples/eSummary_mesh.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_mesh-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.mesh.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=mesh&amp;id=67414177">eutils;</a><br/><a href="../../blob/master/samples/esummary.mesh.json">JSON</a></td></tr>
    <tr><th>ncbisearch</th><td>✓</td><td/><td><a href="../../blob/master/samples/eSummary_ncbisearch.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_ncbisearch-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.ncbisearch.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=ncbisearch&amp;id=1121">eutils;</a><br/><a href="../../blob/master/samples/esummary.ncbisearch.json">JSON</a></td></tr>
    <tr><th>nlmcatalog</th><td>✓</td><td/><td><a href="../../blob/master/samples/eSummary_nlmcatalog.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_nlmcatalog-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.nlmcatalog.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=nlmcatalog&amp;id=101573253">eutils;</a><br/><a href="../../blob/master/samples/esummary.nlmcatalog.json">JSON</a></td></tr>
    <tr><th>omia</th><td>✓</td><td/><td><a href="../../blob/master/samples/eSummary_omia.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_omia-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.omia.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=omia&amp;id=2615">eutils;</a><br/><a href="../../blob/master/samples/esummary.omia.json">JSON</a></td></tr>
    <tr><th>omim</th><td>✓</td><td/><td><a href="../../blob/master/samples/eSummary_omim.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_omim-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.omim.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=omim&amp;id=609708">eutils;</a><br/><a href="../../blob/master/samples/esummary.omim.json">JSON</a></td></tr>
    <tr><th>pmc</th><td>✓</td><td/><td><a href="../../blob/master/samples/eSummary_pmc.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_pmc-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.pmc.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=pmc&amp;id=254085,14900">eutils;</a><br/><a href="../../blob/master/samples/esummary.pmc.json">JSON</a></td></tr>

    <tr><th>pmc with error</th><td>✓</td><td><font size="5"><a href="#%E2%91%A1-xml-results-that-fail-to-validate-bad-dtds">②</a> </font>
          The XML results here were not valid according to the DTD.
          I added a declaration for the &lt;error&gt; element into the DTD. 
          I suspect that this is a problem for all the other esummary DTDs as 
          well, but I didn't try them with erroneous IDs.
        </td><td><a href="../../blob/master/samples/eSummary_pmc.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_pmc-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.pmcerror.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=pmc&amp;id=254085,1,14900">eutils;</a><br/><a href="../../blob/master/samples/esummary.pmcerror.json">JSON</a></td></tr>
    
    <tr><th>popset</th><td>✓</td><td><font size="5"><a href="#%E2%91%A1-xml-results-that-fail-to-validate-bad-dtds">②</a> </font>
          The instance document is invalid according to the DTD.
        </td><td><a href="../../blob/master/samples/eSummary_popset.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_popset-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.popset.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=popset&amp;id=418209882">eutils;</a><br/><a href="../../blob/master/samples/esummary.popset.json">JSON</a></td></tr>
    <tr><th>probe</th><td>✓</td><td/><td><a href="../../blob/master/samples/eSummary_probe.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_probe-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.probe.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=probe&amp;id=156811">eutils;</a><br/><a href="../../blob/master/samples/esummary.probe.json">JSON</a></td></tr>
    <tr><th>proteinclusters</th><td>✓</td><td/><td><a href="../../blob/master/samples/eSummary_proteinclusters.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_proteinclusters-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.proteinclusters.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=proteinclusters&amp;id=2516486">eutils;</a><br/><a href="../../blob/master/samples/esummary.proteinclusters.json">JSON</a></td></tr>
    <tr><th>pcassay</th><td>✓</td><td/><td><a href="../../blob/master/samples/eSummary_pcassay.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_pcassay-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.pcassay.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=pcassay&amp;id=493206">eutils;</a><br/><a href="../../blob/master/samples/esummary.pcassay.json">JSON</a></td></tr>
    <tr><th>pccompound</th><td>✓</td><td/><td><a href="../../blob/master/samples/eSummary_pccompound.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_pccompound-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.pccompound.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=pccompound&amp;id=10322165">eutils;</a><br/><a href="../../blob/master/samples/esummary.pccompound.json">JSON</a></td></tr>
    <tr><th>pcsubstance</th><td>✓</td><td/><td><a href="../../blob/master/samples/eSummary_pcsubstance.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_pcsubstance-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.pcsubstance.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=pcsubstance&amp;id=127317050">eutils;</a><br/><a href="../../blob/master/samples/esummary.pcsubstance.json">JSON</a></td></tr>
    <tr><th>pubmedhealth</th><td>✓</td><td><font size="5"><a href="#%E2%91%A1-xml-results-that-fail-to-validate-bad-dtds">②</a> </font>
          Can't find DTD.  See EU-1908.  I created one by copying and hacking the books DTD.  Might or
          might not be correct.
        </td><td><a href="../../blob/master/samples/eSummary_pubmedhealth.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_pubmedhealth-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.pubmedhealth.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=pubmedhealth&amp;id=8625">eutils;</a><br/><a href="../../blob/master/samples/esummary.pubmedhealth.json">JSON</a></td></tr>
    <tr><th>seqannot</th><td>✓</td><td><font size="5"><a href="#%E2%91%A4-escaped-markup">⑤</a> </font>
          The &lt;ExpXml&gt; element has a lot of very interesting data, which 
          unfortunately is inaccessible because it is in escaped markup.
        <br/>⇒ 
          The bulk of the data here is trapped inside the escaped-markup content
          of the &lt;ExpXml&gt; element.
        </td><td><a href="../../blob/master/samples/eSummary_seqannot.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_seqannot-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.seqannot.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=seqannot&amp;id=7232">eutils;</a><br/><a href="../../blob/master/samples/esummary.seqannot.json">JSON</a></td></tr>
    <tr><th>snp</th><td>✓</td><td/><td><a href="../../blob/master/samples/eSummary_snp.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_snp-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.snp.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=snp&amp;id=206676795">eutils;</a><br/><a href="../../blob/master/samples/esummary.snp.json">JSON</a></td></tr>
    <tr><th>sra</th><td>✓</td><td><font size="5"><a href="#%E2%91%A4-escaped-markup">⑤</a> </font>
          Like seqannot, the bulk of the data here is trapped inside the escaped-markup content
          of the &lt;ExpXml&gt; element.  There is another escaped-markup element here, &lt;Runs&gt;, 
          which also has some nice but inaccessible data.
        </td><td><a href="../../blob/master/samples/eSummary_sra.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_sra-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.sra.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=sra&amp;id=30750">eutils;</a><br/><a href="../../blob/master/samples/esummary.sra.json">JSON</a></td></tr>
    <tr><th>taxonomy</th><td>✓</td><td><font size="5"><a href="#%E2%91%A1-xml-results-that-fail-to-validate-bad-dtds">②</a> </font>
          XML instance document is invalid.  Added &lt;Status&gt;, &lt;AkaTaxId&gt;, and
          &lt;ModificationDate&gt; to the DTD.
        </td><td><a href="../../blob/master/samples/eSummary_taxonomy.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_taxonomy-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.taxonomy.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=taxonomy&amp;id=9685">eutils;</a><br/><a href="../../blob/master/samples/esummary.taxonomy.json">JSON</a></td></tr>
    <tr><th>toolkit</th><td>✓</td><td><font size="5"><a href="#%E2%91%A4-escaped-markup">⑤</a> </font>
          Has escaped markup inside an &lt;Xmlnote&gt; element.  I could understand this if the
          markup were HTML, designed to be injected into a web page, but it is not.  It appears
          to be a custom XML format, so, why not deliver it unescaped?
        </td><td><a href="../../blob/master/samples/eSummary_toolkit.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_toolkit-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.toolkit.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=toolkit&amp;id=149440">eutils;</a><br/><a href="../../blob/master/samples/esummary.toolkit.json">JSON</a></td></tr>
    <tr><th>unigene</th><td>✓</td><td/><td><a href="../../blob/master/samples/eSummary_unigene.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_unigene-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.unigene.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=unigene&amp;id=1190943">eutils;</a><br/><a href="../../blob/master/samples/esummary.unigene.json">JSON</a></td></tr>
    <tr><th>unists</th><td>✓</td><td><font size="5"><a href="#%E2%91%A2-dtds-elements-that-are-under-specified">③</a> </font>
          &lt;Map_Gene_Summary&gt; is under-specified.
        </td><td><a href="../../blob/master/samples/eSummary_unists.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_unists-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.unists.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=unists&amp;id=254085,254086">eutils;</a><br/><a href="../../blob/master/samples/esummary.unists.json">JSON</a></td></tr>
    <tr><th>error</th><td>✓</td><td/><td><a href="../../blob/master/samples/eSummary_041029.dtd">DTD</a>, <a href="../../blob/master/samples/eSummary_041029-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/esummary.error.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=error&amp;id=254088">eutils;</a><br/><a href="../../blob/master/samples/esummary.error.json">JSON</a></td></tr>
  </table>
  <h2>EFetch PubMed</h2>
  <table><tr><th/><th>✓</th><th>Description / Notes</th><th>Links</th></tr>
    <tr><th>PubMed</th><td>✓</td><td>⇒ 
          This is the only one that uses an imported stylesheet, efetch.pubmed.xsl,
          because there were some
          things that the DTD annotation feature could not handle.
        </td><td><a href="../../blob/master/samples/pubmed_120101.dtd">DTD</a>, <a href="../../blob/master/samples/pubmed_120101-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/efetch.pubmed.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&amp;id=17284678,9997&amp;retmode=xml">eutils;</a><br/><a href="../../blob/master/samples/efetch.pubmed.json">JSON</a></td></tr>
    <tr><th>Pubmed Book</th><td>✓</td><td/><td><a href="../../blob/master/samples/pubmed_120101.dtd">DTD</a>, <a href="../../blob/master/samples/pubmed_120101-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/efetch.pubmedbook.xml">local</a>, <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&amp;id=20301295&amp;retmode=xml">eutils;</a><br/><a href="../../blob/master/samples/efetch.pubmedbook.json">JSON</a></td></tr>

    <tr><th>PubMed Example</th><td>✓</td><td><em>
          A contrived sample for testing.
        </em></td><td><a href="../../blob/master/samples/pubmed_120101.dtd">DTD</a>, <a href="../../blob/master/samples/pubmed_120101-2json.xsl">XSLT</a>;<br/>XML: <a href="../../blob/master/samples/efetch.pubmedexample.xml">local</a>, <a href="">eutils;</a><br/><a href="../../blob/master/samples/efetch.pubmedexample.json">JSON</a></td></tr>
    
  </table>
</div>
