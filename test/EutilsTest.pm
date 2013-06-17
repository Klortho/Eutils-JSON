package EutilsTest;

# Structure of the object:
# {
#   # Command line option variables, set to their defaults
#   'opts' => { ... command line options ... },
#   'verbose' => 0,
#   'coe' => 0,
#
#   'samplegroups' => [
#     { # One sample group
#       # Data from the XML file
#       isa => 'samplegroup',
#       dtd => 'einfo.dtd',
#       idx => 0,
#       eutil => 'einfo',
#
#       # Derived data:
#       'dtd-public-id' => '...'   # The expected public id.  Empty if we don't know.
#       'dtd-system-id' => '...',  # The expected system id.
#       'dtd-id-date' => 'YYYYMMDD', # The date field from the system id
#       'dtd-url' => '...',        # Computed value for the actual URL used to grab the DTD;
#                                  # usually the same as dtd-system-id, but not always
#       'dtd-path' => 'out/...',   # Relative path to the local copy, if there is one,
#                                  # otherwise (--dtd-remote was given) the empty string
#       'json-xslt' => 'out/...",  # Location of the 2JSON XSLT file
#       'dtd2xml2json-out' => '...', # A string of the output from the dtd2xml2json utility
#
#       msgs => [ ... messages while testing this samplegroup ... ],
#       failed => 0,   # boolean, indicates whether or not any test failed
#       tests => [
#           { 'name' => 'fetch-dtd', 'failed' => 0 },
#           ...
#       ],
#
#       samples => [
#         { # One of these for each sample in a group
#           # Data from the XML file
#           isa => 'sample',
#           sg => ...,                # Reference to the parent samplegroup this belongs to
#           name => 'einfo',
#           db => 'pubmed',           # optional
#           'eutils-url' => '....',   # relative URL, from the testcases.xml file
#           'error-type' => 0,        # from the @error attribute of the testcases.xml file
#
#           # Derived data
#           'local-xml' => 'out/foo.xml',      # Where this was downloaded to
#           'xml-url' => 'http://eutils...',   # Nominal URL for the XML (before tld substitution)
#           'real-xml-url' => 'http://qa....', # The actual URL from which it was downloaded
#           'final-xml' => '/tmp/...',         # Munged copy of the XML (changed doctype decl);
#                                              # if the XML was not modified, this will be the same as
#                                              # local-xml.
#           'json-file' => 'out/...',          # Filename of the generated json file
#           'json-url' => 'http://eutils...",  # Nominal URL for the JSON (before tld substitution)
#           'real-json-url' => 'http://...', # If JSON was downloaded, this is the source
#
#           msgs => [ ... messages while testing this sample ... ],
#           failed => 0,
#           tests => [ ... list of tests that this failed ... ],
#
#         }, ... more samples
#       ]
#     } ... more sample groups
#   ]  # end samplegroups
# }

use strict;
use warnings;
use XML::LibXML;
use File::Temp qw/ :POSIX /;
use Logger;
use File::Copy;
use Getopt::Long;
use File::Path qw(make_path);
use LWP::UserAgent;
use Data::Dumper;
use File::Which;

my $ua = LWP::UserAgent->new;


my @commonOpts = (
    'help|?',
    'quiet',
    'continue-on-error',
    'reset',
    'tld:s',
    'eutil:s',
    'db:s',
    'dtd:s',
    'sample:s',
    'idx',
    'error',
);

our $commonOptUsage = q(
General options:
  -h|-? - help
  -q|--quiet - turn off most messages
  -c|--continue-on-error - keep going even if there is an error (default is to
    stop)
  --reset - erase the 'out' directory first
  --tld=<tld> - Substitute a different top-level-domain in all URLs.
    I.e., for DTDs:  www.ncbi -> <tld>.ncbi; for FCGIs:  eutils.ncbi ->
    <tld>.ncbi

Options to select the sample(s) from the samples.xml file to test (these will
be ANDed together):
  --eutil=<eutil> - test samplegroups corresponding only to the given eutility
  --dtd=<dtd> - test samplegroups correponding to the given DTD (as given
    in samples.xml)
  --db=<db> - test samples corresponding to the given database
  --sample=<sample-name> - test only the indicated sample
  --idx - test only ESummary with the IDX databases samplegroups
  --error - test only the error samples
);

