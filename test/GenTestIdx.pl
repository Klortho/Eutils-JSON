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
use Cwd;
use File::Path qw(make_path);

my $cwd = getcwd;
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
    "no-fetch-xml",
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
          "  --domain - Domain to test.  Defaults to 'www'.\n" .
          "  --dtd-from - specify how to get the DTD(s).  Valid values are 'remote' (default), 'local'\n" .
    exit 0;
}
$verbose = $Opts{verbose};
$log = Logger->new($verbose);


$coe = $Opts{'continue-on-error'};
$EutilsJson::coe = $coe;

my $eutilToTest = $Opts{'eutil'} || '';
my $dbToTest = $Opts{'db'} || '';
my $dtdToTest = $Opts{'dtd'} || '';
my $sampleToTest = $Opts{'sample'} || '';
my $testIdx = $Opts{'idx'} || 0;
my $testError = $Opts{'error'} || 0;

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
    $step = 'fetch-dtd';
    my $dtdpath = EutilsJson::getDtd();
    next if !$dtdpath;   # means there was an error and continue-on-error is set.
    $log->indent;

    # For each sample corresponding to this DTD:
    foreach my $sample (@$groupsamples) {
        $s = $sample;
        next if !sampleMatch();

        # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        $step = 'fetch-xml';
        my $sampleXml = 'out/' . $s->{name} . ".xml";   # final output filename
        my $eutilsUrl = $EutilsJson::eutilsBaseUrl . $s->{"eutils-url"};

        $eutilsUrl =~ s/\&/\\\&/g;
        $log->message("Fetching $eutilsUrl => $sampleXml");
        $cmd = "curl --silent --output $sampleXml $eutilsUrl";
        $status = system $cmd;
        if ($status != 0) {
            $log->error("FAILED: $cmd");
            exit 1 if !$coe;
            EutilsJson::recordFailure($cmd);
            next;
        }
        $log->indent;

        # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        EutilsJson::validateXml($sampleXml, $dtdpath);

        $log->undent;
    }

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    $step = 'generate-xslt';

    # For this DTD, generate the esummary2json_DBNAME.xslt files.
    # Put these into the same place as the DTD (usually the 'out' directory)
    my $jsonXslPath = $dtdpath;
    $jsonXslPath =~ s/esummary_(\w+)\.dtd/esummary2json_$1.xslt/;
    my $baseXsltPath = $cwd . "/xml2json.xsl";
    $cmd = "dtd2xml2json --basexslt $baseXsltPath $dtdpath $jsonXslPath > /dev/null 2>&1";
    $log->message("Creating XSLT $jsonXslPath");
    $status = system $cmd;
    if ($status != 0) {
        $log->error("FAILED: $cmd");
        exit 1 if !$coe;
        EutilsJson::recordFailure($cmd);
        next;
    }
    $log->indent;


    # Now, for each sample, generate the JSON output
    foreach my $sample (@$groupsamples) {
        $s = $sample;
        next if !sampleMatch();

        # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        $step = 'generate-json';
        my $sampleXml = 'out/' . $s->{name} . ".xml";
        my $sampleJson = $sampleXml;
        $sampleJson =~ s/\.xml$/.json/;
        $log->message("Converting XML -> JSON:  $sampleJson");
        $cmd = "xsltproc $jsonXslPath $sampleXml > $sampleJson 2> /dev/null";
        $status = system $cmd;
        if ($status != 0) {
            $log->error("FAILED: $cmd");
            exit 1 if !$coe;
            EutilsJson::recordFailure($cmd);
            next;
        }
        $log->indent;

        # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        $step = 'validate-json';
        $cmd = "jsonlint -q $sampleJson";
        $log->message("Validating $sampleJson");
        $status = system $cmd;
        if ($status != 0) {
            $log->error("FAILED: $cmd");
            exit 1 if !$coe;
            EutilsJson::recordFailure($cmd);
            next;
        }
        $log->undent;
    }

    $log->undent;
    $log->undent;
}

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



