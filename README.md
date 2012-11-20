Eutils-JSON
===========

Conversion XSLTs for NCBI [E-utilities](http://www.ncbi.nlm.nih.gov/books/NBK25501/) XML to JSON.

==Usage examples==

You can just use xsltproc to try these out.  For example:

    xsltproc Eutils2JSON.xsl http://eutils.ncbi.nlm.nih.gov/entrez/eutils/einfo.fcgi
    xsltproc Eutils2JSON.xsl \
        http://eutils.ncbi.nlm.nih.gov/entrez/eutils/einfo.fcgi?db=pubmed
    xsltproc Eutils2JSON.xsl \
        http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed\&id=5683731\&retmode=xml

==Feedback welcome==

This is a feature we are preparing to add to NCBI E-utilities, and we are making
this preliminary XSLT conversion available in order to solicit community feedback.

Please submit pull requests, create a github issue here, or send an email to
[eutilities@ncbi.nlm.nih.gov](eutilities@ncbi.nlm.nih.gov).