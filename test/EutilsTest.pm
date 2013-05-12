package EutilsTest;

# Structure of the object:
# {
#   # Command line option variables, set to their defaults
#   'verbose' => 0,
#   'coe' => 0,
#
#   'testcases' => [
#     { # One sample group
#       # Data from the XML file
#       dtd => 'eInfo_020511.dtd',
#       idx => 0,
#       eutil => 'einfo',
#       # Derived data:
#       'dtd-system-id' => '...',  # Computed value for the system identifier
#       'dtd-url' => '...',        # Computed value for the actual URL used to grab the DTD;
#                                  # usually the same as dtd-system-id, but not always
#       'dtd-path' => 'out/...',   # Relative path to the local copy, if there is one,
#                                  # otherwise (--dtd-remote was given) the empty string
#
#       samples => [
#         { # One of these for each sample in a group
#           # Data from the XML file
#           name => 'einfo',
#           db => 'pubmed',           # optional
#           'eutils-url' => '....',   # relative URL, from the XML file
#           'error-type' => 0,        # from the @error attribute of the XML file
#           # Derived data
#           'local-xml' => 'out/foo.xml',   # Where this was downloaded to
#           'full-xml-url' => 'http://eutils....', # Full URL from which it was downloaded
#           'final-xml' => '/tmp/...',      # Munged copy of the XML (changed doctype decl);
#                                           # if the XML was not modified, this will be the same as
#                                           # local-xml.
#         },
#       ]
#     } ...
#   ],
# }


use strict;
use warnings;
use XML::LibXML;
use File::Temp qw/ :POSIX /;
use Logger;
use Exporter 'import';
use Data::Dumper;
use Cwd;


our @EXPORT = qw(
    $self
    $status $sg $s $step $failures
);

# FIXME:  temporary, while migrating to OO:
our $self;


my $cwd = getcwd;

# This stores the system command, whenever we run one
my $cmd;

## Set this to true if this should output verbose messages
#our $verbose = 0;

## Set this to true if you want *not* to exit when there's an error
#our $coe = 0;

## Log messages
#our $log;

# Status returned from system command
our $status;
# sample group
our $sg;
# sample
our $s;
# The step we're currently on
our $step;
# count the number of failures
our $failures = 0;

our @steps = qw(
    fetch-dtd fetch-xml validate-xml generate-xslt generate-json validate-json
);


# Base URL of the eutilities services
our $eutilsBaseUrl = 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/';

# Base URL of the DTDs
our $eutilsDtdBase = 'http://www.ncbi.nlm.nih.gov/entrez/query/DTD/';


# $idxextbase  points to the base directory of the subtree under which are all
# of the IDX DTDs.  This can either be a directory on the filesystem, or a URL
# to the Subversion repository.
# Any given DTD is at $idxextbase/<db>/support/esummary_<db>.dtd

#my $idxextbase = "/home/maloneyc/svn/toolkit/trunk/internal/c++/src/internal/idxext";
my $idxextbase = "https://svn.ncbi.nlm.nih.gov/repos/toolkit/trunk/internal/c++/src/internal/idxext";


#-------------------------------------------------------------
sub new {
    my $class = shift;
    my $self = {
        'testcases' => _readTestCases(),
        # Command line option variables, set to their defaults
        'verbose' => 0,
        'coe' => 0,
    };
    bless $self, $class;
    return $self;
}

#-------------------------------------------------------------
# Read the testcases.xml file and produce a structure that stores the
# information.

sub _readTestCases {
    my $parser = new XML::LibXML;
    my $sxml = $parser->load_xml(location => 'testcases.xml')->getDocumentElement();

    my @testcases = ();
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
                'error-type' => ($errAttr eq 'true'),
            );
            push @groupsamples, \%gs;
            $samplegroup{samples} = \@groupsamples;
        }
        push @testcases, \%samplegroup;
    }

    return \@testcases;
}

#-----------------------------------------------------------------------------
# Compute the location, and (optionally) retrieve a local copy of the DTD for a
# samplegroup.  If --dtd-doctype was given, then this function does nothing;
# everything is deferred to later, when an instance document is fetched.
#
# This function encapsulates information about where the DTDs are for each type
# of Eutility.
#
# This takes a $sg as input (package variable), and stores various pieces of information
# in that hash (see the data structure description in the comments at the top.)
#
# This function returns 1 if successful, or 0 if there is a failure.
#
# Special case:  if --dtd-svn is given, and this is an ESummary IDX database, and
# $idxextbase points to the filesystem, then this will set 'dtd-path' to point to
# the DTD file under within that path on the filesystem.  Otherwise, if
# $idxextbase is an SVN URL, this will download it to a local copy, as with any
# other URL.

