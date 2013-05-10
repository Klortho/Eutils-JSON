#!/opt/perl-5.8.8/bin/perl
# Script for testing EUtils JSON output
# All output files will be written to an "out" subdirectory here.

# Right now this only tests esummary IDX databases, using the DTDs that are
# in a working copy of the subversion repo.

use strict;
use EutilsJson;
use Data::Dumper;
use Getopt::Long;
use Cwd;
use File::Path qw(make_path);

my $status;
my $cwd = getcwd;
make_path('out');


# -v | --verbose turn on verbose messages
my %Opts;
my $ok = GetOptions(\%Opts,
    "help|?",
    "verbose",
    "continue-on-error",
    "no-fetch-xml",
);
if ($Opts{help}) {
    print "Usage:  GetTestIdx.pl [-v|--verbose] [-s|--stop-on-error]\n" .
          "This script tests EUtilities.\n" .
          "Options:\n" .
          "  -h|-? - help\n" .
          "  -v|--verbose - turn on verbose messages\n" .
          "  -c|--continue-on-error - keep going even if there is an error\n" .
          "  -n|--no-fetch-xml - don't fetch anything from the eutils.  This\n" .
          "      assumes all XML files have already been fetched.\n";
    exit 0;
}
my $verbose = $Opts{verbose};
$EutilsJson::verbose = $verbose;
my $coe = $Opts{'continue-on-error'};
$EutilsJson::coe = $coe;
my $noFetch = $Opts{'no-fetch-xml'};




my $samples = EutilsJson::readSamples();
#print Dumper($samples) if $verbose;

#my %testResults;
foreach my $samplegroup (@$samples) {
    my $eutil = $samplegroup->{eutil};
    my $dtd = $samplegroup->{dtd};
    my $idx = $samplegroup->{idx};

    # If this is not an esummary, or one of the IDX databases above, then skip it.
    next if $eutil ne 'esummary' || !$idx;
#    $testResults{$db} = {
#        'samples-exist' => 1,  # if there are samples in samples.xml
#        'dtd-found' => 0,      # if we found the DTD on the filesystem
#    };

    my $dtdpath = EutilsJson::getDtd($samplegroup);
    print "Checking sample group eutil=$eutil, dtd=$dtd\n" if $verbose;

    # For each sample corresponding to this DTD:
    my $groupsamples = $samplegroup->{samples};
    foreach my $s (@$groupsamples) {

        # Fetch the XML for this eutilities sample URL, into a temp file
        my $sampleXml = 'out/' . $s->{name} . ".xml";   # final output filename
        if (!$noFetch) {
            my $eutilsUrl = $EutilsJson::eutilsBaseUrl . $s->{"eutils-url"};

            $eutilsUrl =~ s/\&/\\\&/g;
            print "        Fetching $eutilsUrl => $sampleXml\n" if $verbose;
            $status = system "curl --silent --output $sampleXml $eutilsUrl";
            if ($status != 0) {
                print "            ... FAILED!\n";
                exit 1 if !$coe;
                next;
            }
        }

        EutilsJson::validateXml($sampleXml, $dtdpath);
    }

    # For this DTD, generate the esummary2json_DBNAME.xslt files.
    # Put these into the same place as the DTD
    my $jsonXslPath = $dtdpath;
    $jsonXslPath =~ s/esummary_(\w+)\.dtd/esummary2json_$1.xslt/;
    my $baseXsltPath = $cwd . "/xml2json.xsl";
    my $dtd2xsl2jsonCmd =
        "dtd2xml2json --basexslt $baseXsltPath $dtdpath $jsonXslPath";
    print "    Creating XSLT $jsonXslPath\n" if $verbose;
    $status = system $dtd2xsl2jsonCmd;
    if ($status != 0) {
        print "        FAILED!\n";
        exit 1 if !$coe;
    }

    # Now, for each sample, generate the JSON output
    foreach my $s (@$groupsamples) {
        my $sampleXml = 'out/' . $s->{name} . ".xml";
        my $sampleJson = $sampleXml;
        $sampleJson =~ s/\.xml$/.json/;
        print "        Converting XML -> JSON:  $sampleJson\n" if $verbose;
        my $xsltCmd = "xsltproc $jsonXslPath $sampleXml > $sampleJson";
        $status = system $xsltCmd;
        if ($status != 0) {
            print "            FAILED!\n";
            exit 1 if !$coe;
            next;
        }

        # Validate the JSON output
        my $jsonValidateCmd = "jsonlint -q $sampleJson";
        print "        Validating $sampleJson\n";
        $status = $jsonValidateCmd;
        if ($status != 0) {
            print "            FAILED!\n";
            exit 1 if !$coe;
            next;
        }
    }
}

