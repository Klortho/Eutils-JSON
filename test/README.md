# NCBI Eutilities test tool

## Installing

This should be installed on a Unix system that has the basic tools
`perl`, `curl`, and `xmllint` in your PATH.

If you want to be able to generate the XML-to-JSON XSLT files and to
generate JSON output from those, then
you will also need the [DtdAnalyzer](https://github.com/NCBITools/DtdAnalyzer)
and [xsltproc](http://xmlsoft.org/XSLT/xsltproc2.html).

To validate the JSON output (either generated, or from the Eutilities)
you need [jsonlint](https://github.com/zaach/jsonlint).

## Running the tests

The test script `testeutils.pl` should be run from the same directory in
which it resides.  It needs write access to that directory, since it puts
generated files into the `out` subdirectory there.

Enter the following to get the list of command line options:

```bash
./testeutils.pl -?
```

## Contents of this directory

Here is a list of some of the files and scripts, and what they do.

* `testeutils.pl` - Main all-in-one test script
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

## Steps

Enter `testeutils.pl -?` to get the list of defined steps.

## Pipelines

The test script does nothing by default.  You have to specify at least one step
or at least one pipeline.

A pipeline is really just a fixed set of command-line options.  They can be combined
with other options, but the result will always be the superset (there's no way to
"unset" a pipeline option.)  The following pipelines are defined:

## To do:

These need to be done

- Add a check to verify that the system and public identifiers in the
  instance documents are correct.  All the ones in a given sample group
  should be the same.

- Enable it to use local copies of DTDs, instead of fetching them from the
  server.  This should be implemented with a catalog file.
  There is already a catalog.xml file in the
  directory.  The catalog should use prefixes, instead of calling all the DTDs out explicitly.
  This can only be used with --dtd-remote, because `curl`, that copies down all the
  DTDs into a local directory, doens't know how to use a catalog
    - Change the catalog so that it expects all dtds in a dtd/ subdirectory
    - Change the curl dtd-downloading functionality so that it downloads into
      dtd/..., same as what the catalog expects.

- CIDX in ergatis use case:
    - It should also be able to use JSON XSLTs that were already generated.
    - It should get the XML from a command-line utility, and wrap it somehow.

- Add jslint4java validation.

These are "nice to have" improvements:

- Combine recordFailure with $log->error.  Also implement halt-on-error there.

- use LibXML for XML validation

- use LibXSLT for the transformation

- use LWP instead of curl

- Write a custom json parser and jsonlint.

- Doesn't work for efetch, because that's a multipart DTD

- Turn this into a CGI, and have it output a detailed test report in XML

- Include a 'generate-dtd' step that generates CIDX DTDs from Max's tool.
  It will replace GenEsummaryDtds.pl

- Be able to configure pipelines in an external (yaml or xml) file.

