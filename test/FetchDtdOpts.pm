package FetchDtdOpts;

# Step-specific options
our @opts = (
    "dtd-svn",
    'dtd-nocheck',
);

our $optsUsage = q(
Options related to fetching the DTD.  By default, the first sample in a sample
group (or, if --sample, is given, use that) is examined to determine the
location of the DTD.
  --dtd-svn - Get the DTDs from svn instead of a sample system identifier.
    Only works with --idx samplegroups.
  --dtd-nocheck - Don't check the form of the public and system identifiers.
);

#-------------------------------------------------------------------
sub processOpts {
    my $Opts = shift;

    # Some options defaults for step-specific options
    $Opts->{'dtd-svn'} = 0     if !$Opts->{'dtd-svn'};
    $Opts->{'dtd-nocheck'} = 0 if !$Opts->{'dtd-nocheck'};
}

1;