#-------------------------------------------------------------------------
# Function to process command line options. This prints out the usage message
# and exits, if the help option was given.  This should be called explicitly
# from the script, after it initializes its "step-specific" option array, but
# before instantiating the EutilsTest object.

sub getOptions {
    my ($stepOpts, $usage) = @_;
    my @options = (@$stepOpts, @commonOpts);

    my %Opts;
    # Strict:  die if there's anything wrong with the command line.  That's better
    # than perhaps running tons of tests which would bury the error.
    die if !GetOptions(\%Opts, @options);


    # Set defaults for the common options.  This prevents a class of runtime
    # errors when trying to access uninitialized hash elements
    $Opts{help} = 0                if !$Opts{help};
    $Opts{'continue-on-error'} = 0 if !$Opts{'continue-on-error'};
    $Opts{'eutil'} = ''            if !$Opts{'eutil'};
    $Opts{'db'} = ''               if !$Opts{'db'};
    $Opts{'dtd'} = ''              if !$Opts{'dtd'};
    $Opts{'sample'} = ''           if !$Opts{'sample'};
    $Opts{'idx'} = 0               if !$Opts{'idx'};
    $Opts{'error'} = 0             if !$Opts{'error'};

    if ($Opts{help}) {
        print $usage;
        exit 0;
    }
    return \%Opts;
}

# Base URL of the eutilities services
our $eutilsBaseUrl = 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/';

# Base URL of the DTDs
our $eutilsDtdBase = 'http://www.ncbi.nlm.nih.gov/entrez/query/DTD/';


# $idxextbase  points to the base directory of the subtree under which are all
# of the IDX DTDs.  This should be a URL to the Subversion repository.
# Any given DTD is at $idxextbase/<db>/support/esummary_<db>.dtd

our $idxextbase =
    "https://svn.ncbi.nlm.nih.gov/repos/toolkit/trunk/internal/c++/src/internal/idxext";


#-------------------------------------------------------------
# Create a new test-run object, read in testcases.xml.  This also prepares the
# output directory.
sub new {
    my ($class, $Opts, $logger) = @_;

    my $self = {
        'log' => $logger,
        'samplegroups' => _readTestCases(),

        # Command line options and shortcuts
        'opts' => $Opts,
        'verbose' => !$Opts->{'quiet'},
        'coe' => $Opts->{'continue-on-error'},

        # Other
        'current-step' => {
            'step' => 'none',
        },
        'total-tests' => 0,
        'failures' => 0,
    };
    bless $self, $class;

    $logger->setVerbose($self->{verbose});

    # Set up the output directory
    make_path('out');
    if ($Opts->{reset}) {
        unlink glob "out/*";
    }

    # If no samplegroup or sample filters were given, then test everything
    $self->{'test-all'} = !$Opts->{'eutil'} && !$Opts->{'db'} && !$Opts->{'dtd'} &&
                          !$Opts->{'sample'} && !$Opts->{'idx'} && !$Opts->{'error'};

    return $self;
}

#-------------------------------------------------------------
# Read the testcases.xml file and produce a structure that stores the
# information.

sub _readTestCases {
    my $parser = new XML::LibXML;
    my $sxml = $parser->load_xml(location => 'testcases.xml')->getDocumentElement();

    my @samplegroups = ();
    foreach my $sgx ($sxml->getChildrenByTagName('samplegroup')) {
        my $idxAttr = $sgx->getAttribute('idx') || '';
        my $sg = {
            isa => 'samplegroup',
            dtd => $sgx->getAttribute('dtd'),
            idx => ($idxAttr eq 'true'),
            eutil => $sgx->getAttribute('eutil'),
            msgs => [],
            failed => 0,
            tests => [],
        };

        my @groupsamples = ();
        $sg->{samples} = \@groupsamples;
        foreach my $samp ($sgx->getChildrenByTagName('sample')) {
            my $errAttr = $samp->getAttribute('error') || '';
            my $s = {
                isa => 'sample',
                sg => $sg,
                name => $samp->getAttribute('name'),
                db => $samp->getAttribute('db') || '',
                'eutils-url' =>
                    ($samp->getChildrenByTagName('eutils-url'))[0]->textContent(),
                'error-type' => ($errAttr eq 'true'),
                msgs => [],
                failed => 0,
                tests => [],
            };
            push @groupsamples, $s;
        }
        push @samplegroups, $sg;
    }

    return \@samplegroups;
}

