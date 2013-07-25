Eutils-JSON
===========


Conversion XSLTs for NCBI [E-utilities](http://www.ncbi.nlm.nih.gov/books/NBK25501/) XML to JSON.

Please send us your feedback.

We are preparing to add JSON output format to NCBI E-utilities, and are making
this preliminary XSLT conversion available in order to solicit community feedback.

Please submit pull requests, create a github issue here, or send an email to
[eutilities@ncbi.nlm.nih.gov](mailto:eutilities@ncbi.nlm.nih.gov).

## Samples / test cases

The `samples` directory here provides a large number of samples of E-utility 
XML responses, DTDs, etc.  This was where preliminary investigations were done,
and a list of problems were identified in the current XML outputs.

## Test script

The `test` directory here contains a feature-rich test script, along with a
`testcases.xml` file that identifies an extensive set of test cases.

## Ruby / Rack application

The `rack-proxy` directory here contains a simple Ruby application that uses
the Puma server to reverse-proxy Eutilities requests and convert them into
JSON.  

Thanks to @sdor for this pull request.

##Questions

* What is the str:decode-uri() doing in the np:q function?  Are some of these values
really URI-style percent encoded?

##Authors

Mark Johnson, Chris Maloney
