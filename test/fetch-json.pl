#!/usr/bin/env perl
# Script for testing EUtils JSON output - fetch-xml step.

use strict;
use warnings;
use EutilsTest;
use Logger;

#-----------------------------------------------------------------
# Parse command line options, output usage help, etc.

# Usage message:  note where common options usage is inserted
my $usage = q(
Usage:  fetch-xml.pl [options]

This script fetches a local copy of the XML for a set of samples.  It puts the
file into the 'out' directory.
) .
$EutilsTest::commonOptUsage;

# Process these options.
my $Opts = EutilsTest::getOptions([], $usage);

#-----------------------------------------------------------------
# Create a new test object, and read in the testcases.xml file

my $logger = Logger->new();
my $t = EutilsTest->new($Opts, $logger);
my $samplegroups = $t->{samplegroups};

#-----------------------------------------------------------------
# Now run the test

foreach my $sg (@$samplegroups) {
    foreach my $s (@{$sg->{samples}}) {
        next if !$t->filterMatch($s);
        $logger->setCurrentTest('fetch-xml', $s);
        $t->fetchXml($s);
    }
}

# Make sure at least one sample was found
if ($logger->{'total-tests'} == 0) {
    die "No test cases were found matching your criteria!";
}

$t->summaryReport();
exit !!$logger->{failures};
