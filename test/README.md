# NCBI Eutilities test tool

## Installing

This should be installed on a Unix system that has the basic tools
`perl` and `xmllint` in your PATH.

If you want to be able to generate the XML-to-JSON XSLT files and to
generate JSON output from those, then
you will also need the [DtdAnalyzer](https://github.com/NCBITools/DtdAnalyzer)
and [xsltproc](http://xmlsoft.org/XSLT/xsltproc2.html).

To validate the JSON output (either generated, or from the Eutilities)
you need [jsonlint](https://github.com/zaach/jsonlint).

## The test cases

There are several different test scripts here, that all use the same
set of test cases, that are defined in the testcases.xml file.  This file
contains a list of \<samplegroup>s, which, in turn, each contains
a list of \<sample>s.  Each samplegroup corresponds to one independent DTD,
and each sample corresponds to one particular EUtilities request that should
return a response using that DTD.

## Running the tests

Run any of the test scripts with `-?` to see all the option available.
Below is a brief summary of what each one does.

### fetch-dtd.pl

Fetches the DTD for each of the samplegroups.  In order to do this, it has
to first fetch the first sample and examine its doctype declaration.  It
verifies that the system and public identifiers used in that sample
correspond to the standard forms for these.

### fetch-xml.pl

This merely fetches all the XML versions of all of the samples, without
doing any validation.

### validate-xml.pl

This script fetches the DTD for each samplegroup, then fetches the XML for
each individual sample, and then validates the XML against the DTD.

### generate-xslt.pl

Fetches the DTD for each samplegroup, and then uses the DtdAnalyzer utility
to create an XML-to-JSON transformation stylesheet.

### validate-json.pl

COMING SOON

This will download the JSON output directly from the Eutilities service, and
make sure it is valid JSON.

### generate-json.pl

COMING SOON.

Combines generate-xslt and fetch-xml, and then runs each XML through the newly
created XSLT to generate JSON.  Then validates that JSON.

### qa-test.pl

COMING SOON.

Combines validate-xml with validate-json.  Also has a command line switch to
run it against the qa domain.

## Contents of this directory

Here is a list of some of the files and scripts, and what they do.

* `*.pl` - test scripts, as described above
* `EutilsTest.pm` - Perl module that implements most of the functionality
* `Logger.pm` - Logs messages
* `testcases.xml` - Latest list of all of the test cases we'll use
* `testeutils.pl` - *Deprecated*.


## To do:

These need to be done

- Add a check in validate-xml to verify that the system and public identifiers in the
  instance documents are correct (code is commented out in fetch-dtd).  Also, all the
  ones in a given sample group should be the same.

- Add (back) the --dtd-remote option for (for example) validate-xml.pl.  This
  would cause it to skip the fetch-dtd step.

- CIDX in ergatis use case:
    - It should also be able to use JSON XSLTs that were already generated.
    - It should get the XML from a command-line utility, and wrap it somehow.

- Add jslint4java validation.

These are "nice to have" improvements:

- use LibXML for XML validation

- use LibXSLT for the transformation

- Write a custom json parser and jsonlint.

- Doesn't work for efetch, because that's a multipart DTD

- Turn this into a CGI, and have it output a detailed test report in XML

- Include a 'generate-dtd' step that generates CIDX DTDs from Max's tool.
  It will replace GenEsummaryDtds.pl

