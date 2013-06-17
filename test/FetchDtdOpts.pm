package FetchDtdOpts;

# Step-specific options
our @opts = (
    "dtd-newurl",
    "dtd-doctype",
    "dtd-svn",
    "dtd-loc:s",
);

our $optsUsage = q(
Options related to the DTD.  These are mutually exclusive.  If none are given,
then --dtd-newurl is the default.
  --dtd-newurl - Get the DTD based on the doctype-decl of a sample XML, while
    validating that the URI is in the correct form.  This is the default.
  --dtd-doctype - Same as --dtd-newurl, but doesn't do any checking of the URIs.
    doctype declaration of the first sample in the group
  --dtd-svn - Get the DTDs from svn instead of the system identifier.  Only
    works with --idx.  Can't be used with other --dtd options.
  --dtd-loc=<path-to-dtd> - Specify the location of the DTD (on the filesystem)
    explicitly.  This should only be used when testing just one samplegroup at
    a time.
);

#-------------------------------------------------------------------
sub processOpts {
    my $Opts = shift;

    # Some options defaults for step-specific options
    $Opts->{'dtd-newurl'} = 0  if !$Opts->{'dtd-newurl'};
    $Opts->{'dtd-doctype'} = 0 if !$Opts->{'dtd-doctype'};
    $Opts->{'dtd-svn'} = 0     if !$Opts->{'dtd-svn'};
    $Opts->{'dtd-loc'} = ''    if !$Opts->{'dtd-loc'};

    # Verify that no more than one is given
    my $numDtdOpts = ($Opts->{'dtd-newurl'} ? 1 : 0) +
                     ($Opts->{'dtd-doctype'} ? 1 : 0) +
                     ($Opts->{'dtd-svn'} ? 1 : 0) +
                     ($Opts->{'dtd-loc'} ? 1 : 0);
    if ($numDtdOpts == 0) {
        $Opts->{'dtd-newurl'} = 1;
    }
    elsif ($numDtdOpts > 1) {
        die "No more than one --dtd option can be given.";
    }
}

1;
