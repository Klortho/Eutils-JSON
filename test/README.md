# Testing framework for Eutils-JSON

## Contents of this directory

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

## To do:

These need to be done

- Add something to verify that the system and public identifiers in the
  instance documents are correct
- Need to add new-style system identifiers (see Confluence page) to fetchDtd
- Add a switch to take DTDs from the filesystem.
- It should also be able to validate the JSON output directly from the new utilities,
  when that's deployed.
- CIDX in ergatis use case:
    - It should also be able to use JSON XSLTs that were already generated.
    - It should get the XML from a command-line utility, and wrap it somehow.
- Add --reset, which causes the out directory to be cleared.
- Add jslint4java validation.

These are "nice to have" improvements:

- Enable it to use a catalog file.  There is already a catalog.xml file in the
  directory.  It should use prefixes, instead of calling all the DTDs out explicitly.
  This can only be used with --dtd-remote, because `curl`, that copies down all the
  DTDs into a local directory, doens't know how to use a catalog
    - Change the catalog so that it expects all dtds in a dtd/ subdirectory
    - Change the curl dtd-downloading functionality so that it downloads into
      dtd/..., same as what the catalog expects.

- Combine recordFailure with $log->error.  Also implement halt-on-error there.
- use LibXML for XML validation
- use LibXSLT for the transformation
- use LWP instead of curl
- Write a custom json parser and jsonlint.
- Doesn't work for efetch, because that's a multipart DTD
- Make the samplegroup and the samples into objects.  Store more stuff there
  rather than in package variables.
- Turn this into a CGI, and have it output a detailed test report in XML
- Include a 'generate-dtd' step that generates CIDX DTDs from Max's tool.
  It will replace GenEsummaryDtds.pl
