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
    "tld:s",
    "eutil:s",
    "db:s",
    "dtd:s",
    "sample:s",
    "idx",
    "error",
    @EutilsTest::steps,
    "dtd-remote",
    "dtd-svn",
    "dtd-oldurl",
    "dtd-doctype",
    "dtd-loc:s",
    "xml-docsumtool:s",
    "dbinfo:s",
    "build:s",
    "xslt-loc:s",
    "pipe-qa-monitor",
    "pipe-qa-release",
    "pipe-cidx-verify",
    "pipe-idx-svn",
);
#print Dumper \%Opts;

if ($Opts{help}) {
    print q(
Usage:  GetTestIdx.pl [-v|--verbose] [-s|--stop-on-error]

This script tests EUtilities.

General options:
  -h|-? - help
  -v|--verbose - turn on verbose messages
  -c|--continue-on-error - keep going even if there is an error
  --reset - erase the 'out' directory first
  --tld=<tld> - Substitute a different top-level-domain in all URLs.
    I.e., for DTDs:  www.ncbi -> <tld>.ncbi; for FCGIs:  eutils.ncbi ->
    <tld>.ncbi

Options to select the sample(s) from the samples.xml file to test (these will
be ANDed together):
  --eutil=<eutil> - test samples corresponding only to the given eutility
  --db=<db> - test samples corresponding to the given database
  --dtd=<dtd> - test only those samples correponding to the given DTD (as given
    in samples.xml)
  --sample=<sample-name> - test only the indicated sample
  --idx - test only ESummary with the IDX databases
  --error - test only the error cases

Options to control the steps to test.  If none of these are given, then the
default pipeline steps are performed.
) .
(join("", map { "  --$_\n" } @EutilsTest::steps)) .
q(
Options related to the DTD.  In general, the script "knows" where to get the
DTD, and doesn't use the actual doctype declaration from the instance documents.
  --dtd-remote - Leave the DTD on the remote server, rather than copying it
    locally.
  --dtd-svn - Get the DTDs from svn instead of the system identifier.  Only
    works with --idx.  Can't be used with other --dtd options.
  --dtd-oldurl - Use old-style URLs to get the DTDs; prior to the redesign
    of the system and public identifiers.
  --dtd-doctype - Trust the doctype declaration.  Can be used in conjunction
    with --tld or with --dtd-remote.  This won't do any checking to see that
    the doctype decl matches what we expect, or that every sample in a group
    has the same doctype decl.
  --dtd-loc=<full-path-to-dtd> - Specify the location of the DTD explicitly.
    This should only be used when testing just one samplegroup at a time.

Other options:
  --xml-docsumtool=<path-to-tool> - When testing CIDX pipeline, we use a utility
    to generate docsums, that we then wrap into an XML file
  --dbinfo - Location of the dbinfo.ini file.  Same as for CIDX tools; this is
    passed to the xml-docsumtool
  --build - Build identfier.  Same as for CIDX tools; this is passed to the
    xml-docsumtool
  --xslt-loc - Specify the location of the XSLT explicitly.  This is used in
    conjunction with --dtd-loc, when testing just one samplegroup at a time.

Pipelines.  These are shorthands for collections of other options.
  --pipe-qa-monitor
  --pipe-qa-release
  --pipe-idx-svn
);
    exit 0;
}

# Pipelines are collections of other options, that will get merged in
my %pipelines = (
    'default' => {
        'fetch-dtd' => 1,
        'fetch-xml' => 1,
        'validate-xml' => 1,
        'generate-xslt' => 1,
        'generate-json' => 1,
        'validate-json' => 1,
    },
    'qa-monitor' => {
        'reset' => 1,
        'idx' => 1,
        'eutil' => 'esummary',
        'fetch-dtd' => 1,
        'fetch-xml' => 1,
        'validate-xml' => 1,
        'fetch-json' => 1,
        'validate-json' => 1,
    },
    'qa-release' => {
        'reset' => 1,
        'tld' => 'qa',
        'eutil' => 'esummary',
        'fetch-dtd' => 1,
        'fetch-xml' => 1,
        'validate-xml' => 1,
        'fetch-json' => 1,
        'validate-json' => 1,
    },
    'cidx-verify' => {
        'reset' => 1,
        'eutil' => 'esummary',
        'fetch-dtd' => 1,
        'generate-xml' => 1,
        'validate-xml' => 1,
        'generate-xslt' => 1,
        'generate-json' => 1,
        'validate-json' => 1,
    },
    'idx-svn' => {
        'reset' => 1,
        'idx' => 1,
        'eutil' => 'esummary',
        'fetch-dtd' => 1,
        'fetch-xml' => 1,
        'validate-xml' => 1,
        'generate-xslt' => 1,
        'generate-json' => 1,
        'validate-json' => 1,
    }
);

