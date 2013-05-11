package EutilsJson;

use strict;
use warnings;
use XML::LibXML;
use File::Temp qw/ :POSIX /;
use Logger;
use Exporter 'import';
use Data::Dumper;

our @EXPORT = qw(
    $verbose $coe $log $cmd $status $sg $s $step $failed
);

# Set this to true if this should output verbose messages
our $verbose = 0;
# Set this to true if you want *not* to exit when there's an error
our $coe = 0;
# Log messages
our $log;
# command line command
our $cmd;
# Status returned from system command
our $status;
# sample group
our $sg;
# sample
our $s;
# The step we're currently on
our $step;
# count the number of failures
our $failed = 0;

our @steps = qw(
    fetch-dtd fetch-xml validate-xml generate-xslt generate-json validate-json
);

# Base URL of the eutilities services
our $eutilsBaseUrl = 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/';

# $idxextbase  points to the base directory of the subtree under which are all
# of the IDX DTDs.  This can either be a directory on the filesystem, or a URL
# to the Subversion repository.
# Any given DTD is at $idxextbase/<db>/support/esummary_<db>.dtd

#my $idxextbase = "/home/maloneyc/svn/toolkit/trunk/internal/c++/src/internal/idxext";
my $idxextbase = "https://svn.ncbi.nlm.nih.gov/repos/toolkit/trunk/internal/c++/src/internal/idxext";


#-------------------------------------------------------------
# Read the samples.xml file and produce a structure that stores information about it.
#   [
#     { dtd => 'eInfo_020511.dtd',
#       idx => 0,
#       eutil => 'einfo',
#       samples => [
#         { name => 'einfo',
#           db => 'pubmed',
#           eutils-url => '....', },
#       ]
#     } ...
#   ]

sub readSamples {
    my $parser = new XML::LibXML;
    my $sxml = $parser->load_xml(location => 'samples.xml')->getDocumentElement();

    my @samples = ();
    foreach my $sgx ($sxml->getChildrenByTagName('samplegroup')) {
        my $idxAttr = $sgx->getAttribute('idx') || '';
        my %samplegroup = (
            dtd => $sgx->getAttribute('dtd'),
            idx => ($idxAttr eq 'true'),
            eutil => $sgx->getAttribute('eutil'),
        );

        my @groupsamples = ();
        foreach my $samp ($sgx->getChildrenByTagName('sample')) {
            my $errAttr = $samp->getAttribute('error') || '';
            my %gs = (
                name => $samp->getAttribute('name'),
                db => $samp->getAttribute('db') || '',
                'eutils-url' =>
                    ($samp->getChildrenByTagName('eutils-url'))[0]->textContent(),
                error => ($errAttr eq 'true'),
            );
            push @groupsamples, \%gs;
            $samplegroup{samples} = \@groupsamples;
        }
        push @samples, \%samplegroup;
    }

    return \@samples;
}

#-----------------------------------------------------------------------------
# Retrieve the DTD for a samplegroup.  This encapsulates information about how
# and where to get it.  This takes a $sg as input (package variable), and
# returns the relative pathname to the DTD file.  It returns 0 on failure.
# If this is an ESummary IDX database, and $idxextbase points to the filesystem,
# then this will return the copy of the DTD file under that path.  Otherwise, if
# $idxextbase is an SVN URL, this will download it into the 'out' subdirectory,
# and use that.

