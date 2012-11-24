Eutils-JSON
===========

Conversion XSLTs for NCBI [E-utilities](http://www.ncbi.nlm.nih.gov/books/NBK25501/) XML to JSON.

Please send us your feedback.

We are preparing to add JSON output format to NCBI E-utilities, and are making
this preliminary XSLT conversion available in order to solicit community feedback.

Please submit pull requests, create a github issue here, or send an email to
[eutilities@ncbi.nlm.nih.gov](mailto:eutilities@ncbi.nlm.nih.gov).

_We will implement this very soon, so send us feedback as soon as possible (preferably
by the end of November, 2012)._


##Samples

You can just use xsltproc to try these out.  For example,

    xsltproc Eutils2JSON.xsl http://eutils.ncbi.nlm.nih.gov/entrez/eutils/einfo.fcgi

### [Einfo](http://www.ncbi.nlm.nih.gov/books/NBK25499/#chapter4.EInfo)

#### ✓ List databases

http://eutils.ncbi.nlm.nih.gov/entrez/eutils/einfo.fcgi
([einfo.xml](klortho/samples/einfo.xml)),
([einfo.json](klortho/samples/einfo.json)),

#### ✓ Info about PubMed

http://eutils.ncbi.nlm.nih.gov/entrez/eutils/einfo.fcgi?db=pubmed
([einfo.pubmed.xml](klortho/samples/einfo.pubmed.xml)),
([einfo.pubmed.json](klortho/samples/einfo.pubmed.json)),

### [Esummary](http://www.ncbi.nlm.nih.gov/books/NBK25499/#chapter4.ESummary)

#### ✓ PubMed - version 1 DTD

http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&id=5683731,22144687&retmode=xml
([esummary.pubmed.xml](klortho/samples/esummary.pubmed.xml)),
([esummary.pubmed.json](klortho/samples/esummary.pubmed.json)),

#### - Unists - version 1 DTD

http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=unists&id=254085,254086
([esummary.unists.xml](klortho/samples/esummary.unists.xml)),
([esummary.unists.json](klortho/samples/esummary.unists.json)),


##Authors

Mark Johnson, Chris Maloney