#-----------------------------------------------------------------------------
# $t->findSample($name);
# Returns the sample with the given name, or undef if not found
sub findSample {
    my ($self, $name) = @_;
    foreach my $sg (@{$self->{samplegroups}}) {
        foreach my $s (@{$sg->{samples}}) {
            return $s if $s->{name} eq $name;
        }
    }
    return undef;
}
#-----------------------------------------------------------------------------
# $t->filterMatch($s or $sg)
# Tests a samplegroup or a sample to see if it matches one of the filter criteria.
# A true value means yes, we should test it.

sub filterMatch {
    my ($self, $s_or_sg) = @_;
    return 1 if $self->{'test-all'};

    if ($s_or_sg->{isa} eq 'samplegroup') {
        my $sg = $s_or_sg;

        # Is this samplegroup is explicitly filtered out?
        return 0 if $self->_sgFilteredOut($sg);

        # If none of the sample-specific selectors were given, then return 1
        my $opts = $self->{opts};
        return 1 if !$opts->{db} && !$opts->{sample} && !$opts->{error};

        # Otherwise if any of the samples were
        # selected (not filtered out), then return 1
        foreach my $s (@{$sg->{samples}}) {
            return 1 if !$self->_sFilteredOut($s);
        }

        # Otherwise skip this group.
        return 0;
    }

    else {
        my $s = $s_or_sg;

        # If this sample's samplegroup was explicitly filtered out, then return 0.
        return 0 if $self->_sgFilteredOut($s->{sg});

        # Otherwise, return 0 if and only if this sample was explicitly filtered out.
        return !$self->_sFilteredOut($s);
    }
}

# This just tests whether or not any samplegroup filters are set, and this samplegroup
# does not match.  In that case, this returns 1, and this samplegroup is filtered out,
# and we won't test it.
sub _sgFilteredOut {
    my ($self, $sg) = @_;
    my $opts = $self->{opts};
    my $eutilToTest = $opts->{eutil};
    my $dtdToTest = $opts->{dtd};
    my $testIdx = $opts->{idx};

    return $eutilToTest && $eutilToTest ne $sg->{eutil} ||
           $dtdToTest   && $dtdToTest ne $sg->{dtd} ||
           $testIdx     && !$sg->{idx};
}

# This just tests whether or not any sample filters are set, and this sample does not
# match.
sub _sFilteredOut {
    my ($self, $s) = @_;
    my $opts = $self->{opts};
    my $dbToTest = $opts->{db};
    my $sampleToTest = $opts->{sample};
    my $testError = $opts->{error};

    return $dbToTest     && $dbToTest ne $s->{db} ||
           $sampleToTest && $sampleToTest ne $s->{name} ||
           $testError    && !$s->{'error-type'};
}

#-----------------------------------------------------------------------------
# Compute the location, and retrieve a local copy of the DTD for a
# samplegroup.
#
# This function encapsulates information about where the DTDs are for each type
# of Eutility.
#
# This takes a $sg as input (package variable), and stores various pieces of information
# in that hash (see the data structure description in the comments at the top.)
#
# This function returns 1 if successful, or 0 if there is a failure.

