# Samples / test cases

This directory has local copies of all the samples files.  The tables below are
auto-generated from samples.xml, where we're keeping track of the status of the
conversions.

The column "NCBI Eutils" gives a link to retrieve the original XML from the
NCBI site.  Note that because database contents are prone to change, the results
might differ from the locally stored xml file.

We are using the DtdAnalyzer utility to automatically generate XSLT files from
the DTDs.  To do this, first create a soft link to the DtdAnalyzer version of
the base stylesheet:

    ln -s /path-to-dtdanalyzer/xslt/xml2json.xsl

Then, to generate the XSLT, for example,

    dtd2xml2json -s eInfo_020511.dtd eInfo_020511-2json.xsl

Finally, run that against the instance document(s) to generate JSON output:

    xsltproc eInfo_020511-2json.xsl einfo.xml > einfo.json
    xsltproc eInfo_020511-2json.xsl einfo.pubmed.xml > einfo.pubmed.json
    xsltproc eInfo_020511-2json.xsl einfo.error.xml > einfo.error.json

As a validity check, you then should copy-paste the resultant JSON into
http://jsonlint.com/.  Note that it's really not enough to use a Javascript
utility to just read it in, because we want to use a strict validator that
looks for things like extraneous trailing commas in arrays and objects.

See also problems.md here for things that should be turned into JIRA tickets.

# Notes / Problems

## ① All ESummary DTDs use the same public identifier

* All the esummary example files use the public id "-//NLM//DTD eSummaryResult//EN"
  to refer to their DTDs, but different system identifiers.  This makes it more
  difficult to use OASIS catalog files with them, which is important to prevent
  external tools from hitting our servers every time they read an XML instance
  document.

## ② XML results that fail to validate (bad DTDs)

* esummary.pmcerror.xml, PMC esummary, with an erroroneous id:
  http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&version=2.0&db=pmc&id=254085,1,14900
  I had to add a declaration for the &lt;error&gt; element into the DTD.  I suspect
  that this is a problem for all the other esummary DTDs as well, but I didn't try
  them with erroneous IDs.

* esummary.nucleotide.xml

## ③ DTDs elements that are under-specified.

In many cases, the declarations in the DTDs are not optimal.  We often guessed at
the actual schema that the data would conform to, based on the example instance
document.  Sometimes, we might have guessed wrong.  See "Assumptions", below, for
a list.

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
is the most prominent example.  Sometimes we may have guessed wrong, but there were
so many examples of this, and it seemed to be such a common pattern, that I think we
were right.

In other words (if we were right) the DTDs specify these elements too loosely, and
that leads to problems when trying to write robust applications that should be able
to handle any instance document.  In our case, it causes some uncertainty about
whether or not our conversion to JSON is robust.

These DTD specs should be reviewed, and tightened up, where possible.

## ④ Errors in DTDs

* In eSummary_gapplus.dtd, element &lt;source> is marked as "T_int", but its values
  in instance documents are not numbers, they are text strings.

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
&lt;BookInfo> element.  For medgen, I can't see any reason for it.

Places where this is a problem:

* esummary.assembly.xml - in the &lt;Meta> element.
* eSummary_book.dtd - in &lt;BookInfo>
* esummary.medgen.xml  - in &lt;ConceptMeta>

## ⑥ Miscellaneous problems / questions / suggestions

### eSummary_blastdbinfo.dtd

This DTD has the following effective definitions:

    <!ELEMENT SourceDb "(SourceDbData)*">
    <!ELEMENT SourceDbData "(SrcDb)*">
    <!ELEMENT SrcDb "(#PCDATA)">

Why an array inside of an array?  First of all, are more than one value allowed?  Even
if so, then this could be flattened at least one level.

Likewise:

    <!ELEMENT Term "(TermData)*">
    <!ELEMENT TermData "(SearchTerm)*">
    <!ELEMENT SearchTerm "(#PCDATA)">



# Assumptions

