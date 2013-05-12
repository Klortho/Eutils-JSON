#!/usr/bin/env perl
# Script for testing EUtils JSON output
# All output files will be written to an "out" subdirectory here.

# Right now this only tests esummary IDX databases, using the DTDs that are
# in a working copy of the subversion repo.

use strict;
use warnings;
use EutilsTest;
use Data::Dumper;
use Getopt::Long;
use File::Path qw(make_path);
use File::Which;
use File::Copy;


# Create a new test object, and read in the samples xml file
my $t = EutilsTest->new();
my $testcases = $t->{testcases};
#print Dumper($testcases);

# -v | --verbose turn on verbose messages
my %Opts;
my $ok = GetOptions(\%Opts,
    "help|?",
    "verbose",
    "continue-on-error",
    "reset",
    "eutil:s",
    "db:s",
    "dtd:s",
    "sample:s",
    "idx",
    "error",
    "fetch-dtd",
    "fetch-xml",
    "validate-xml",
    "generate-xslt",
    "generate-json",
    "validate-json",
    "dtd-remote",
    "dtd-tld:s",
    "dtd-svn",
    "dtd-doctype",
);
if ($Opts{help}) {
    print <<END_USAGE;
Usage:  GetTestIdx.pl [-v|--verbose] [-s|--stop-on-error]

This script tests EUtilities.

General options:
  -h|-? - help
  -v|--verbose - turn on verbose messages
  -c|--continue-on-error - keep going even if there is an error
  --reset - erase the 'out' directory first

Options to select the sample(s) from the samples.xml file to test (these will
be ANDed together):
  --eutil=<eutil> - test samples corresponding only to the given eutility
  --db=<db> - test samples corresponding to the given database
  --dtd=<dtd> - test only those samples correponding to the given DTD (as given
    in samples.xml)
  --sample=<sample-name> - test only the indicated sample
  --idx - test only ESummary with the IDX databases
  --error - test only the error cases

Options to control the steps to test.  If none of these are given, then all the
steps are performed.
  --fetch-dtd
  --fetch-xml
  --validate-xml
  --generate-xslt
  --generate-json
  --validate-json

Options related to the DTD.  In general, the script "knows" where to get the
DTD, and doesn't use the actual doctype declaration from the instance documents.
  --dtd-remote - Leave the DTD on the remote server, rather than copying it
    locally.
  --dtd-tld=<tld> - Substitute a different top-level-domain in the DTD URL.
    I.e. substitute "www" with <tld>.
  --dtd-svn - Get the DTDs from svn instead of the system identifier.  Only
    works with --idx.  Can't be used with other --dtd options.
  --dtd-doctype - Trust the doctype declaration.  Can be used in conjunction
    with --dtd-remote or --dtd-tld.  This won't do any checking to see that
    the doctype decl matches what we expect, or that every sample in a group
    has the same doctype decl.
END_USAGE
    exit 0;
}
$t->{verbose} = $Opts{verbose};
my $log = $t->{log} = Logger->new($t->{verbose});

$t->{coe} = $Opts{'continue-on-error'};

my $eutilToTest = $Opts{'eutil'} || '';
my $dbToTest = $Opts{'db'} || '';
my $dtdToTest = $Opts{'dtd'} || '';
my $sampleToTest = $Opts{'sample'} || '';
my $testIdx = $Opts{'idx'} || 0;
my $testError = $Opts{'error'} || 0;

my $doAllSteps = !$Opts{'fetch-dtd'} &&
                 !$Opts{'fetch-xml'} &&
                 !$Opts{'validate-xml'} &&
                 !$Opts{'generate-xslt'} &&
                 !$Opts{'generate-json'} &&
                 !$Opts{'validate-json'};
my $doFetchDtd = $Opts{'fetch-dtd'} || $doAllSteps;
my $doFetchXml = $Opts{'fetch-xml'} || $doAllSteps;
my $doValidateXml = $Opts{'validate-xml'} || $doAllSteps;
my $doGenerateXslt = $Opts{'generate-xslt'} || $doAllSteps;
my $doGenerateJson = $Opts{'generate-json'} || $doAllSteps;
my $doValidateJson = $Opts{'validate-json'} || $doAllSteps;