sub fetchDtd {
    my ($self, $sg) = @_;

    my $opts = $self->{opts};
    my $tld = $opts->{tld};
    my $dtdNewUrl = $opts->{'dtd-newurl'};
    my $dtdDoctype = $opts->{'dtd-doctype'};
    my $dtdSvn = $opts->{'dtd-svn'};
    my $dtdLoc = $opts->{'dtd-loc'};

    my $dtd = $sg->{dtd};
    my $idx = $sg->{idx};
    my $eutil = $sg->{eutil};
    my $dtdpath;

    if ($dtdNewUrl || $dtdDoctype) {
        if ($dtdNewUrl) {
            $self->message("Fetching DTD based on new URL scheme; requires getting a sample XML");
        }
        else {
            $self->message("Fetching DTD based on doctype of a sample XML");
        }

        # Fetch the first XML in the set, or, if --sample was given, then use that.
        my $sampleToTest = $opts->{sample};
        my $s = $sampleToTest ? $self->findSample($sampleToTest)
                              : $sg->{samples}[0];
        $self->_fetchXml($s);
        my $firstXml = $s->{'local-xml'};

        # Get the public and system ids from the doctype
        my $ids = getDoctype($firstXml);
        if (!$ids) {
            $self->failed("Couldn't read doctype declaration from $firstXml");
            return 0;  # not much we can do
        }

        # Store these results
        my $dtdPublicId = $sg->{'dtd-public-id'}
            = exists $ids->{'public'} ? $ids->{'public'} : '';
        my $dtdSystemId = $sg->{'dtd-system-id'} = $ids->{'system'};

        if ($dtdNewUrl) {
            # Validate the form of the identifiers
            # public:  e.g.  -//NLM//DTD einfo YYYYMMDD//EN
            if ($dtdPublicId !~ m{-//NLM//DTD [a-z]+ \d{8}//EN}) {
                $self->failed("DTD public identifier '$dtdPublicId' doesn't match expected form");
            }
            # system:  e.g.  http://eutils.ncbi.nlm.nih.gov/dtd/YYYYMMDD/einfo.dtd
            if ($dtdSystemId !~ m{http://eutils.ncbi.nlm.nih.gov/dtd/\d{8}/[a-z]+\.dtd}) {
                $self->failed("DTD system identifier '$dtdSystemId' doesn't match expected form");
            }
        }

        # Fetch the DTD
        return $self->downloadDtd($sg, $dtdSystemId, $tld);
    }


    elsif ($dtdSvn) {
        # We won't try to compute/verify the public identifier.
        $sg->{'dtd-public-id'} = '';

        # If the --dtd-svn option was given, then this better be an esummary idx samplegroup,
        # otherwise we have to fail.
        if ($eutil ne 'esummary' || !$idx) {
            $self->failed(
                "--dtd-svn was specified, but I don't know where this DTD is in svn:  $dtd");
            return 0;
        }

        # Get the database from the name of the dtd
        if ($dtd !~ /esummary_([a-z]+)\.dtd/) {
            $self->failed("Unexpected DTD name for esummary idx database:  $dtd");
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
            # Assume $dtdpath is a URL, and fetch it
            my $dest = "out/$dtd";
            $sg->{'dtd-system-id'} = $sg->{'dtd-url'} = $dtdpath;
            $sg->{'dtd-path'} = $dest;

            $self->message("Fetching $dtdpath");
            return $self->httpGetToFile($dtdpath, $dest);
        }
    }

    # User specified a local-filesystem location for the DTD explicitly (this can only
    # be used when testing a single samplegroup, but we don't enforce that -- it is up
    # to the user to make sure.)
    elsif ($dtdLoc) {
        # Don't try to compute the public identifier
        $sg->{'dtd-public-id'} = $sg->{'dtd-system-id'} = '';
        # Use the filesystem path as the system id and URL (not used, though)
        $sg->{'dtd-system-id'} = $sg->{'dtd-url'} = 'file://' . $dtdLoc;

        # Here is the local copy.
        my $dtdPath = $sg->{dtd};
        $sg->{'dtd-path'} = $dtdPath;

        $self->message("Fetching $dtdLoc -> $dtdPath");
        if (!copy($dtdLoc, $dtdPath)) {
            $self->failed("copying $dtdLoc -> $dtdPath");
            return 0;
        }

        return 1;
    }
}

#-------------------------------------------------------------
# Generate XML from Maxim's docsum tool (binary)

sub generateXml {
    my ($self, $s, $do, $xmlDocsumTool, $dbinfo, $build) = @_;
    $self->_setCurrentStep('generate-xml', $s);

    my $localXml = 'out/' . $s->{name} . '.xml';  # final output filename
    $s->{'local-xml'} = $localXml;

    if ($do) {
        if (!$dbinfo || !$build) {
            $self->failed("Can't run xml-docsumtool without --dbinfo and --build");
            return 0;
        }
        # Generate the list of XML docsums in a temporary file
        # Sample command line:
        #     cidxdocsum2xml -dbinfo $DBINFOINI -db pmc -build Build130513-0205.1 \
        #         -uid 14900,14901 > t.xml
        my $tmp = tmpnam();
        my $cmd = "$xmlDocsumTool -dbinfo $dbinfo -db pmc -build $build " .
                  "-outxml $tmp -uid 14900,14901";

        $self->message("Generating docsum file $tmp");
        my $status = system $cmd;
        if ($status != 0) {
            $self->failedCmd($status, $cmd);
            return 0;
        }

        # Now wrap it in esummaryset
        $self->message("Wrapping docsums  -> $localXml");

        my $src;
        if (!open($src, "<", $tmp)) {
            $self->failed("Can't open $tmp for reading");
            return 0;
        }
        open(my $dest, ">", $localXml) or die "Can't open $localXml for writing";
        print $dest "<eSummaryResult>\n" .
                    "<DocumentSummarySet status='OK'>\n";
        while (my $line = <$src>) {
            print $dest $line;
        }
        print $dest "</DocumentSummarySet>\n" .
                    "</eSummaryResult>\n";
        close $dest;
        close $src;

    }
    return 1;
}

#-------------------------------------------------------------
# Fetch an XML sample file, and puts 'local-xml' and 'real-xml-url'
# into the sample structure.
# This function returns 1 if successful, or 0 if there is a failure.

sub fetchXml {
    my ($self, $s) = @_;

    # See if this has already been fetched (possible if it was fetched
    # as part of fetchDtd)
    return 1 if ($s->{'local-xml'});

    return $self->_fetchXml($s);
}

#-------------------------------------------------------------
# This implements the guts of fetchXml.  It is reused by that step as
# well as by fetchDtd, which sometimes needs to grab an XML instance document in
# order to discover the system identifier.
# Returns 1 on success, 0 on failure.

sub _fetchXml {
    my ($self, $s) = @_;
    my $tld = $self->{opts}{tld};

    my $localXml = 'out/' . $s->{name} . ".xml";   # final output filename
    $s->{'local-xml'} = $localXml;

    my $xmlUrl = $eutilsBaseUrl . $s->{"eutils-url"};
    $s->{'xml-url'} = $xmlUrl;
    my $realUrl = $xmlUrl;
    if ($tld) {
        $realUrl =~ s/http:\/\/eutils/http:\/\/$tld/;
    }
    $s->{'real-xml-url'} = $realUrl;

    $self->message("Fetching $realUrl => $localXml");
    return $self->httpGetToFile($realUrl, $localXml);
}

#-------------------------------------------------------------
# Note that if there's a problem opening the local file for writing, that's
# a fatal error.
# Returns 1 on success, 0 on failure.

sub httpGetToFile {
    my ($self, $url, $localFile) = @_;

    my $req = HTTP::Request->new(GET => $url);
    my $res = $ua->request($req);
    if ($res->is_success) {
        open(my $OUT, ">", $localFile) or die("Can't open $localFile:  $!");
        print $OUT $res->content;
        close $OUT;
        return 1;
    }
    else {
        $self->failed("HTTP GET '$url':  " . $res->status_line);
        return 0;
    }
}

#-------------------------------------------------------------
# This does the actual download of the DTD for both fetchDtd
# and validateXml.
# This returns 1 if successful, or 0 if there was a failure.

sub downloadDtd {
    my ($self, $sg, $dtdSystemId, $tld, $dtdRemote) = @_;

    # Now the URL that we'll use to actually get it.
    my $dtdUrl = $dtdSystemId;
    if ($tld) {
        $dtdUrl =~ s/www/$tld/;
    }

    # Here is where we'll put the local copy, only if not --dtd-remote
    my $dtdPath = $dtdRemote ? '' : "out/" . $sg->{'dtd'};

    $sg->{'dtd-system-id'} = $dtdSystemId;
    $sg->{'dtd-url'} = $dtdUrl;
    $sg->{'dtd-path'} = $dtdPath;
    if (!$dtdRemote) {
        $self->message("Fetching $dtdUrl -> $dtdPath");
        return $self->httpGetToFile($dtdUrl, $dtdPath);
    }
    return 1;
}

#-------------------------------------------------------------
# Validate an XML file against a DTD.  This assumes that the DTD and the XML
# files have already been fetched.
# The DTD local path or URL that will be used is figured out on the basis of
# the $sg->{'dtd-url'} and $sg->{'dtd-path'} that were set in fetchDtd():
#     dtd-path   dtd-url
#     <path>      ---       Strip off doctype decl, and use --dtdvalid to point to local file
#     ''         <url>      Rewrite doctype decl, and use --valid
# Returns 1 if successful; 0 otherwise.

sub validateXml {
    my ($self, $s) = @_;
    my $sg = $s->{sg};
    my $dtdUrl = $sg->{'dtd-url'};
    my $dtdPath = $sg->{'dtd-path'};
    my $xml = $s->{'local-xml'};

    my $xmllintArg = '';   # command-line argument to xmllint, if needed.
    my $finalXml = $xml;   # The pathname of the actual file we'll pass to xmllint
    $finalXml =~ s/\.xml$/-test\.xml/;

    if ($dtdPath) {
        # Strip off the doctype declaration.  This is necessary because we want
        # to validate against local DTD files.  Note that even though
        # `xmllint --dtdvalid` does that local validation, it will still fail
        # if the remote DTD does not exist, which was the case, for example,
        # for pubmedhealth.
        $self->message("Stripping doctype decl:  $xml -> $finalXml");
        my $th;
        if (!open($th, "<", $xml)) {
            $self->failed("Can't open $xml for reading");
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
        $self->message("Writing new doctype decl:  $xml -> $finalXml");
        my $th;
        if (!open($th, "<", $xml)) {
            $self->failed("Can't open $xml for reading");
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
    my $cmd = 'xmllint --noout ' . $xmllintArg . ' ' . $finalXml . ' > /dev/null 2>&1';
    $self->message("Validating:  '$cmd'");
    my $status = system $cmd;
    if ($status != 0) {
        $self->failedCmd($status, $cmd);
        return 0;
    }
    return 1;
}

#------------------------------------------------------------------------
# Use the dtd2xml2json utility to generate an XSLT from the DTD.
# Alternatively, if $xsltLoc is specified, this just copies it from that
# location
# Returns 1 if successful; 0 otherwise.
# Puts the pathname of the generated file into 'json-xslt'

sub generateXslt {
    my ($self, $sg) = @_;

    # If this is the first time here, then
    # Get the XSLT base stylesheet, xml2json.xsl, into the out directory
    if (!$self->{'got-xml2json'}) {
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

        $self->{'got-xml2json'} = 1;
    }


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
    elsif ($jf =~ /\.dtd$/) {
        $jf =~ s/\.dtd$/2json.xslt/;
    }
    else {
        $self->failed(
            "Unrecognized DTD filename, don't know how to construct 2json XSLT filename: $jf");
        return 0;
    }
    my $jsonXslPath = $sg->{'json-xslt'} = $jp . $jf;


    # Run the utility, and capture both standard out and standard error into a
    # file
    my $outfile = 'out/dtd2xml2json.out';
    my $cmd = "dtd2xml2json $dtdSrc $jsonXslPath > $outfile 2>&1";
    $self->message("Creating XSLT $jsonXslPath");
    my $status = system $cmd;
    if ($status != 0) {
        $self->failedCmd($status, $cmd);
        return 0;
    }

    # Check the output from the command, to see if there were problems with
    # the JSON annotations (unfortunately, the tool does not return with an
    # error status when this happens).
    my $output = do {
        local $/ = undef;
        open my $fh, "<", $outfile or die "could not open $outfile: $!";
        <$fh>;
    };
    $sg->{'dtd2xml2json-out'} = $output;

    # Look for specific messages
    if ($output =~ /invalid json annotation/ ||
        $output =~ /tell me what to do/ ||
        $output =~ /unknown item group/ ||
        $output =~ /unrecognized element/)
    {
        $self->failed("Problems or warnings while running '$cmd'");
        return 0;
    }

    return 1;
}


#------------------------------------------------------------------------
# Returns 1 if successful; 0 otherwise.
# Puts the pathname of the generated file into $s->{'json-file'}

sub generateJson {
    my ($self, $s, $do) = @_;

    my $jsonXslt = $s->{sg}{'json-xslt'};

    # Use local-xml to figure out what the JSON filename should be,
    my $localXml = $s->{'local-xml'};
    my $jsonFile = $localXml;
    $jsonFile =~ s/\.xml$/.json/;
    $s->{'json-file'} = $jsonFile;

    # But use final-xml as input to the conversion
    my $finalXml = $s->{'final-xml'};
    if ($do) {
        $self->message("Converting XML -> JSON:  $jsonFile");
        my $errfile = 'out/xsltproc.err';
        my $cmd = "xsltproc $jsonXslt $finalXml > $jsonFile 2> $errfile";
        my $status = system $cmd;
        if ($status != 0) {
            $self->failedCmd($status, $cmd);
            return 0;
        }

        my $err = do {
            local $/ = undef;
            open my $fh, "<", $errfile or die "could not open $errfile: $!";
            <$fh>;
        };
        if (length($err) > 0)
        {
            $self->failed("Problem during the xsltproc conversion: '$cmd'");
            return 0;
        }
    }
    return 1;
}

#-------------------------------------------------------------
# Fetch the JSON results from EUtilities, and puts 'json-file' 'json-url',
# and 'real-json-url' into the sample structure.
# This function returns 1 if successful, or 0 if there is a failure.

sub fetchJson {
    my ($self, $s, $tld) = @_;
    $self->_setCurrentStep('fetch-json', $s);

    my $jsonFile = 'out/' . $s->{name} . ".json";   # final output filename
    $s->{'json-file'} = $jsonFile;



    my $jsonUrl = $eutilsBaseUrl . $s->{"eutils-url"} . '&retmode=json';
    $s->{'json-url'} = $jsonUrl;
    my $realUrl = $jsonUrl;
    if ($tld) {
        $realUrl =~ s/http:\/\/eutils/http:\/\/$tld/;
    }
    $s->{'real-json-url'} = $realUrl;

    # For inserting into the system command, escape ampersands:
    my $cmdUrl = $realUrl;
    $cmdUrl =~ s/\&/\\\&/g;

    $self->message("Fetching $realUrl => $jsonFile");
    return $self->httpGetToFile($cmdUrl, $jsonFile);
}


#------------------------------------------------------------------------
# Returns 1 if successful; 0 otherwise.

sub validateJson {
    my ($self, $s, $do) = @_;
    $self->_setCurrentStep('validate-json', $s);
    my $jsonFile = $s->{'json-file'};

    if ($do) {
        my $cmd = "jsonlint -q $jsonFile > /dev/null 2>&1";
        $self->message("Validating $jsonFile");
        my $status = system $cmd;
        if ($status != 0) {
            $self->failedCmd($status, $cmd);
            return 0;
        }
    }
    return 1;
}

#-----------------------------------------------------------------------------
# Utility function to extract public and system ids from a local file,
# from its doctype declaration.  This returns 0 if it couldn't find anything,
# or a hash like this:  { 'public-id' => '....', 'system-id' => '....' }

sub getDoctype {
    my $xmlFilename = shift;

    # FIXME:  this should only read as far as the end of the doctype.
    # Slurp the whole file into a string
    my $xml = do {
        local $/ = undef;
        open my $xmlFile, "<", $xmlFilename
            or return 0;
        <$xmlFile>;
    };

    if ($xml =~ m/<\!DOCTYPE.*?PUBLIC\s+"(.*?)"\s+"(.*?)"/) {
        return {
            'public' => $1,
            'system' => $2,
        };
    }
    if ($xml =~ m/<\!DOCTYPE.*?SYSTEM\s+"(.*?)"/) {
        return {
            'system' => $1,
        };
    }
    return 0;
}

#------------------------------------------------------------------------
# $self->failed($msg);
# This delegates writing the error message to the Logger, and then checks
# the status of continue-on-error

sub failed {
    my ($self, $msg) = @_;
    $self->{log}->failed($msg);
    exit 1 if !$self->{coe};
}

#------------------------------------------------------------------------
# $self->failedCmd($status, $cmd);
# Failure handler for a system command.
# This produces a canned message, and also causes the system to exit if
# the status indicates an abnormal termination, even if continue-on-error
# is active.  This lets us exit if the user presses ^C, even when
# continue-on-error is true.

sub failedCmd {
    my ($self, $status, $cmd) = @_;
    my $msg = "System command '$cmd':  $?";
    $self->failed($msg);
    exit 1 if $status & 127;
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
# Summary pass / fail report
sub summaryReport {
    my $self = shift;
    my $logger = $self->{log};

    # What is the total number of different test types that have been run?
    my $testNames = $logger->{'test-names'};
    my $numTestTypes = scalar (keys %$testNames);
    print "Number of different test types = " . $numTestTypes . "\n";

    if ($logger->{failures}) {
        print $logger->{failures} . " failures of " . $logger->{'total-tests'} . " tests:\n";
        foreach my $sg (@{$self->{samplegroups}}) {
            if ($sg->{failed}) {
                print "  " . $sg->{dtd} . ":\n";
                if ($numTestTypes > 1) {
                    foreach my $test (@{$sg->{tests}}) {
                        if ($test->{failed}) {
                            print "    " . $test->{name} . "\n";
                        }
                    }
                }
                foreach my $s (@{$sg->{samples}}) {
                    if ($s->{failed}) {
                        print "    " . $s->{name} . ":\n";
                        if ($numTestTypes > 1) {
                            foreach my $test (@{$sg->{tests}}) {
                                if ($test->{failed}) {
                                    print "      " . $test->{name} . "\n";
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    else {
        print "All tests passed!\n";
    }
}

1;