# If no pipeline and no steps are selected, then use pipe-default.
my $pipeline = $Opts{'pipe-qa-monitor'} ? 'qa-monitor' :
               $Opts{'pipe-qa-release'} ? 'qa-release' :
               $Opts{'pipe-idx-svn'}    ? 'idx-svn' :
               $Opts{'pipe-cidx-verify'}    ? 'cidx-verify' : '';

# This will be true if any of the step options was given
my $stepOptGiven = grep { $Opts{$_} } @EutilsTest::steps;

if (!$pipeline && !$stepOptGiven) {
    $pipeline = 'default';
}

# Merge in the pipeline options
my $pipeOpts = $pipelines{$pipeline};
foreach my $k (keys %$pipeOpts) {
    $Opts{$k} = $pipeOpts->{$k};
}
#print Dumper \%Opts;


$t->{verbose} = $Opts{verbose};
my $log = $t->{log} = Logger->new($t->{verbose});

$t->{coe} = $Opts{'continue-on-error'};
my $tld = $Opts{'tld'};

my $eutilToTest = $Opts{'eutil'} || '';
my $dbToTest = $Opts{'db'} || '';
my $dtdToTest = $Opts{'dtd'} || '';
my $sampleToTest = $Opts{'sample'} || '';
my $testIdx = $Opts{'idx'} || 0;
my $testError = $Opts{'error'} || 0;

my $doFetchDtd = $Opts{'fetch-dtd'};
my $doFetchXml = $Opts{'fetch-xml'};
my $doGenerateXml = $Opts{'generate-xml'};
my $doValidateXml = $Opts{'validate-xml'};
my $doFetchJson = $Opts{'fetch-json'};
my $doGenerateXslt = $Opts{'generate-xslt'};
my $doGenerateJson = $Opts{'generate-json'};
my $doValidateJson = $Opts{'validate-json'};

my $dtdRemote = $Opts{'dtd-remote'};
my $dtdSvn = $Opts{'dtd-svn'};
my $dtdOldUrl = $Opts{'dtd-oldurl'};
my $dtdDoctype = $Opts{'dtd-doctype'};
my $dtdLoc = $Opts{'dtd-loc'};
if ($dtdSvn && ($dtdRemote || $dtdOldUrl || $dtdDoctype)) {
    die "Can't use --dtd-svn with any other DTD option.";
}
my $xmlDocsumTool = $Opts{'xml-docsumtool'};
my $dbinfo = $Opts{'dbinfo'};
my $build = $Opts{'build'};
my $xsltLoc = $Opts{'xslt-loc'};

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
    next if !$t->fetchDtd($sg, $doFetchDtd, $dtdRemote, $tld, $dtdSvn,
                          $dtdDoctype, $dtdOldUrl, $dtdLoc);
    $log->indent;

    # For each sample corresponding to this DTD:
    foreach my $s (@$groupsamples) {
        next if !sampleMatch($s);

        # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        if ($doGenerateXml) {
            next if !$t->generateXml($s, $doGenerateXml, $xmlDocsumTool,
                                     $dbinfo, $build);
        }

        # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        if ($doFetchXml) {
            next if !$t->fetchXml($s, $doFetchXml, $tld);
        }

        # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        $log->indent;
        $t->validateXml($s, $doValidateXml, $s->{'local-xml'}, $dtdRemote, $tld,
                        $dtdDoctype);
        $log->undent;
    }

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    if (!$t->generateXslt($sg, $doGenerateXslt, $xsltLoc)) {
        $log->undent;
        next;
    }
    my $jsonXsltPath = $sg->{'json-xslt'};
    $log->indent;

    # Now, for each sample, generate the JSON output
    foreach my $s (@$groupsamples) {
        next if !sampleMatch($s);

        if ($doGenerateJson) {
            if ($s->{failure}{'fetch-xml'}) {
                $log->message("Skipping generate-json for " . $s->{name} .
                              ", because fetch-xml failed");
                next;
            }

            # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            next if !$t->generateJson($s, $doGenerateJson);
        }

        else {
            # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            next if !$t->fetchJson($s, $doFetchJson, $tld);
        }

        # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        $log->indent;
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



