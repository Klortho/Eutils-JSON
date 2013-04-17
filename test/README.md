# Testing framework for Eutils-JSON

Here is a list of some of the files and scripts here and what they do.
There are several others, but they are of the "throw-away" variety.

* `samples.xml` - Latest list of all of the test cases we'll use
* `GenEsummaryDtds.pl` - Auto-generates all of the eSummary DTDs from the cidx
  utility, and then fixes some known errors in them.
* `catalog.xml` - Catalog file so that `xmllint` will use the local copies of DTDs
  for validation of the XML results
* `TestXmlJson.pl` - Tests each sample in samples.xml
* `EutilsJson.pm` - Perl module with some shared code.
* `GetRandomIds.pl` - throw-away script to compile lists of random IDs for each
  of the available databases.  The output of this is XML, suitable for merging
  into `samples.xml`.
