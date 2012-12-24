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

# Problems

## All ESummary DTDs seem to use the same public identifier

* All the esummary example files use the public id "-//NLM//DTD eSummaryResult//EN"
  to refer to their DTDs, but different system identifiers.  This makes it more
  difficult to use OASIS catalog files with them, which is important to prevent
  external tools from hitting our servers every time they read an XML instance
  document.

## XML results that fail to validate

* esummary.pmcerror.xml, PMC esummary, with an erroroneous id:
  http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&version=2.0&db=pmc&id=254085,1,14900

* esummary.nucleotide.xml

## DTDs elements that are under-specified.

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

## Errors in DTDs

* In eSummary_gapplus.dtd, element &lt;source> is marked as "T_int", but its values
  in instance documents are not numbers, they are text strings.

## Miscellaneous places where the DTDs could be improved

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

### eSummary_book.dtd

Uses escaped-XML CDATA section for BookInfo.  This makes the data very hard to extract
for other applications, and in particular for conversion into JSON.  My guess is that
this is only done because you can have HTML markup inside the title.  If that's the
case, then the escaped-XML could be reserved to just the &lt;Title> element.

## Other

* esummary.assembly uses an ugly hack to get metadata into the output, including
  an escaped-xml section inside a "Meta" element.  This data will be very difficult to
  extract in JSON.


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
      <th>Local files</th>
      <th>Comments</th>
      <th>NCBI EUtils</th>
    </tr>
    <tr>
      <th>EInfo</th>
      <td>D</td>
      <td>
        <a href="../../blob/master/samples/eInfo_020511.dtd">eInfo_020511.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eInfo_020511-2json.xsl">eInfo_020511-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/einfo.xml">einfo.xml</a>
        <br/>
        <a href="../../blob/master/samples/einfo.json">einfo.json</a>
      </td>
      <td>List all databases</td>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/einfo.fcgi">get xml</a>
      </td>
    </tr>
    <tr>
      <th>EInfo PubMed</th>
      <td>D</td>
      <td>
        <a href="../../blob/master/samples/eInfo_020511.dtd">eInfo_020511.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eInfo_020511-2json.xsl">eInfo_020511-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/einfo.pubmed.xml">einfo.pubmed.xml</a>
        <br/>
        <a href="../../blob/master/samples/einfo.pubmed.json">einfo.pubmed.json</a>
      </td>
      <td/>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/einfo.fcgi?db=pubmed">get xml</a>
      </td>
    </tr>
    <tr>
      <th>EInfo Error</th>
      <td>D</td>
      <td>
        <a href="../../blob/master/samples/eInfo_020511.dtd">eInfo_020511.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eInfo_020511-2json.xsl">eInfo_020511-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/einfo.error.xml">einfo.error.xml</a>
        <br/>
        <a href="../../blob/master/samples/einfo.error.json">einfo.error.json</a>
      </td>
      <td>Invalid database name</td>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/einfo.fcgi?db=fleegle">get xml</a>
      </td>
    </tr>
  </table>
  <h2>ESearch</h2>
  <table>
    <tr>
      <th/>
      <th>Status</th>
      <th>Local files</th>
      <th>Comments</th>
      <th>NCBI EUtils</th>
    </tr>
    <tr>
      <th>ESearch PubMed</th>
      <td>D</td>
      <td>
        <a href="../../blob/master/samples/eSearch_020511.dtd">eSearch_020511.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSearch_020511-2json.xsl">eSearch_020511-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esearch.pubmed.xml">esearch.pubmed.xml</a>
        <br/>
        <a href="../../blob/master/samples/esearch.pubmed.json">esearch.pubmed.json</a>
      </td>
      <td/>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&amp;term=cancer&amp;reldate=60&amp;datetype=edat&amp;retmax=100&amp;usehistory=y">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESearch Error</th>
      <td>D</td>
      <td>
        <a href="../../blob/master/samples/eSearch_020511.dtd">eSearch_020511.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSearch_020511-2json.xsl">eSearch_020511-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esearch.error.xml">esearch.error.xml</a>
        <br/>
        <a href="../../blob/master/samples/esearch.error.json">esearch.error.json</a>
      </td>
      <td>This query has a bad search term</td>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=nlmcatalog&amp;term=obstetrics%5bMeSH%20Terms%5d+OR+fleegle%5bMeSH%20Terms%5d">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESearch Bad Error</th>
      <td>D</td>
      <td>
        <a href="../../blob/master/samples/eSearch_020511.dtd">eSearch_020511.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSearch_020511-2json.xsl">eSearch_020511-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esearch.baderror.xml">esearch.baderror.xml</a>
        <br/>
        <a href="../../blob/master/samples/esearch.baderror.json">esearch.baderror.json</a>
      </td>
      <td>Invalid db name specified.</td>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=fleegle&amp;term=cat">get xml</a>
      </td>
    </tr>
  </table>
  <h2>ESummary</h2>
  <table>
    <tr>
      <th/>
      <th>Status</th>
      <th>Local files</th>
      <th>Comments</th>
      <th>NCBI EUtils</th>
    </tr>
    <tr>
      <th>ESummary pubmed</th>
      <td>D</td>
      <td>
        <a href="../../blob/master/samples/eSummary_pubmed.dtd">eSummary_pubmed.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_pubmed-2json.xsl">eSummary_pubmed-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.pubmed.xml">esummary.pubmed.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.pubmed.json">esummary.pubmed.json</a>
      </td>
      <td/>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=pubmed&amp;id=5683731,22144687">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary protein</th>
      <td>D</td>
      <td>
        <a href="../../blob/master/samples/eSummary_protein.dtd">eSummary_protein.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_protein-2json.xsl">eSummary_protein-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.protein.xml">esummary.protein.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.protein.json">esummary.protein.json</a>
      </td>
      <td/>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=protein&amp;id=284822047">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary nuccore</th>
      <td>D</td>
      <td>
        <a href="../../blob/master/samples/eSummary_nuccore.dtd">eSummary_nuccore.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_nuccore-2json.xsl">eSummary_nuccore-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.nuccore.xml">esummary.nuccore.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.nuccore.json">esummary.nuccore.json</a>
      </td>
      <td/>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=nuccore&amp;id=424386131">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary nucleotide</th>
      <td>D</td>
      <td>
        <a href="../../blob/master/samples/eSummary_nucleotide.dtd">eSummary_nucleotide.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_nucleotide-2json.xsl">eSummary_nucleotide-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.nucleotide.xml">esummary.nucleotide.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.nucleotide.json">esummary.nucleotide.json</a>
      </td>
      <td>
        The instance document is invalid according to the DTD.  I fixed the DTD,
        by adding some elements and attributes that were declared in eSummary_nuccore.dtd.
      </td>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=nucleotide&amp;id=424386131">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary nucgss</th>
      <td>D</td>
      <td>
        <a href="../../blob/master/samples/eSummary_nucgss.dtd">eSummary_nucgss.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_nucgss-2json.xsl">eSummary_nucgss-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.nucgss.xml">esummary.nucgss.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.nucgss.json">esummary.nucgss.json</a>
      </td>
      <td/>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=nucgss&amp;id=371566079">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary nucest</th>
      <td>D</td>
      <td>
        <a href="../../blob/master/samples/eSummary_nucest.dtd">eSummary_nucest.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_nucest-2json.xsl">eSummary_nucest-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.nucest.xml">esummary.nucest.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.nucest.json">esummary.nucest.json</a>
      </td>
      <td/>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=nucest&amp;id=409212211">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary structure</th>
      <td>D</td>
      <td>
        <a href="../../blob/master/samples/eSummary_structure.dtd">eSummary_structure.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_structure-2json.xsl">eSummary_structure-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.structure.xml">esummary.structure.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.structure.json">esummary.structure.json</a>
      </td>
      <td>
        Instance document is not valid according to the DTD.  The element PdbAccSynList
        is not declared.  This requires us to create a special imported XSLT
        for this, esummary.structure.xsl.
      </td>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=structure&amp;id=52770">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary genome</th>
      <td>D</td>
      <td>
        <a href="../../blob/master/samples/eSummary_genome.dtd">eSummary_genome.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_genome-2json.xsl">eSummary_genome-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.genome.xml">esummary.genome.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.genome.json">esummary.genome.json</a>
      </td>
      <td>
        Instance document is not valid according to the DTD.  
        The elements Organism_Group and Organism_Subgroup were not declared, so
        I added them as strings.
      </td>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=genome&amp;id=2640">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary assembly</th>
      <td>D</td>
      <td>
        <a href="../../blob/master/samples/eSummary_assembly.dtd">eSummary_assembly.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_assembly-2json.xsl">eSummary_assembly-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.assembly.xml">esummary.assembly.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.assembly.json">esummary.assembly.json</a>
      </td>
      <td/>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=assembly&amp;id=440818">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary gcassembly</th>
      <td>D</td>
      <td>
        <a href="../../blob/master/samples/eSummary_gcassembly.dtd">eSummary_gcassembly.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_gcassembly-2json.xsl">eSummary_gcassembly-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.gcassembly.xml">esummary.gcassembly.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.gcassembly.json">esummary.gcassembly.json</a>
      </td>
      <td>
        Instance document is not valid according to the DTD.  No definitions for
        SubmitterOrganization or AssemblyStatus.  I added the definitions for these from
        eSummary_assembly.dtd (which makes these two DTDs identical.)
      </td>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=gcassembly&amp;id=440818">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary genomeprj</th>
      <td>D</td>
      <td>
        <a href="../../blob/master/samples/eSummary_genomeprj.dtd">eSummary_genomeprj.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_genomeprj-2json.xsl">eSummary_genomeprj-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.genomeprj.xml">esummary.genomeprj.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.genomeprj.json">esummary.genomeprj.json</a>
      </td>
      <td/>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=genomeprj&amp;id=54101">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary bioproject</th>
      <td>D</td>
      <td>
        <a href="../../blob/master/samples/eSummary_bioproject.dtd">eSummary_bioproject.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_bioproject-2json.xsl">eSummary_bioproject-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.bioproject.xml">esummary.bioproject.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.bioproject.json">esummary.bioproject.json</a>
      </td>
      <td/>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=bioproject&amp;id=171168">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary biosample</th>
      <td>D</td>
      <td>
        <a href="../../blob/master/samples/eSummary_biosample.dtd">eSummary_biosample.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_biosample-2json.xsl">eSummary_biosample-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.biosample.xml">esummary.biosample.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.biosample.json">esummary.biosample.json</a>
      </td>
      <td/>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=biosample&amp;id=182293">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary biosystems</th>
      <td>D</td>
      <td>
        <a href="../../blob/master/samples/eSummary_biosystems.dtd">eSummary_biosystems.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_biosystems-2json.xsl">eSummary_biosystems-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.biosystems.xml">esummary.biosystems.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.biosystems.json">esummary.biosystems.json</a>
      </td>
      <td/>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=biosystems&amp;id=493040">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary blastdbinfo</th>
      <td>D</td>
      <td>
        <a href="../../blob/master/samples/eSummary_blastdbinfo.dtd">eSummary_blastdbinfo.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_blastdbinfo-2json.xsl">eSummary_blastdbinfo-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.blastdbinfo.xml">esummary.blastdbinfo.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.blastdbinfo.json">esummary.blastdbinfo.json</a>
      </td>
      <td/>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=blastdbinfo&amp;id=645844">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary books</th>
      <td>D</td>
      <td>
        <a href="../../blob/master/samples/eSummary_books.dtd">eSummary_books.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_books-2json.xsl">eSummary_books-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.books.xml">esummary.books.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.books.json">esummary.books.json</a>
      </td>
      <td/>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=books&amp;id=2825746">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary cdd</th>
      <td>D</td>
      <td>
        <a href="../../blob/master/samples/eSummary_cdd.dtd">eSummary_cdd.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_cdd-2json.xsl">eSummary_cdd-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.cdd.xml">esummary.cdd.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.cdd.json">esummary.cdd.json</a>
      </td>
      <td/>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=cdd&amp;id=201140">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary clone</th>
      <td>D</td>
      <td>
        <a href="../../blob/master/samples/eSummary_clone.dtd">eSummary_clone.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_clone-2json.xsl">eSummary_clone-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.clone.xml">esummary.clone.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.clone.json">esummary.clone.json</a>
      </td>
      <td/>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=clone&amp;id=29702171">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary gap</th>
      <td>D</td>
      <td>
        <a href="../../blob/master/samples/eSummary_gap.dtd">eSummary_gap.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_gap-2json.xsl">eSummary_gap-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.gap.xml">esummary.gap.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.gap.json">esummary.gap.json</a>
      </td>
      <td/>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=gap&amp;id=195331">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary gapplus</th>
      <td>D</td>
      <td>
        <a href="../../blob/master/samples/eSummary_gapplus.dtd">eSummary_gapplus.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_gapplus-2json.xsl">eSummary_gapplus-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.gapplus.xml">esummary.gapplus.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.gapplus.json">esummary.gapplus.json</a>
      </td>
      <td>
        Instance document is not valid according to the DTD.  
        This DTD looks like it doesn't match the content very well.  I fixed it by adding
        elements until the instance document validated, but I don't have much confidence that
        the DTD I created is correct.
      </td>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=gapplus&amp;id=5235996">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary dbvar</th>
      <td>D</td>
      <td>
        <a href="../../blob/master/samples/eSummary_dbvar.dtd">eSummary_dbvar.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_dbvar-2json.xsl">eSummary_dbvar-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.dbvar.xml">esummary.dbvar.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.dbvar.json">esummary.dbvar.json</a>
      </td>
      <td>
        Instance document is not valid according to the DTD.  
        Assembly_accession is not defined.
      </td>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=dbvar&amp;id=1272816">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary epigenomics</th>
      <td>D</td>
      <td>
        <a href="../../blob/master/samples/eSummary_epigenomics.dtd">eSummary_epigenomics.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_epigenomics-2json.xsl">eSummary_epigenomics-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.epigenomics.xml">esummary.epigenomics.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.epigenomics.json">esummary.epigenomics.json</a>
      </td>
      <td/>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=epigenomics&amp;id=16796">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary gene</th>
      <td>D</td>
      <td>
        <a href="../../blob/master/samples/eSummary_gene.dtd">eSummary_gene.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_gene-2json.xsl">eSummary_gene-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.gene.xml">esummary.gene.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.gene.json">esummary.gene.json</a>
      </td>
      <td/>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=gene&amp;id=21803">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary gds</th>
      <td>D</td>
      <td>
        <a href="../../blob/master/samples/eSummary_gds.dtd">eSummary_gds.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_gds-2json.xsl">eSummary_gds-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.gds.xml">esummary.gds.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.gds.json">esummary.gds.json</a>
      </td>
      <td>
        Instance document is not valid according to the DTD.  There was no declaration
        for &lt;ExtRelations&gt;.  I guessed that this should have the same content model as
        &lt;Relations&gt;.  No declaration for &lt;FTPLink&gt;, and based on the sample, I added this
        with text content.  No declaration for &lt;GEO2R&gt;.  The sample has value "yes", and I made
        this a JSON string, although boolean might be better.
      </td>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=gds&amp;id=200040726">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary geo</th>
      <td>D</td>
      <td>
        <a href="../../blob/master/samples/eSummary_geo.dtd">eSummary_geo.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_geo-2json.xsl">eSummary_geo-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.geo.xml">esummary.geo.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.geo.json">esummary.geo.json</a>
      </td>
      <td/>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=geo&amp;id=65685298">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary geoprofiles</th>
      <td>D</td>
      <td>
        <a href="../../blob/master/samples/eSummary_geoprofiles.dtd">eSummary_geoprofiles.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_geoprofiles-2json.xsl">eSummary_geoprofiles-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.geoprofiles.xml">esummary.geoprofiles.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.geoprofiles.json">esummary.geoprofiles.json</a>
      </td>
      <td/>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=geoprofiles&amp;id=65526197">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary homologene</th>
      <td/>
      <td>
        <a href="../../blob/master/samples/eSummary_homologene.dtd">eSummary_homologene.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_homologene-2json.xsl">eSummary_homologene-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.homologene.xml">esummary.homologene.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.homologene.json">esummary.homologene.json</a>
      </td>
      <td/>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=homologene&amp;id=20659">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary journals</th>
      <td/>
      <td>
        <a href="../../blob/master/samples/eSummary_journals.dtd">eSummary_journals.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_journals-2json.xsl">eSummary_journals-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.journals.xml">esummary.journals.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.journals.json">esummary.journals.json</a>
      </td>
      <td/>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=journals&amp;id=35478">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary medgen</th>
      <td>✗</td>
      <td>
        <a href="../../blob/master/samples/esummary.medgen.xml">esummary.medgen.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.medgen.json">esummary.medgen.json</a>
      </td>
      <td>Can't find DTD; see EU-1908.</td>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=medgen&amp;id=122602">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary mesh</th>
      <td/>
      <td>
        <a href="../../blob/master/samples/eSummary_mesh.dtd">eSummary_mesh.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_mesh-2json.xsl">eSummary_mesh-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.mesh.xml">esummary.mesh.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.mesh.json">esummary.mesh.json</a>
      </td>
      <td/>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=mesh&amp;id=67414177">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary ncbisearch</th>
      <td/>
      <td>
        <a href="../../blob/master/samples/eSummary_ncbisearch.dtd">eSummary_ncbisearch.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_ncbisearch-2json.xsl">eSummary_ncbisearch-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.ncbisearch.xml">esummary.ncbisearch.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.ncbisearch.json">esummary.ncbisearch.json</a>
      </td>
      <td/>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=ncbisearch&amp;id=1121">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary nlmcatalog</th>
      <td/>
      <td>
        <a href="../../blob/master/samples/eSummary_nlmcatalog.dtd">eSummary_nlmcatalog.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_nlmcatalog-2json.xsl">eSummary_nlmcatalog-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.nlmcatalog.xml">esummary.nlmcatalog.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.nlmcatalog.json">esummary.nlmcatalog.json</a>
      </td>
      <td/>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=nlmcatalog&amp;id=101573253">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary omia</th>
      <td/>
      <td>
        <a href="../../blob/master/samples/eSummary_omia.dtd">eSummary_omia.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_omia-2json.xsl">eSummary_omia-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.omia.xml">esummary.omia.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.omia.json">esummary.omia.json</a>
      </td>
      <td/>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=omia&amp;id=2615">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary omim</th>
      <td/>
      <td>
        <a href="../../blob/master/samples/eSummary_omim.dtd">eSummary_omim.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_omim-2json.xsl">eSummary_omim-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.omim.xml">esummary.omim.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.omim.json">esummary.omim.json</a>
      </td>
      <td/>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=omim&amp;id=609708">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary pmc</th>
      <td>D</td>
      <td>
        <a href="../../blob/master/samples/eSummary_pmc.dtd">eSummary_pmc.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_pmc-2json.xsl">eSummary_pmc-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.pmc.xml">esummary.pmc.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.pmc.json">esummary.pmc.json</a>
      </td>
      <td/>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=pmc&amp;id=254085,14900">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary pmc with error</th>
      <td>✗</td>
      <td>
        <a href="../../blob/master/samples/eSummary_pmc.dtd">eSummary_pmc.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_pmc-2json.xsl">eSummary_pmc-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.pmcerror.xml">esummary.pmcerror.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.pmcerror.json">esummary.pmcerror.json</a>
      </td>
      <td>The XML results here are not valid according to the DTD.  Need to open a JIRA ticket.</td>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=pmc&amp;id=254085,1,14900">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary popset</th>
      <td/>
      <td>
        <a href="../../blob/master/samples/eSummary_popset.dtd">eSummary_popset.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_popset-2json.xsl">eSummary_popset-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.popset.xml">esummary.popset.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.popset.json">esummary.popset.json</a>
      </td>
      <td>
        The instance document is invalid according to the DTD.
      </td>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=popset&amp;id=418209882">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary probe</th>
      <td/>
      <td>
        <a href="../../blob/master/samples/eSummary_probe.dtd">eSummary_probe.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_probe-2json.xsl">eSummary_probe-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.probe.xml">esummary.probe.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.probe.json">esummary.probe.json</a>
      </td>
      <td/>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=probe&amp;id=156811">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary proteinclusters</th>
      <td/>
      <td>
        <a href="../../blob/master/samples/eSummary_proteinclusters.dtd">eSummary_proteinclusters.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_proteinclusters-2json.xsl">eSummary_proteinclusters-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.proteinclusters.xml">esummary.proteinclusters.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.proteinclusters.json">esummary.proteinclusters.json</a>
      </td>
      <td/>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=proteinclusters&amp;id=2516486">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary pcassay</th>
      <td/>
      <td>
        <a href="../../blob/master/samples/eSummary_pcassay.dtd">eSummary_pcassay.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_pcassay-2json.xsl">eSummary_pcassay-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.pcassay.xml">esummary.pcassay.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.pcassay.json">esummary.pcassay.json</a>
      </td>
      <td/>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=pcassay&amp;id=493206">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary pccompound</th>
      <td/>
      <td>
        <a href="../../blob/master/samples/eSummary_pccompound.dtd">eSummary_pccompound.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_pccompound-2json.xsl">eSummary_pccompound-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.pccompound.xml">esummary.pccompound.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.pccompound.json">esummary.pccompound.json</a>
      </td>
      <td/>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=pccompound&amp;id=10322165">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary pcsubstance</th>
      <td/>
      <td>
        <a href="../../blob/master/samples/eSummary_pcsubstance.dtd">eSummary_pcsubstance.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_pcsubstance-2json.xsl">eSummary_pcsubstance-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.pcsubstance.xml">esummary.pcsubstance.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.pcsubstance.json">esummary.pcsubstance.json</a>
      </td>
      <td>
        XML instance document is empty.
      </td>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=pcsubstance&amp;id=127317050">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary pubmedhealth</th>
      <td>✗</td>
      <td>
        <a href="../../blob/master/samples/esummary.pubmedhealth.xml">esummary.pubmedhealth.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.pubmedhealth.json">esummary.pubmedhealth.json</a>
      </td>
      <td>Can't find DTD.  See EU-1908.</td>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=pubmedhealth&amp;id=8625">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary seqannot</th>
      <td/>
      <td>
        <a href="../../blob/master/samples/eSummary_seqannot.dtd">eSummary_seqannot.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_seqannot-2json.xsl">eSummary_seqannot-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.seqannot.xml">esummary.seqannot.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.seqannot.json">esummary.seqannot.json</a>
      </td>
      <td>
        XML instance document is empty.
      </td>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=seqannot&amp;id=7232">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary snp</th>
      <td/>
      <td>
        <a href="../../blob/master/samples/eSummary_snp.dtd">eSummary_snp.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_snp-2json.xsl">eSummary_snp-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.snp.xml">esummary.snp.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.snp.json">esummary.snp.json</a>
      </td>
      <td>
        XML instance document is empty.
      </td>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=snp&amp;id=206676795">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary sra</th>
      <td/>
      <td>
        <a href="../../blob/master/samples/eSummary_sra.dtd">eSummary_sra.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_sra-2json.xsl">eSummary_sra-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.sra.xml">esummary.sra.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.sra.json">esummary.sra.json</a>
      </td>
      <td/>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=sra&amp;id=30750">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary taxonomy</th>
      <td/>
      <td>
        <a href="../../blob/master/samples/eSummary_taxonomy.dtd">eSummary_taxonomy.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_taxonomy-2json.xsl">eSummary_taxonomy-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.taxonomy.xml">esummary.taxonomy.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.taxonomy.json">esummary.taxonomy.json</a>
      </td>
      <td>
        XML instance document is invalid.
      </td>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=taxonomy&amp;id=9685">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary toolkit</th>
      <td/>
      <td>
        <a href="../../blob/master/samples/eSummary_toolkit.dtd">eSummary_toolkit.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_toolkit-2json.xsl">eSummary_toolkit-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.toolkit.xml">esummary.toolkit.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.toolkit.json">esummary.toolkit.json</a>
      </td>
      <td/>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=toolkit&amp;id=149440">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary unigene</th>
      <td/>
      <td>
        <a href="../../blob/master/samples/eSummary_unigene.dtd">eSummary_unigene.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_unigene-2json.xsl">eSummary_unigene-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.unigene.xml">esummary.unigene.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.unigene.json">esummary.unigene.json</a>
      </td>
      <td/>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=unigene&amp;id=1190943">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary unists</th>
      <td>D</td>
      <td>
        <a href="../../blob/master/samples/eSummary_unists.dtd">eSummary_unists.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_unists-2json.xsl">eSummary_unists-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.unists.xml">esummary.unists.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.unists.json">esummary.unists.json</a>
      </td>
      <td/>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=unists&amp;id=254085,254086">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary gencoll</th>
      <td/>
      <td>
        <a href="../../blob/master/samples/eSummary_gencoll.dtd">eSummary_gencoll.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_gencoll-2json.xsl">eSummary_gencoll-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.gencoll.xml">esummary.gencoll.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.gencoll.json">esummary.gencoll.json</a>
      </td>
      <td/>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=gencoll&amp;id=320608">get xml</a>
      </td>
    </tr>
    <tr>
      <th>ESummary error</th>
      <td>D</td>
      <td>
        <a href="../../blob/master/samples/eSummary_041029.dtd">eSummary_041029.dtd</a>
        <br/>
        <a href="../../blob/master/samples/eSummary_041029-2json.xsl">eSummary_041029-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/esummary.error.xml">esummary.error.xml</a>
        <br/>
        <a href="../../blob/master/samples/esummary.error.json">esummary.error.json</a>
      </td>
      <td/>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&amp;version=2.0&amp;db=error&amp;id=254088">get xml</a>
      </td>
    </tr>
  </table>
  <h2>EFetch</h2>
  <table>
    <tr>
      <th/>
      <th>Status</th>
      <th>Local files</th>
      <th>Comments</th>
      <th>NCBI EUtils</th>
    </tr>
    <tr>
      <th>PubMed</th>
      <td/>
      <td>
        <a href="../../blob/master/samples/pubmed_120101.dtd">pubmed_120101.dtd</a>
        <br/>
        <a href="../../blob/master/samples/pubmed_120101-2json.xsl">pubmed_120101-2json.xsl</a>
        <br/>
        <a href="../../blob/master/samples/efetch.pubmed.xml">efetch.pubmed.xml</a>
        <br/>
        <a href="../../blob/master/samples/efetch.pubmed.json">efetch.pubmed.json</a>
      </td>
      <td>
        This one is very complicated.  Note that I got a start on it before moving to DtdAnalyzer,
        with a manual stylesheet that is saved here:
        https://github.com/Klortho/Eutils-JSON/blob/7550961a849e14f53899ea9cc948a36e5903677e/Eutils2JSON.xsl.
        The JSON file, efetch.pubmed.json, here in the samples directory is the result of that
        output, and should be the goal.
      </td>
      <td>
        <a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&amp;id=17284678,9997&amp;retmode=xml">get xml</a>
      </td>
    </tr>
  </table>
</div>
