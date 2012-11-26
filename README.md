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

##Samples / test cases

You can just use xsltproc to try these out.  For example,

    xsltproc Eutils2JSON.xsl http://eutils.ncbi.nlm.nih.gov/entrez/eutils/einfo.fcgi

See the samples directory here for an extensive list.

##Questions

* What is the str:decode-uri() doing in the np:q function?  Are some of these values
really URI-style percent encoded?

##Authors

Mark Johnson, Chris Maloney