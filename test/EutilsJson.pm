package EutilsJson;

use strict;
use XML::LibXML;
use File::Temp qw/ :POSIX /;
use Logger;

our $log;


# Set this to true if this should output verbose messages
our $verbose = 0;
# Set this to true if you want *not* to exit when there's an error
our $coe = 0;


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
    foreach my $sg ($sxml->getChildrenByTagName('samplegroup')) {
        my %samplegroup = (
            dtd => $sg->getAttribute('dtd'),
            idx => ($sg->getAttribute('idx') eq 'true'),
            eutil => $sg->getAttribute('eutil'),
        );

        my @groupsamples = ();
        foreach my $samp ($sg->getChildrenByTagName('sample')) {
            my %gs = (
                name => $samp->getAttribute('name'),
                db => $samp->getAttribute('db'),
                'eutils-url' =>
                  ($samp->getChildrenByTagName('eutils-url'))[0]->textContent(),
                error => ($samp->getAttribute('error') eq 'true'),
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
# and where to get it.  This takes a $samplegroup as input (see above), and
# returns the relative pathname to the DTD file.
# If this is an ESummary IDX database, and $idxextbase points to the filesystem,
# then this will return the copy of the DTD file under that path.  Otherwise, if
# $idxextbase is an SVN URL, this will download it into the 'out' subdirectory,
# and use that.

sub getDtd {
    my $samplegroup = shift;
    my $eutil = $samplegroup->{eutil};
    my $dtd = $samplegroup->{dtd};
    my $idx = $samplegroup->{idx};
    my $dtdpath;

    # If this is an esummary idx samplegroup, then:
    if ($eutil eq 'esummary' && $idx) {
        # Get the database from the name of the dtd
        if ($dtd !~ /esummary_([a-z]+)\.dtd/) {
            $log->error("FAILED:  Unexpected DTD name for esummary idx database:  $dtd");
            exit 1 if $coe;
            next;
        }
        my $db = $1;

        # See if the DTD exists on the filesystem
        $dtdpath = "$idxextbase/$db/support/esummary_$db.dtd";
        if (-f $dtdpath) {
            return $dtdpath;
        }
        else {
            # Assume $dtdpath is a URL, and fetch it with curl
            my $dest = "out/esummary_$db.dtd";
            $log->message("Fetching $dtdpath");
            my $status = system "curl --silent --output $dest $dtdpath";
            if ($status != 0) {
                $log->error("FAILED to retrieve $dtdpath!");
                exit 1 if !$coe;
                next;
            }
            return $dest;
        }
    }

    return $dtdpath;
}


#-------------------------------------------------------------
# Validate an XML file against a DTD.  By default, this will just use the
# DTD specified by the doctype declaration in the file to do the validation,
# but if a second argument is given, that will be used as the DTD.

sub validateXml {
    my ($xml, $dtdpath) = @_;
    #print "        Validating $xml against $dtdpath\n" if $verbose;

    my $dtdvalidArg = '';    # command-line argument to xmllint, if needed.
    if ($dtdpath) {
        # Strip off the doctype declaration.  This is necessary because we want
        # to validate against local DTD files.  Note that even though
        # `xmllint --dtdvalid` does that local validation, it will still fail
        # if the remote DTD does not exist, which was the case, for example,
        # for pubmedhealth.
        my $tempname = tmpnam();
        $log->message("Stripping doctype decl:  $xml -> $tempname.");
        open(my $th, "<", $xml) or die "Can't open $xml for reading";
        open(my $sh, ">", $tempname) or die "Can't open $tempname for writing";
        while (my $line = <$th>) {
            next if $line =~ /^\<\!DOCTYPE /;
            print $sh $line;
        }
        close $sh;
        close $th;

        $xml = $tempname;
        $dtdvalidArg = '--dtdvalid ' . $dtdpath;
    }

    # Validate this sample against the new DTD.
    my $xmllintCmd = 'xmllint --noout ' . $dtdvalidArg . ' ' . $xml;
    $log->message("Validating:  '$xmllintCmd'");
    my $status = system $xmllintCmd;
    if ($status != 0) {
        $log->error("$xml FAILED to validate!");
        exit 1 if !$coe;
        next;
    }
}


1;
