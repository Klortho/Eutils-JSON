#!/usr/bin/env perl
# Script for testing EUtils JSON output
# All output files will be written to an "out" subdirectory here.

# Right now this only tests esummary IDX databases, using the DTDs that are
# in a working copy of the subversion repo.

use strict;
use warnings;
use EutilsJson;
use Data::Dumper;
use Getopt::Long;
use File::Path qw(make_path);

make_path('out');

# -v | --verbose turn on verbose messages
my %Opts;
my $ok = GetOptions(\%Opts,
    "help|?",
    "verbose",
    "continue-on-error",
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
);
if ($Opts{help}) {
    print "Usage:  GetTestIdx.pl [-v|--verbose] [-s|--stop-on-error]\n\n" .
          "This script tests EUtilities.\n\n" .
          "General options:\n" .
          "  -h|-? - help\n" .
          "  -v|--verbose - turn on verbose messages\n" .
          "  -c|--continue-on-error - keep going even if there is an error\n\n" .
          "Options to select the sample(s) from the samples.xml file to test (these will be ANDed together):\n" .
          "  --eutil=<eutil> - test samples corresponding only to the given eutility\n" .
          "  --db=<db> - test samples corresponding to the given database\n" .
          "  --dtd=<dtd> - test only those samples correponding to the given DTD (as given in samples.xml)\n" .
          "  --sample=<sample-name> - test only the indicated sample\n" .
          "  --idx - test only IDX databases\n" .
          "  --error - test only the error cases\n\n" .
          "Options to control the steps to test\n" .
          "  --fetch-dtd\n" .
          "  --fetch-xml\n" .
          "  --validate-xml\n" .
          "  --generate-xslt\n" .
          "  --generate-json\n" .
          "  --validate-json\n\n" .
          "Options related to the DTD\n" .
          "  --domain - Domain to test.  Defaults to 'www'.\n" .
          "  --dtd-from - specify how to get the DTD(s).  Valid values are 'remote' (default), 'local'\n";
    exit 0;
}
$verbose = $Opts{verbose};
$log = Logger->new($verbose);


$coe = $Opts{'continue-on-error'};

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

#print "eutilToTest = '$eutilToTest'; dbToTest = '$dbToTest'; \n" .
#      "dtdToTest = '$dtdToTest'; sampleToTest = '$sampleToTest'\n";
#exit 1;

my $samples = EutilsJson::readSamples();
#print Dumper($samples) if $verbose;

#my %testResults;
foreach my $samplegroup (@$samples) {
    $sg = $samplegroup;

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
        foreach my $sample (@$groupsamples) {
            $s = $sample;
            if ( sampleMatch() ) {
                $doTest = 1;
                last;
            }
        }
        next if !$doTest;
    }

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    my $dtdpath = EutilsJson::fetchDtd($doFetchDtd);
    next if !$dtdpath;   # means there was an error and continue-on-error is set.
    $log->indent;

    # For each sample corresponding to this DTD:
    foreach my $sample (@$groupsamples) {
        $s = $sample;
        next if !sampleMatch();

        # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        my $sampleXml = EutilsJson::fetchXml($doFetchXml);
        next if $status != 0;
        $log->indent;

        # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        EutilsJson::validateXml($doValidateXml, $sampleXml, $dtdpath);
        $log->undent;
    }

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    my $jsonXslPath = EutilsJson::generateXslt($doGenerateXslt, $dtdpath);
    if ($status != 0) {
        $log->undent;
        $status = 0;
        next;
    }
    $log->indent;

    # Now, for each sample, generate the JSON output
    foreach my $sample (@$groupsamples) {
        $s = $sample;
        next if !sampleMatch();

        if ($s->{failure}{'fetch-xml'}) {
            $log->message("Skipping generate-json for " . $s->{name} .
                          ", because fetch-xml failed");
            next;
        }

        # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        my $sampleJson = EutilsJson::generateJson($doGenerateJson, $jsonXslPath);
        next if $status != 0;
        $log->indent;

        # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        EutilsJson::validateJson($doValidateJson, $sampleJson);
        $log->undent;
    }

    $log->undent;
    $log->undent;
}

# Summary pass / fail report
if ($EutilsJson::failed) {
    print "$EutilsJson::failed failures:\n";
    foreach my $samplegroup (@$samples) {
        $sg = $samplegroup;
        if ($sg->{failure}) {
            print "  " . $sg->{dtd} . ": ";
            my @fs = map { $sg->{failure}{$_} ? $_ : () } @EutilsJson::steps;
            print join(", ", @fs) . "\n";
        }
    }
}
else {
    print "All tests passed!\n";
}
exit $EutilsJson::failed;

#-----------------------------------------------------------------------
# This subroutine returns true if the sample matches the selection criteria
# given by the user in the command-line arguments.

sub sampleMatch {
    my $matchDb = !$dbToTest || $s->{db} eq $dbToTest;
    my $matchSample = !$sampleToTest || $s->{name} eq $sampleToTest;
    my $matchError = !$testError || $s->{error};
    return $matchDb && $matchSample && $matchError;
}