[FIXME:  In fact, there were many more than are listed here.  Either go back and find
all the assumptions by looking at the added json annotations, or else abandon the attempt
to maintain this list.]

Here are some assumptions we made while mapping DTD elements to JSON.
These might be incorrect, which, in most cases, would mean that there would be
some XML instance documents that are valid according to the DTD that would
result in invalid JSON output.

## eSummary_bioproject.dtd
* &lt;Project_Objectives_Struct> → object

## eSummary_biosystems.dtd
* &lt;citation> → object
* &lt;gene> → object
* &lt;proteinstruct> → object

## eSummary_pmc.dtd
* &lt;Author> → object
* &lt;DocumentSummary> → object
* &lt;ArticleId> → object

## eSummary_unists.dtd
* &lt;DocumentSummary> → object
* &lt;Map_Gene_Summary> → object

## eSummary_nuccore.dtd
* &lt;DocumentSummarySet> → object; in this case, what if it contains Warnings?

# To do

* Go through all the sample DTDs once more for a quick check of which problems were
  encountered with which, and add "notes" markers to cross-reference them.


<!--
  DO NOT MODIFY BELOW THIS LINE.
  The stuff from here down is auto-generated, and any changes you make
  will be lost.  See the fixsamples.pl script.
-->

<div>
  <h2>EInfo</h2>
  <table>
    <tr>
      <th/>
      <th>Status</th>
      <th>Notes</th>
      <th>Comments</th>
      <th>Links</th>
    </tr>
    <tr>
      <th>EInfo</th>
      <td>D</td>
      <td/>
      <td>List all databases</td>
      <td><a href="../../blob/master/samples/eInfo_020511.dtd">DTD</a>,
          <a href="../../blob/master/samples/eInfo_020511-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/einfo.xml">XML</a>,
        <a href="../../blob/master/samples/einfo.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/einfo.fcgi">EUtils</a></td>
    </tr>
    <tr>
      <th>EInfo PubMed</th>
      <td>D</td>
      <td/>
      <td/>
      <td><a href="../../blob/master/samples/eInfo_020511.dtd">DTD</a>,
          <a href="../../blob/master/samples/eInfo_020511-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/einfo.pubmed.xml">XML</a>,
        <a href="../../blob/master/samples/einfo.pubmed.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/einfo.fcgi?db=pubmed">EUtils</a></td>
    </tr>
    <tr>
      <th>EInfo Error</th>
      <td>D</td>
      <td/>
      <td>Invalid database name</td>
      <td><a href="../../blob/master/samples/eInfo_020511.dtd">DTD</a>,
          <a href="../../blob/master/samples/eInfo_020511-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/einfo.error.xml">XML</a>,
        <a href="../../blob/master/samples/einfo.error.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/einfo.fcgi?db=fleegle">EUtils</a></td>
    </tr>
  </table>
  <h2>ESearch</h2>
  <table>
    <tr>
      <th/>
      <th>Status</th>
      <th>Notes</th>
      <th>Comments</th>
      <th>Links</th>
    </tr>
    <tr>
      <th>ESearch PubMed</th>
      <td>D</td>
      <td/>
      <td/>
      <td><a href="../../blob/master/samples/eSearch_020511.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSearch_020511-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esearch.pubmed.xml">XML</a>,
        <a href="../../blob/master/samples/esearch.pubmed.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&amp;term=cancer&amp;reldate=60&amp;datetype=edat&amp;retmax=100&amp;usehistory=y">EUtils</a></td>
    </tr>
    <tr>
      <th>ESearch Error</th>
      <td>D</td>
      <td/>
      <td>This query has a bad search term</td>
      <td><a href="../../blob/master/samples/eSearch_020511.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSearch_020511-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esearch.error.xml">XML</a>,
        <a href="../../blob/master/samples/esearch.error.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=nlmcatalog&amp;term=obstetrics%5bMeSH%20Terms%5d+OR+fleegle%5bMeSH%20Terms%5d">EUtils</a></td>
    </tr>
    <tr>
      <th>ESearch Bad Error</th>
      <td>D</td>
      <td/>
      <td>Invalid db name specified.</td>
      <td><a href="../../blob/master/samples/eSearch_020511.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSearch_020511-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esearch.baderror.xml">XML</a>,
        <a href="../../blob/master/samples/esearch.baderror.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=fleegle&amp;term=cat">EUtils</a></td>
    </tr>
  </table>
  <h2>ESummary</h2>
  <table>
    <tr>
      <th/>
      <th>Status</th>
      <th>Notes</th>
      <th>Comments</th>
      <th>Links</th>
    </tr>
    <tr>
      <th>ESummary pubmed</th>
      <td>D</td>
      <td/>
      <td/>
      <td><a href="../../blob/master/samples/eSummary_pubmed.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_pubmed-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.pubmed.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.pubmed.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=pubmed&amp;id=5683731,22144687">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary protein</th>
      <td>D</td>
      <td/>
      <td/>
      <td><a href="../../blob/master/samples/eSummary_protein.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_protein-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.protein.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.protein.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=protein&amp;id=284822047">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary nuccore</th>
      <td>D</td>
      <td/>
      <td/>
      <td><a href="../../blob/master/samples/eSummary_nuccore.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_nuccore-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.nuccore.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.nuccore.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=nuccore&amp;id=424386131">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary nucleotide</th>
      <td>D</td>
      <td/>
      <td>
        The instance document is invalid according to the DTD.  I fixed the DTD,
        by adding some elements and attributes that were declared in eSummary_nuccore.dtd.
      </td>
      <td><a href="../../blob/master/samples/eSummary_nucleotide.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_nucleotide-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.nucleotide.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.nucleotide.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=nucleotide&amp;id=424386131">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary nucgss</th>
      <td>D</td>
      <td/>
      <td/>
      <td><a href="../../blob/master/samples/eSummary_nucgss.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_nucgss-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.nucgss.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.nucgss.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=nucgss&amp;id=371566079">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary nucest</th>
      <td>D</td>
      <td/>
      <td/>
      <td><a href="../../blob/master/samples/eSummary_nucest.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_nucest-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.nucest.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.nucest.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=nucest&amp;id=409212211">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary structure</th>
      <td>D</td>
      <td/>
      <td>
        Instance document is not valid according to the DTD.  The element PdbAccSynList
        is not declared.  This requires us to create a special imported XSLT
        for this, esummary.structure.xsl.
      </td>
      <td><a href="../../blob/master/samples/eSummary_structure.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_structure-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.structure.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.structure.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=structure&amp;id=52770">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary genome</th>
      <td>D</td>
      <td/>
      <td>
        Instance document is not valid according to the DTD.  
        The elements Organism_Group and Organism_Subgroup were not declared, so
        I added them as strings.
      </td>
      <td><a href="../../blob/master/samples/eSummary_genome.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_genome-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.genome.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.genome.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=genome&amp;id=2640">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary assembly</th>
      <td>D</td>
      <td>⑤</td>
      <td/>
      <td><a href="../../blob/master/samples/eSummary_assembly.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_assembly-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.assembly.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.assembly.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=assembly&amp;id=440818">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary gcassembly</th>
      <td>D</td>
      <td/>
      <td>
        Instance document is not valid according to the DTD.  No definitions for
        SubmitterOrganization or AssemblyStatus.  I added the definitions for these from
        eSummary_assembly.dtd (which makes these two DTDs identical.)
      </td>
      <td><a href="../../blob/master/samples/eSummary_gcassembly.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_gcassembly-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.gcassembly.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.gcassembly.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=gcassembly&amp;id=440818">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary genomeprj</th>
      <td>D</td>
      <td/>
      <td/>
      <td><a href="../../blob/master/samples/eSummary_genomeprj.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_genomeprj-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.genomeprj.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.genomeprj.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=genomeprj&amp;id=54101">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary bioproject</th>
      <td>D</td>
      <td/>
      <td/>
      <td><a href="../../blob/master/samples/eSummary_bioproject.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_bioproject-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.bioproject.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.bioproject.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=bioproject&amp;id=171168">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary biosample</th>
      <td>D</td>
      <td/>
      <td/>
      <td><a href="../../blob/master/samples/eSummary_biosample.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_biosample-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.biosample.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.biosample.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=biosample&amp;id=182293">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary biosystems</th>
      <td>D</td>
      <td/>
      <td/>
      <td><a href="../../blob/master/samples/eSummary_biosystems.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_biosystems-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.biosystems.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.biosystems.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=biosystems&amp;id=493040">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary blastdbinfo</th>
      <td>D</td>
      <td/>
      <td/>
      <td><a href="../../blob/master/samples/eSummary_blastdbinfo.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_blastdbinfo-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.blastdbinfo.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.blastdbinfo.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=blastdbinfo&amp;id=645844">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary books</th>
      <td>D</td>
      <td>⑤</td>
      <td/>
      <td><a href="../../blob/master/samples/eSummary_books.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_books-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.books.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.books.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=books&amp;id=2825746">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary cdd</th>
      <td>D</td>
      <td/>
      <td/>
      <td><a href="../../blob/master/samples/eSummary_cdd.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_cdd-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.cdd.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.cdd.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=cdd&amp;id=201140">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary clone</th>
      <td>D</td>
      <td/>
      <td/>
      <td><a href="../../blob/master/samples/eSummary_clone.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_clone-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.clone.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.clone.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=clone&amp;id=29702171">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary gap</th>
      <td>D</td>
      <td/>
      <td/>
      <td><a href="../../blob/master/samples/eSummary_gap.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_gap-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.gap.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.gap.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=gap&amp;id=195331">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary gapplus</th>
      <td>D</td>
      <td/>
      <td>
        Instance document is not valid according to the DTD.  
        This DTD looks like it doesn't match the content very well.  I fixed it by adding
        elements until the instance document validated, but I don't have much confidence that
        the DTD I created is correct.
      </td>
      <td><a href="../../blob/master/samples/eSummary_gapplus.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_gapplus-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.gapplus.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.gapplus.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=gapplus&amp;id=5235996">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary dbvar</th>
      <td>D</td>
      <td/>
      <td>
        Instance document is not valid according to the DTD.  
        Assembly_accession is not defined.
      </td>
      <td><a href="../../blob/master/samples/eSummary_dbvar.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_dbvar-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.dbvar.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.dbvar.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=dbvar&amp;id=1272816">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary epigenomics</th>
      <td>D</td>
      <td/>
      <td/>
      <td><a href="../../blob/master/samples/eSummary_epigenomics.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_epigenomics-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.epigenomics.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.epigenomics.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=epigenomics&amp;id=16796">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary gene</th>
      <td>D</td>
      <td/>
      <td/>
      <td><a href="../../blob/master/samples/eSummary_gene.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_gene-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.gene.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.gene.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=gene&amp;id=21803">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary gds</th>
      <td>D</td>
      <td/>
      <td>
        Instance document is not valid according to the DTD.  There was no declaration
        for &lt;ExtRelations&gt;.  I guessed that this should have the same content model as
        &lt;Relations&gt;.  No declaration for &lt;FTPLink&gt;, and based on the sample, I added this
        with text content.  No declaration for &lt;GEO2R&gt;.  The sample has value "yes", and I made
        this a JSON string, although boolean might be better.
      </td>
      <td><a href="../../blob/master/samples/eSummary_gds.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_gds-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.gds.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.gds.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=gds&amp;id=200040726">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary geo</th>
      <td>D</td>
      <td/>
      <td/>
      <td><a href="../../blob/master/samples/eSummary_geo.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_geo-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.geo.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.geo.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=geo&amp;id=65685298">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary geoprofiles</th>
      <td>D</td>
      <td/>
      <td/>
      <td><a href="../../blob/master/samples/eSummary_geoprofiles.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_geoprofiles-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.geoprofiles.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.geoprofiles.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=geoprofiles&amp;id=65526197">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary homologene</th>
      <td>D</td>
      <td/>
      <td/>
      <td><a href="../../blob/master/samples/eSummary_homologene.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_homologene-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.homologene.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.homologene.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=homologene&amp;id=20659">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary journals</th>
      <td>D</td>
      <td/>
      <td/>
      <td><a href="../../blob/master/samples/eSummary_journals.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_journals-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.journals.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.journals.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=journals&amp;id=35478">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary medgen</th>
      <td>D</td>
      <td>⑤</td>
      <td>
        Can't find DTD; see EU-1908.
        I went ahead and created a DTD for this.  There's just enough detail to get
        the sample file to validate.  It might or might not be correct.
      </td>
      <td><a href="../../blob/master/samples/esummary.medgen.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.medgen.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=medgen&amp;id=122602">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary mesh</th>
      <td>D</td>
      <td/>
      <td/>
      <td><a href="../../blob/master/samples/eSummary_mesh.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_mesh-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.mesh.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.mesh.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=mesh&amp;id=67414177">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary ncbisearch</th>
      <td>D</td>
      <td/>
      <td/>
      <td><a href="../../blob/master/samples/eSummary_ncbisearch.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_ncbisearch-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.ncbisearch.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.ncbisearch.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=ncbisearch&amp;id=1121">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary nlmcatalog</th>
      <td>D</td>
      <td/>
      <td/>
      <td><a href="../../blob/master/samples/eSummary_nlmcatalog.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_nlmcatalog-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.nlmcatalog.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.nlmcatalog.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=nlmcatalog&amp;id=101573253">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary omia</th>
      <td>D</td>
      <td/>
      <td/>
      <td><a href="../../blob/master/samples/eSummary_omia.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_omia-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.omia.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.omia.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=omia&amp;id=2615">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary omim</th>
      <td>D</td>
      <td/>
      <td/>
      <td><a href="../../blob/master/samples/eSummary_omim.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_omim-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.omim.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.omim.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=omim&amp;id=609708">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary pmc</th>
      <td>D</td>
      <td/>
      <td/>
      <td><a href="../../blob/master/samples/eSummary_pmc.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_pmc-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.pmc.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.pmc.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=pmc&amp;id=254085,14900">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary pmc with error</th>
      <td>D</td>
      <td>②</td>
      <td>The XML results here are not valid according to the DTD. </td>
      <td><a href="../../blob/master/samples/eSummary_pmc.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_pmc-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.pmcerror.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.pmcerror.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=pmc&amp;id=254085,1,14900">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary popset</th>
      <td>D</td>
      <td/>
      <td>
        The instance document is invalid according to the DTD.
      </td>
      <td><a href="../../blob/master/samples/eSummary_popset.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_popset-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.popset.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.popset.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=popset&amp;id=418209882">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary probe</th>
      <td>D</td>
      <td/>
      <td/>
      <td><a href="../../blob/master/samples/eSummary_probe.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_probe-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.probe.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.probe.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=probe&amp;id=156811">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary proteinclusters</th>
      <td>D</td>
      <td/>
      <td/>
      <td><a href="../../blob/master/samples/eSummary_proteinclusters.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_proteinclusters-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.proteinclusters.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.proteinclusters.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=proteinclusters&amp;id=2516486">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary pcassay</th>
      <td>D</td>
      <td/>
      <td/>
      <td><a href="../../blob/master/samples/eSummary_pcassay.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_pcassay-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.pcassay.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.pcassay.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=pcassay&amp;id=493206">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary pccompound</th>
      <td>D</td>
      <td/>
      <td/>
      <td><a href="../../blob/master/samples/eSummary_pccompound.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_pccompound-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.pccompound.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.pccompound.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=pccompound&amp;id=10322165">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary pcsubstance</th>
      <td/>
      <td/>
      <td>
        XML instance document is empty.
      </td>
      <td><a href="../../blob/master/samples/eSummary_pcsubstance.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_pcsubstance-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.pcsubstance.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.pcsubstance.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=pcsubstance&amp;id=127317050">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary pubmedhealth</th>
      <td>✗</td>
      <td/>
      <td>Can't find DTD.  See EU-1908.</td>
      <td><a href="../../blob/master/samples/esummary.pubmedhealth.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.pubmedhealth.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=pubmedhealth&amp;id=8625">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary seqannot</th>
      <td/>
      <td/>
      <td>
        XML instance document is empty.
      </td>
      <td><a href="../../blob/master/samples/eSummary_seqannot.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_seqannot-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.seqannot.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.seqannot.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=seqannot&amp;id=7232">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary snp</th>
      <td/>
      <td/>
      <td>
        XML instance document is empty.
      </td>
      <td><a href="../../blob/master/samples/eSummary_snp.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_snp-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.snp.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.snp.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=snp&amp;id=206676795">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary sra</th>
      <td/>
      <td/>
      <td/>
      <td><a href="../../blob/master/samples/eSummary_sra.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_sra-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.sra.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.sra.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=sra&amp;id=30750">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary taxonomy</th>
      <td/>
      <td/>
      <td>
        XML instance document is invalid.
      </td>
      <td><a href="../../blob/master/samples/eSummary_taxonomy.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_taxonomy-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.taxonomy.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.taxonomy.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=taxonomy&amp;id=9685">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary toolkit</th>
      <td/>
      <td/>
      <td/>
      <td><a href="../../blob/master/samples/eSummary_toolkit.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_toolkit-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.toolkit.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.toolkit.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=toolkit&amp;id=149440">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary unigene</th>
      <td/>
      <td/>
      <td/>
      <td><a href="../../blob/master/samples/eSummary_unigene.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_unigene-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.unigene.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.unigene.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=unigene&amp;id=1190943">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary unists</th>
      <td>D</td>
      <td/>
      <td/>
      <td><a href="../../blob/master/samples/eSummary_unists.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_unists-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.unists.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.unists.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=unists&amp;id=254085,254086">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary gencoll</th>
      <td/>
      <td/>
      <td/>
      <td><a href="../../blob/master/samples/eSummary_gencoll.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_gencoll-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.gencoll.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.gencoll.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=gencoll&amp;id=320608">EUtils</a></td>
    </tr>
    <tr>
      <th>ESummary error</th>
      <td>D</td>
      <td/>
      <td/>
      <td><a href="../../blob/master/samples/eSummary_041029.dtd">DTD</a>,
          <a href="../../blob/master/samples/eSummary_041029-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/esummary.error.xml">XML</a>,
        <a href="../../blob/master/samples/esummary.error.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=error&amp;id=254088">EUtils</a></td>
    </tr>
  </table>
  <h2>EFetch</h2>
  <table>
    <tr>
      <th/>
      <th>Status</th>
      <th>Notes</th>
      <th>Comments</th>
      <th>Links</th>
    </tr>
    <tr>
      <th>PubMed</th>
      <td/>
      <td/>
      <td>
        This one is very complicated.  Note that I got a start on it before moving to DtdAnalyzer,
        with a manual stylesheet that is saved here:
        https://github.com/Klortho/Eutils-JSON/blob/7550961a849e14f53899ea9cc948a36e5903677e/Eutils2JSON.xsl.
        The JSON file, efetch.pubmed.json, here in the samples directory is the result of that
        output, and should be the goal.
      </td>
      <td><a href="../../blob/master/samples/pubmed_120101.dtd">DTD</a>,
          <a href="../../blob/master/samples/pubmed_120101-2json.xsl">XSL</a>,
        <a href="../../blob/master/samples/efetch.pubmed.xml">XML</a>,
        <a href="../../blob/master/samples/efetch.pubmed.json">JSON</a>,
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&amp;id=17284678,9997&amp;retmode=xml">EUtils</a></td>
    </tr>
  </table>
</div>
