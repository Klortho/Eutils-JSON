package FetchDtdOpts;

# Step-specific options
our @opts = (
    "dtd-svn",
);

our $optsUsage = q(
Options related to fetching the DTD.  By default, the first sample in a sample
group (or, if --sample, is given, use that) is examined to determine the
location of the DTD.
  --dtd-svn - Get the DTDs from svn instead of a sample system identifier.
    Only works with --idx samplegroups.
);

#-------------------------------------------------------------------
sub processOpts {
    my $Opts = shift;

    # Some options defaults for step-specific options
    $Opts->{'dtd-svn'} = 0     if !$Opts->{'dtd-svn'};
}

1;
