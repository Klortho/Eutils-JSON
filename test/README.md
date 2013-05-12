# Testing framework for Eutils-JSON

Here is a list of some of the files and scripts, and what they do.

* `testeutils.pl` - Main test script
* `EutilsTest.pm` - Perl module that implements most of the functionality
* `Logger.pm` - Logs messages
* `samples.xml` - Latest list of all of the test cases we'll use
* `catalog.xml` - OASIS catalog file.  This allows you to use local copies
  of all DTDs with all of the tools.  This must only be used with --dtd-remote.
  **This functionality not implemented yet.**

These are deprecated and will be replaced eventually:

* `GenEsummaryDtds.pl` - Auto-generates all of the eSummary DTDs from the cidx
  utility, and then fixes some known errors in them.
* `GetRandomIds.pl` - throw-away script to compile lists of random IDs for each
  of the available databases.  The output of this is XML, suitable for merging
  into `samples.xml`.
