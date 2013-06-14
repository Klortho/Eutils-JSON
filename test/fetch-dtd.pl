#!/usr/bin/env perl
# Script for testing EUtils JSON output - fetch-dtd step.

use strict;
use warnings;
use EutilsTest;
use FetchDtd;

#-----------------------------------------------------------------
# Parse command line options, output usage help, etc.
# FIXME:  GetOptions call and other stuff can be moved to EutilsTest.pm

# Step-specific options
my @stepOpts = (
    "dtd-svn",
    "dtd-oldurl",
    "dtd-doctype",
    "dtd-loc:s",
);

# Usage message:  note where common options usage is inserted
my $usage = q(
Usage:  fetch-dtd.pl [options]

This script computes the location of, and (optionally) fetches a local copy
of the DTD for a set of sample groups.  If the DTD is fetched, it will be put
into the 'out' directory.

In general, the script "knows" where to get the DTD, and doesn't use the actual
doctype declaration from the instance documents.  But, that default behavior
can be overridden.
) .
$EutilsTest::commonOptUsage .
q(
Options related to the DTD.  These are mutually exclusive.  If none are given,
then the location of the DTD is computed according to the new scheme.
  --dtd-oldurl - Use old-style URLs to get the DTDs; prior to the redesign
    of the system and public identifiers.
  --dtd-doctype - Don't compute the location of the DTD; instead, use the
    doctype declaration of the first sample in the group
  --dtd-svn - Get the DTDs from svn instead of the system identifier.  Only
    works with --idx.  Can't be used with other --dtd options.
  --dtd-loc=<full-path-to-dtd> - Specify the location of the DTD explicitly.
    This should only be used when testing just one samplegroup at a time.
);

# Process these options.
my $Opts = EutilsTest::getOptions(\@stepOpts, $usage);

# Some options defaults for step-specific options
$Opts->{'dtd-oldurl'} = 0  if !$Opts->{'dtd-oldurl'};
$Opts->{'dtd-doctype'} = 0 if !$Opts->{'dtd-doctype'};
$Opts->{'dtd-svn'} = 0     if !$Opts->{'dtd-svn'};
$Opts->{'dtd-loc'} = ''    if !$Opts->{'dtd-loc'};


#-----------------------------------------------------------------
# Create a new test object, and read in the testcases.xml file

my $t = EutilsTest->new($Opts);
my $samplegroups = $t->{samplegroups};

# Set some test-run variables based on command-line options.  This is where
# defaults are specified.


#-----------------------------------------------------------------
# Now run the test

foreach my $sg (@$samplegroups) {
    next if !$t->filterMatch($sg);
    $t->fetchDtd($sg);
}