sub fetchDtd {
    $step = 'fetch-dtd';
    $status = 0;
    my ($do, $dtdRemote, $dtdTld, $dtdSvn, $dtdDoctype) = @_;
    return 1 if $dtdDoctype;  # Nothing to do.

    my $dtd = $sg->{dtd};
    my $idx = $sg->{idx};
    my $eutil = $sg->{eutil};
    my $dtdpath;

    # If the --dtd-svn option was given, then this better be an esummary idx samplegroup,
    # otherwise we have to fail.
    if ($dtdSvn) {
        if ($eutil eq 'esummary' && $idx) {
            # Get the database from the name of the dtd
            if ($dtd !~ /esummary_([a-z]+)\.dtd/) {
                failed("Unexpected DTD name for esummary idx database:  $dtd");
                return 0;
            }
            my $db = $1;

            # See if the DTD exists on the filesystem
            $dtdpath = "$idxextbase/$db/support/esummary_$db.dtd";
            if (-f $dtdpath) {
                $sg->{'dtd-system-id'} = $sg->{'dtd-url'} = $sg->{'dtd-path'} = $dtdpath;
                return 1;
            }
            else {
                # Assume $dtdpath is a URL, and fetch it with curl
                my $dest = "out/$dtd";
                $sg->{'dtd-system-id'} = $sg->{'dtd-url'} = $dtdpath;
                $sg->{'dtd-path'} = $dest;
                if ($do) {
                    $self->message("Fetching $dtdpath");
                    $cmd = "curl --fail --silent --output $dest $dtdpath > /dev/null 2>&1";
                    $status = system $cmd;
                    if ($status != 0) {
                        failed("'$cmd': $?");
                        return 0;
                    }
                }
                return 1;
            }
        }
        else {
            failed("--dtd-svn was specified, but I don't know where this DTD " .
                   "is in svn:  $dtd");
            return 0;
        }
    }

    # Not --dtd-svn, we'll compute a normal system identifier URL
    else {
        # Compute the official system identifier (not necessarily the same as
        # the URL that we'll use to get the DTD.
        my $dtdSystemId;

        if ($eutil eq 'esummary') {
            # Prefix with a directory, and change to old-style name, capital S in "eSummary"
            my $proddtd = $dtd;
            $proddtd =~ s/esummary/eSummary/;
            $dtdSystemId = $eutilsDtdBase . 'eSummaryDTD/' . $proddtd;
        }
        else {
            $dtdSystemId = $eutilsDtdBase . $dtd;
        }

        return downloadDtd($do, $dtdSystemId, $dtdTld, $dtdRemote);
    }
}

#-------------------------------------------------------------
# Fetch an XML sample file, and return the pathname.
# This function returns 1 if successful, or 0 if there is a failure.


sub fetchXml {
    $step = 'fetch-xml';
    my $do = shift;

    my $localXml = 'out/' . $s->{name} . ".xml";   # final output filename
    $s->{'local-xml'} = $localXml;

    my $fullUrl = $eutilsBaseUrl . $s->{"eutils-url"};
    $s->{'full-xml-url'} = $fullUrl;

    # For inserting into the system command, escape ampersands:
    my $cmdUrl = $fullUrl;
    $cmdUrl =~ s/\&/\\\&/g;

    if ($do) {
        $self->message("Fetching $fullUrl => $localXml");
        $cmd = "curl --fail --silent --output $localXml $cmdUrl";
        $status = system $cmd;
        if ($status != 0) {
            failed("'$cmd':  $?");
            return 0;
        }
    }
    return 1;
}

#-------------------------------------------------------------
# This does the actual download of the DTD for both fetchDtd
# and validateXml.
# This returns 1 if successful, or 0 if there was a failure.

sub downloadDtd {
    my ($do, $dtdSystemId, $dtdTld, $dtdRemote) = @_;

    # Now the URL that we'll use to actually get it.
    my $dtdUrl = $dtdSystemId;
    if ($dtdTld) {
        $dtdUrl =~ s/www/$dtdTld/;
    }

    # Here is where we'll put the local copy, only if not --dtd-remote
    my $dtdPath = $dtdRemote ? '' : "out/" . $sg->{dtd};

    $sg->{'dtd-system-id'} = $dtdSystemId;
    $sg->{'dtd-url'} = $dtdUrl;
    $sg->{'dtd-path'} = $dtdPath;
    if ($do && !$dtdRemote) {
        $self->message("Fetching $dtdUrl -> $dtdPath");
        $cmd = "curl --fail --silent --output $dtdPath $dtdUrl > /dev/null 2>&1";
        $status = system $cmd;
        if ($status != 0) {
            failed("'$cmd':  $?");
            return 0;
        }
    }
    return 1;
}

