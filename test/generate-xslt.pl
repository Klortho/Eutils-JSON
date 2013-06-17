#!/usr/bin/env perl
# Script for testing EUtils JSON output - generate-xslt step.

use strict;
use warnings;
use EutilsTest;
use FetchDtdOpts;
use Logger;

#-----------------------------------------------------------------
# Parse command line options, output usage help, etc.

# Usage message:  note where common options usage is inserted
my $usage = q(
Usage:  generate-xslt.pl [options]

This script fetches the DTDs, and uses the dtd2xml2json utility to generate
an XSLT for each one.
) .
$EutilsTest::commonOptUsage .
$FetchDtdOpts::optsUsage;

# Process these options.
my $Opts = EutilsTest::getOptions(\@FetchDtdOpts::opts, $usage);

# Post-process fetch-dtd options
FetchDtdOpts::processOpts($Opts);


#-----------------------------------------------------------------
# Create a new test object, and read in the testcases.xml file

my $logger = Logger->new();
my $t = EutilsTest->new($Opts, $logger);
my $samplegroups = $t->{samplegroups};

#-----------------------------------------------------------------
# Now run the test

foreach my $sg (@$samplegroups) {
    next if !$t->filterMatch($sg);
    $logger->setCurrentTest('fetch-dtd', $sg);
    $t->fetchDtd($sg);

    $logger->setCurrentTest('generate-xslt', $sg);
    $t->generateXslt($sg);
}

# Make sure at least one sample was found
if ($logger->{'total-tests'} == 0) {
    die "No test cases were found matching your criteria!";
}

$t->summaryReport();
exit !!$logger->{failures};
