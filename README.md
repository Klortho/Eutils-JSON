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


##Usage examples

You can just use xsltproc to try these out.  In the following examples, the sample output has been
piped through a pretty printer.

Example of [einfo](http://www.ncbi.nlm.nih.gov/books/NBK25499/#chapter4.EInfo)
([sample output](Eutils-JSON/blob/master/samples/einfo.json)):

    xsltproc Eutils2JSON.xsl http://eutils.ncbi.nlm.nih.gov/entrez/eutils/einfo.fcgi

Example of [einfo for pubmed](http://www.ncbi.nlm.nih.gov/books/NBK25499/#chapter4.EInfo)
([sample output](Eutils-JSON/blob/master/samples/einfo.pubmed.json)):

    xsltproc Eutils2JSON.xsl \
        http://eutils.ncbi.nlm.nih.gov/entrez/eutils/einfo.fcgi?db=pubmed

Example of [esummary for pubmed](http://www.ncbi.nlm.nih.gov/books/NBK25499/#chapter4.ESummary)
([sample output](Eutils-JSON/blob/master/samples/esummary.pubmed.json)):

    xsltproc Eutils2JSON.xsl \
        http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed\&id=5683731\&retmode=xml


##Author

The primary author of these is Mark Johnson.