#-------------------------------------------------------------
# Validate an XML file against a DTD.
# The DTD local path or URL that will be used is figured out on the basis of
# the $sg->{'dtd-url'} and $sg->{'dtd-path'} that were set in fetchDtd():
#     dtd-path   dtd-url
#     <path>      ---       Strip off doctype decl, and use --dtdvalid to point to local file
#     ''         <url>      Rewrite doctype decl, and use --valid
# Returns 1 if successful; 0 otherwise.

sub validateXml {
    $step = 'validate-xml';
    $status = 0;
    my ($do, $xml, $dtdRemote, $dtdTld, $dtdDoctype) = @_;
    return 1 if !$do;

    # If the --dtd-doctype argument was given, and this is the first sample from
    # this group that we've seen, then we need to fetch the DTD
    if ($dtdDoctype && !exists $sg->{'dtd-url'}) {
        $self->message("Reading XML file $xml to find the DTD");
        my $dtdSystemId;
        my $th;
        if (!open($th, "<", $xml)) {
            failed("Can't open $xml for reading");
            return 0;
        }
        while (my $line = <$th>) {
            if ($line =~ /^\<\!DOCTYPE.*?".*?"\s+"(.*?)"/) {
                $dtdSystemId = $1;
                last;
            }
        }
        if (!$dtdSystemId) {
            failed("Couldn't get system identifier for DTD from xml file");
            return 0;
        }
        close $th;
        return 0 if !downloadDtd($do, $dtdSystemId, $dtdTld, $dtdRemote);
    }

    my $dtdUrl = $sg->{'dtd-url'};
    my $dtdPath = $sg->{'dtd-path'};

    my $xmllintArg = '';   # command-line argument to xmllint, if needed.
    my $finalXml = $xml;   # The pathname of the actual file we'll pass to xmllint

    if ($dtdPath) {
        # Strip off the doctype declaration.  This is necessary because we want
        # to validate against local DTD files.  Note that even though
        # `xmllint --dtdvalid` does that local validation, it will still fail
        # if the remote DTD does not exist, which was the case, for example,
        # for pubmedhealth.
        $finalXml = tmpnam();
        $self->message("Stripping doctype decl:  $xml -> $finalXml");
        my $th;
        if (!open($th, "<", $xml)) {
            failed("Can't open $xml for reading");
            return 0;
        }
        open(my $sh, ">", $finalXml) or die "Can't open $finalXml for writing";
        while (my $line = <$th>) {
            next if $line =~ /^\<\!DOCTYPE /;
            print $sh $line;
        }
        close $sh;
        close $th;

        $xmllintArg = '--dtdvalid ' . $dtdPath;
    }

    else {
        # Replace the doctype declaration with a new one.
        $finalXml = tmpnam();
        $self->message("Writing new doctype decl:  $xml -> $finalXml");
        my $th;
        if (!open($th, "<", $xml)) {
            failed("Can't open $xml for reading");
            return 0;
        }
        open(my $sh, ">", $finalXml) or die "Can't open $finalXml for writing";
        while (my $line = <$th>) {
            if ($line =~ /^\<\!DOCTYPE /) {
                $line =~ s/PUBLIC\s+".*"/SYSTEM "$dtdUrl"/;
            }
            print $sh $line;
        }
        close $sh;
        close $th;

        $xmllintArg = '--valid';
    }

    # Validate this sample against the new DTD.
    $s->{'final-xml'} = $finalXml;
    $cmd = 'xmllint --noout ' . $xmllintArg . ' ' . $finalXml . ' > /dev/null 2>&1';
    $self->message("Validating:  '$cmd'");
    $status = system $cmd;
    if ($status != 0) {
        failed("Validating $finalXml ($xml): '$cmd'!  $?");
        return 0;
    }
    return 1;
}

#------------------------------------------------------------------------
# Use the dtd2xml2json utility to generate an XSLT from the DTD.
# Returns the pathname of the generated file.

