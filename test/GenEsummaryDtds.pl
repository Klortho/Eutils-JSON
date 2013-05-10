#!/opt/perl-5.8.8/bin/perl

# FIXME:  I took @dbs out of EutilsJson -- the list of databases is now stored
# in the samples.xml file.  So, this script is broken for now.

# This script will auto-generate all of the eSummary DTDs from the cidx utility.
# For each database, first, we find the latest build with the command
#     cidxdbgetparam -db $db -dbinfo $dbinfoIni -n buildversion
# Next, we generate the DTD from the ini file in that build, with
#     cidxgendocsumdtd -dbinfo $dbinfoIni -db $db -build $buildversion \
#         -dtd $outputFile

use strict;
use EutilsJson;

my $debug = 0;


# Here's some information about the CIDX utility; adjust these as needed
my $cidxhome = '/panfs/pan1.be-md.ncbi.nlm.nih.gov/entrez_cidx';
my $cidxbin = "$cidxhome/130307_2.2/bin";
my $dbinfoIni = "$cidxhome/dbinfo.ini";

foreach my $db (@EutilsJson::dbs) {
    genEsummaryDtd($db);
}

#----------------------------------------------------------------------
# Generate an eSummary DTD for a single database using the cidxgendocsumdtd
# utility.

sub genEsummaryDtd
{
    my $db = shift;

    # Get the build version
    my $cmd = "$cidxbin/cidxdbgetparam -db $db -dbinfo $dbinfoIni -n buildversion 2> /dev/null";
    if ($debug) { print "executing '$cmd'\n"; }
    my $buildversion = `$cmd`;
    $buildversion = 'error' if ($?);
    chomp $buildversion;

    print "-------------------------------------------\n" .
          "$db: build: $buildversion\n";

    if ($buildversion ne 'error') {
        # First use the cidxgendocsumdtd to generate a *broken* DTD.  After we
        # get the DTD, we'll fix it up.
        my $brokenDtd = "eSummary_$db.broke.dtd";
        my $cmd = "$cidxbin/cidxgendocsumdtd -dbinfo $dbinfoIni -db $db " .
                  "-build $buildversion -dtd $brokenDtd";
        if ($debug) { print "executing '$cmd'\n"; }
        system $cmd;
        if (! -f $brokenDtd) {
            print "Error!  $brokenDtd not created\n";
            next;
        }

        # Now let's fix it up
        my $fixedDtd = "eSummary_$db.dtd";
        system "./fix-dtds.pl $brokenDtd > $fixedDtd";
        if (! -f $fixedDtd) {
            print "Error!  $fixedDtd not created\n";
            next;
        }

        # Now that we're sure we've got a good one, remove the bad one.
        unlink $brokenDtd;
    }
}