my $dtdRemote = $Opts{'dtd-remote'};
my $dtdTld = $Opts{'dtd-tld'};
my $dtdSvn = $Opts{'dtd-svn'};
my $dtdDoctype = $Opts{'dtd-doctype'};
if ($dtdSvn && ($dtdRemote || $dtdTld || $dtdDoctype)) {
    die "Can't use --dtd-svn with any other DTD option.";
}

# Set things up

make_path('out');
if ($Opts{reset}) {
    unlink glob "out/*";
}

# Get the XSLT base stylesheet, xml2json.xsl, into the out directory
my $ddir = which('dtd2xml2json');
if (!$ddir) {
    die "Can't find dtd2xml2json in my PATH.  That's not good.";
}
$ddir =~ s/^(.*)\/.*$/$1\//;
my $basexslt = $ddir . 'xslt/xml2json.xsl';
if (!-f $basexslt) {
    die "Can't find the base XSLT file $basexslt.  That's bad.";
}
copy($basexslt, 'out');

# Now run the tests, for each sample group, ...
foreach my $sg (@$testcases) {

    # See if we can skip this sample group
    my $eutil = $sg->{eutil};
    next if $eutilToTest ne '' && $eutilToTest ne $eutil;

    my $dtd = $sg->{dtd};
    next if $dtdToTest ne '' && $dtdToTest ne $dtd;

    my $idx = $sg->{idx};
    next if $testIdx && !$idx;

    my $groupsamples = $sg->{samples};

    # If one of the sample-specific selectors has been given, and there are no samples
    # under this group that match any of the other criteria, then skip
    if ($dbToTest || $sampleToTest || $testError) {
        my $doTest = 0;
        foreach my $s (@$groupsamples) {
            if ( sampleMatch($s) ) {
                $doTest = 1;
                last;
            }
        }
        next if !$doTest;
    }

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    next if !$t->fetchDtd($sg, $doFetchDtd, $dtdRemote, $dtdTld, $dtdSvn, $dtdDoctype);
    $log->indent;

    # For each sample corresponding to this DTD:
    foreach my $s (@$groupsamples) {
        next if !sampleMatch($s);

        # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        next if !$t->fetchXml($s, $doFetchXml);
        my $sampleXml = $s->{'local-xml'};
        $log->indent;

        # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        $t->validateXml($s, $doValidateXml, $sampleXml, $dtdRemote, $dtdTld, $dtdDoctype);
        $log->undent;
    }

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    if (!$t->generateXslt($sg, $doGenerateXslt)) {
        $log->undent;
        next;
    }
    my $jsonXsltPath = $sg->{'json-xslt'};
    $log->indent;

    # Now, for each sample, generate the JSON output
    foreach my $s (@$groupsamples) {
        next if !sampleMatch($s);

        if ($s->{failure}{'fetch-xml'}) {
            $log->message("Skipping generate-json for " . $s->{name} .
                          ", because fetch-xml failed");
            next;
        }

        # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        next if !$t->generateJson($s, $doGenerateJson);
        $log->indent;

        # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        $t->validateJson($s, $doValidateJson);
        $log->undent;
    }

    $log->undent;
    $log->undent;
}

# Summary pass / fail report
if ($t->{failures}) {
    print $t->{failures} . " failures:\n";
    foreach my $sg (@$testcases) {
        if ($sg->{failure}) {
            print "  " . $sg->{dtd} . ": ";
            my @fs = map { $sg->{failure}{$_} ? $_ : () } @EutilsTest::steps;
            print join(", ", @fs) . "\n";
        }
    }
}
else {
    print "All tests passed!\n";
}
exit !!$t->{failures};

#-----------------------------------------------------------------------
# sampleMatch($s)
# This subroutine returns true if the sample matches the selection criteria
# given by the user in the command-line arguments.

sub sampleMatch {
    my $s = shift;
    my $matchDb = !$dbToTest || $s->{db} eq $dbToTest;
    my $matchSample = !$sampleToTest || $s->{name} eq $sampleToTest;
    my $matchError = !$testError || $s->{'error-type'};
    return $matchDb && $matchSample && $matchError;
}