sub generateXslt {
    $step = 'generate-xslt';
    my $do = shift;

    my $dtd = $sg->{dtd};
    my $dtdSystemId = $sg->{'dtd-system-id'};
    return if !$dtdSystemId;  # This can happen if --dtd-doctype is given, but we can't find the DTD
    my $dtdPath = $sg->{'dtd-path'};
    my $dtdUrl = $sg->{'dtd-url'};
    my $dtdSrc = $dtdPath ? $dtdPath : $dtdUrl;

    # Compute the full path- and filename of the target 2JSON XSLT file.
    # the e...2json_DBNAME.xslt files.
    # Put these into the same place as the DTD, if there is a local copy of
    # it.  If there is no local copy, put it into the 'out' directory.
    my $jp = '';  # path
    if ($dtdPath) {
        $jp = $dtdPath;
        $jp =~ s/(.*\/).*/$1/;
    }
    if (!$jp) { $jp = 'out/'; }

    # filename
    my $jf = $dtd;
    $jf =~ s/.*\///;  # get rid of path
    if ($jf =~ /esummary/) {
        # Names of the form esummary_db.dtd
        $jf =~ s/esummary_(\w+)\.dtd/esummary2json_$1.xslt/;
    }
    elsif ($jf =~ /e[a-zA-Z]+_\d+\.dtd/) {
        # Names of the from eInfo_020511.dtd
        $jf =~ s/_(\d+)\.dtd/2json_$1.xslt/;
    }
    else {
        failed("Unrecognized DTD filename, don't know how to construct 2json XSLT filename: $jf");
        return;
    }
    my $jsonXslPath = $jp . $jf;

    if ($do) {

        # Run the utility, and capture both standard out and standard error into a
        # file
        my $outfile = 'out/dtd2xml2json.out';
        $cmd = "dtd2xml2json $dtdSrc $jsonXslPath > $outfile 2>&1";
        $self->message("Creating XSLT $jsonXslPath");
        $status = system $cmd;

        if ($status != 0) {
            failed("'$cmd':  $?");
            return;
        }

        # Check the output from the command, to see if there were problems with
        # the JSON annotations (unfortunately, the tool does not return with an
        # error status when this happens).
        my $output = do {
            local $/ = undef;
            open my $fh, "<", $outfile or die "could not open $outfile: $!";
            <$fh>;
        };
        # Look for specific messages
        if ($output =~ /invalid json annotation/ ||
            $output =~ /tell me what to do/ ||
            $output =~ /unknown item group/ ||
            $output =~ /unrecognized element/)
        {
            failed("Problem while running dtd2xml2json utility");
        }
    }
    return $jsonXslPath;
}

#------------------------------------------------------------------------
sub generateJson {
    $step = 'generate-json';
    $status = 0;
    my ($do, $jsonXslPath) = @_;

    my $sampleXml = 'out/' . $s->{name} . ".xml";
    my $sampleJson = $sampleXml;
    $sampleJson =~ s/\.xml$/.json/;
    if ($do) {
        $self->message("Converting XML -> JSON:  $sampleJson");
        my $errfile = 'out/xsltproc.err';
        $cmd = "xsltproc $jsonXslPath $sampleXml > $sampleJson 2> $errfile";
        $status = system $cmd;
        if ($status != 0) {
            failed("'$cmd': $?");
        }

        my $err = do {
            local $/ = undef;
            open my $fh, "<", $errfile or die "could not open $errfile: $!";
            <$fh>;
        };
        if (length($err) > 0)
        {
            failed("Problem during the xsltproc conversion");
        }
    }

    return $sampleJson;
}

#------------------------------------------------------------------------
sub validateJson {
    $step = 'validate-json';
    $status = 0;
    my ($do, $sampleJson) = @_;

    if ($do) {
        $cmd = "jsonlint -q $sampleJson > /dev/null 2>&1";
        $self->message("Validating $sampleJson");
        $status = system $cmd;
        if ($status != 0) {
            failed("'$cmd':  $?");
        }
    }
}

#------------------------------------------------------------------------
# Generic test failure handler

sub failed {
    my $msg = shift;
    $self->error("FAILED:  $msg");
    exit 1 if !$self->{coe} || $status & 127;
    recordFailure($cmd);
    $status = 0;
}

#------------------------------------------------------------------------
# Delegate message() and error() to Logger

sub message {
    my ($self, $msg) = @_;
    $self->{log}->message($msg);
}

sub error {
    my ($self, $msg) = @_;
    $self->{log}->error($msg);
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

    $failures++;
}

1;