sub getDtd {
    $step = 'fetch-dtd';
    my $eutil = $sg->{eutil};
    my $dtd = $sg->{dtd};
    my $idx = $sg->{idx};
    my $dtdpath;

    # If this is an esummary idx samplegroup, then:
    if ($eutil eq 'esummary' && $idx) {
        # Get the database from the name of the dtd
        if ($dtd !~ /esummary_([a-z]+)\.dtd/) {
            $log->error("FAILED:  Unexpected DTD name for esummary idx database:  $dtd");
            exit 1 if !$coe;
            recordFailure("Unexpected DTD name for esummary idx database");
            return 0;
        }
        my $db = $1;

        # See if the DTD exists on the filesystem
        $dtdpath = "$idxextbase/$db/support/esummary_$db.dtd";
        if (-f $dtdpath) {
            return $dtdpath;
        }
        else {
            # Assume $dtdpath is a URL, and fetch it with curl
            my $dest = "out/$dtd";
            $log->message("Fetching $dtdpath");
            $cmd = "curl --silent --output $dest $dtdpath > /dev/null 2>&1";
            $status = system $cmd;
            if ($status != 0) {
                $log->error("FAILED to retrieve $dtdpath!");
                exit 1 if !$coe;
                recordFailure($cmd);
                return 0;
            }
            return $dest;
        }
    }

    else {
        # Get the DTD from the production server
        my $eutilsDtdBase = 'http://www.ncbi.nlm.nih.gov/entrez/query/DTD/';
        if ($eutil eq 'esummary') {
            # Prefix with a directory, and change to old-style name, capital S in "eSummary"
            my $proddtd = $dtd;
            $proddtd =~ s/esummary/eSummary/;
            $dtdpath = $eutilsDtdBase . 'eSummaryDTD/' . $proddtd;
        }
        else {
            $dtdpath = $eutilsDtdBase . $dtd;
        }
        my $dest = "out/$dtd";
        $log->message("Fetching $dtdpath -> $dest");
        $cmd = "curl --silent --output $dest $dtdpath > /dev/null 2>&1";
        $status = system $cmd;
        if ($status != 0) {
            $log->error("FAILED to retrieve $dtdpath!");
            exit 1 if !$coe;
            recordFailure($cmd);
            return 0;
        }
        return $dest;
    }

#    else {
#        $log->error("FAILED:  Don't know how to get the DTD");
#        exit 1 if !$coe;
#        return;
#    }

    return $dtdpath;
}


#-------------------------------------------------------------
# Validate an XML file against a DTD.  By default, this will just use the
# DTD specified by the doctype declaration in the file to do the validation,
# but if a second argument is given, that will be used as the DTD.

sub validateXml {
    my ($xml, $dtdpath) = @_;
    $step = 'validate-xml';
    #print "        Validating $xml against $dtdpath\n" if $verbose;

    my $dtdvalidArg = '';  # command-line argument to xmllint, if needed.
    my $xmlFinal = $xml;   # The actual file we'll pass to xmllint
    if ($dtdpath) {
        # Strip off the doctype declaration.  This is necessary because we want
        # to validate against local DTD files.  Note that even though
        # `xmllint --dtdvalid` does that local validation, it will still fail
        # if the remote DTD does not exist, which was the case, for example,
        # for pubmedhealth.
        $xmlFinal = tmpnam();
        $log->message("Stripping doctype decl:  $xml -> $xmlFinal");
        open(my $th, "<", $xml) or die "Can't open $xml for reading";
        open(my $sh, ">", $xmlFinal) or die "Can't open $xmlFinal for writing";
        while (my $line = <$th>) {
            next if $line =~ /^\<\!DOCTYPE /;
            print $sh $line;
        }
        close $sh;
        close $th;

        $dtdvalidArg = '--dtdvalid ' . $dtdpath;
    }

    # Validate this sample against the new DTD.
    $cmd = 'xmllint --noout ' . $dtdvalidArg . ' ' . $xmlFinal . ' > /dev/null 2>&1';
    $log->message("Validating:  '$cmd'");
    $status = system $cmd;
    if ($status != 0) {
        $log->error("FAILED to validate $xmlFinal ($xml): '$cmd'!");
        exit 1 if !$coe;
        recordFailure('validate-xml', $cmd);
    }
}

#------------------------------------------------------------------------
# Record information about an individual test failure in $sg and (if
# appropriate) $s

sub recordFailure {
    my $msg = shift;

    # We'll always store something in $sg.  Make a hash if one hasn't been
    # made before.
    if (!$sg->{failure}) { $sg->{failure} = {}; }

    if ($step eq 'fetch-dtd' || $step eq 'generate-xslt') {
        $sg->{failure}{$step} = $msg;
    }
    else {
        # This was a sample-specific step
        if (!$s->{failure}) { $s->{failure} = {}; }
        $s->{failure}{$step} = $msg;

        # Also flag this in the $sg hash
        $sg->{failure}{$step} = 1;
    }

    $failed++;
}

1;
