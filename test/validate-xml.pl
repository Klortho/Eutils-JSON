#!/usr/bin/env perl
# Script for testing EUtils JSON output - validate-xml step.  Assumes the XML has
# already been fetched.

use strict;
use warnings;
use EutilsTest;
use FetchDtdOpts;
use Logger;

#-----------------------------------------------------------------
# Parse command line options, output usage help, etc.

# Usage message:  note where common options usage is inserted
my $usage = q(
Usage:  validate-xml.pl [options]

This script combines fetch-dtd and fetch-xml, and then additionally, validates
the fetched XML against the fetched DTD.
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

    foreach my $s (@{$sg->{samples}}) {
        next if !$t->filterMatch($s);
        $logger->setCurrentTest('fetch-xml', $s);
        $t->fetchXml($s);
        $logger->setCurrentTest('validate-xml', $s);
        $t->validateXml($s);
    }
}

# Make sure at least one sample was found
if ($logger->{'total-tests'} == 0) {
    die "No test cases were found matching your criteria!";
}

$t->summaryReport();
exit !!$logger->{failures};
