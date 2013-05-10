#!/opt/perl-5.8.8/bin/perl
# Script for testing EUtils JSON output
# All output files will be written to an "out" subdirectory here.

# Right now this only tests esummary IDX databases, using the DTDs that are
# in a working copy of the subversion repo.

use strict;
use EutilsJson;
use Data::Dumper;
use Getopt::Long;
use File::Temp qw/ :POSIX /;
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
my $coe = $Opts{'continue-on-error'};
my $noFetch = $Opts{'no-fetch-xml'};



# $IDXEXT_DIR  points to the base directory of the subtree under which are all
# of the DTDs.  This is the working copy of the subversion directory
# https://svn.ncbi.nlm.nih.gov/repos/toolkit/trunk/internal/c++/src/internal/idxext
# Any given DTD is at $IDXEXT_DIR/<db>/support/esummary_<db>.dtd
my $IDXEXT_DIR = "/home/maloneyc/svn/toolkit/trunk/internal/c++/src/internal/idxext";

my $samples = EutilsJson::readSamples();
#print Dumper($samples) if $verbose;

my %testResults;
foreach my $samplegroup (@$samples) {
    my $dtd = $samplegroup->{dtd};
    my $idx = $samplegroup->{idx};

    # If the DTD is not of the form esummary_<db>.dtd, where <db> is one
    # of the IDX databases above, then skip it.
    next if $dtd !~ /esummary_([a-z]+)\.dtd/;
    my $db = $1;
    next if !$idx;
    $testResults{$db} = {
        'samples-exist' => 1,  # if there are samples in samples.xml
        'dtd-found' => 0,      # if we found the DTD on the filesystem
    };
    print "Checking $dtd; database $db\n" if $verbose;

    print "    Testing $dtd\n" if $verbose;

    # See if the DTD exists on the filesystem
    my $dtdpath = "$IDXEXT_DIR/$db/support/esummary_$db.dtd";
    if (-f $dtdpath) {
        $testResults{$db}{'dtd-found'} = 1;
    }
    else {
        print "        FAILED:  can't find $dtdpath\n";
        exit 1 if !$coe;
        next;
    }

    # For each sample corresponding to this DTD:
    my $groupsamples = $samplegroup->{samples};
    foreach my $s (@$groupsamples) {

        # Fetch the XML for this eutilities sample URL, into a temp file
        my $sampleXml = 'out/' . $s->{name} . ".xml";   # final output filename
        if (!$noFetch) {
            my $eutilsUrl = $EutilsJson::eutilsBaseUrl . $s->{"eutils-url"};
            my $tempname = tmpnam();
            $eutilsUrl =~ s/\&/\\\&/g;
            print "        Fetching $eutilsUrl => $tempname\n" if $verbose;
            $status = system "curl --silent --output $tempname $eutilsUrl";
            if ($status != 0) {
                print "            ... FAILED!\n";
                exit 1 if !$coe;
                next;
            }

            # Strip off the doctype declaration.  This is necessary because we want
            # to validate against local DTD files.  Note that even though
            # `xmllint --dtdvalid` does that local validation, it will still fail
            # if the remote DTD does not exist, which was the case, for example,
            # for pubmedhealth.

            print "        Stripping doctype decl:  $tempname -> $sampleXml.\n" if $verbose;
            open(my $th, "<", $tempname) or die "Can't open $tempname for reading";
            open(my $sh, ">", $sampleXml) or die "Can't open $sampleXml for writing";
            while (my $line = <$th>) {
                next if $line =~ /^\<\!DOCTYPE /;
                print $sh $line;
            }
            close $sh;
            close $th;
        }

        # Validate this sample against the new DTD.
        my $xmllintCmd = "xmllint --noout --dtdvalid $dtdpath $sampleXml";
        print "        Validating:  '$xmllintCmd'\n" if $verbose;
        $status = system $xmllintCmd;
        if ($status != 0) {
            print "            $sampleXml FAILED to validate!\n";
            exit 1 if !$coe;
            next;
        }
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

